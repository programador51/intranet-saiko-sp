-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-06-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_UpdateQuoteDocument
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idDocument: Document id
-- @idContact: Contact id
-- @currencyCode: Currency code
-- @tc: Exchange rate
-- @expirationDate: Espiration date
-- @reminderDate: Reminder date
-- @idProbability: Probability id
-- @creditDays: Credit days
-- @subtotal: Subtotal amount 
-- @iva: Iva amount
-- @totalAmount: Total amount
-- @createdBy: User who modify the record
-- @autorizationFlag: Autorization flag id
-- @idPeriocityType: Pe
-- @periocityValue:
-- @startDate:
-- @endDate:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-05-06		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/06/2022
-- Description: sp_UpdateQuoteDocument - Some Notes
CREATE PROCEDURE sp_UpdateQuoteDocument(
    @idDocument INT,
    @idContact INT,
    @currencyCode NVARCHAR(3),
    @tc DECIMAL (14,2),
    @expirationDate DATETIME,
    @reminderDate DATETIME,
    @idProbability INT,
    @creditDays INT,
    @subtotal DECIMAL (14,4),
    @iva DECIMAL (14,4),
    @totalAmount DECIMAL (14,4),
    @createdBy NVARCHAR (30),
    @autorizationFlag INT,
    @idPeriocityType INT,
    @periocityValue INT,
    @startDate DATETIME,
    @endDate DATETIME
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @idCurrency INT;
    exec @idCurrency = sp_GetIdCurrencyCode @currencyCode = @currencyCode;

    DECLARE @tranName NVARCHAR(30) ='addQuote';
    DECLARE @tranName2 NVARCHAR(30) ='addNotes';
    DECLARE @ErrorOccurred TINYINT;
    DECLARE @Message NVARCHAR (256);
    DECLARE @CodeNumber INT;

    BEGIN TRY
        BEGIN TRANSACTION @tranName

        UPDATE Documents 
        SET idContact=@idContact,
        idCurrency= @idCurrency,
        protected= @tc,
        expirationDate= @expirationDate,
        reminderDate=  @reminderDate,
        idProbability=   @idProbability,
        creditDays=@creditDays,
        lastUpdatedBy= @createdBy,
        totalAmount=@totalAmount,
        subTotalAmount= @subtotal,
        ivaAmount=  @iva,
        documentNumber=  dbo.fn_NextDocumentNumber(1),
        authorizationFlag= @autorizationFlag, -- authorization flag,
        lastUpdatedDate =dbo.fn_MexicoLocalTime(GETDATE())

        WHERE idDocument= @idDocument

        IF (@@ERROR <>0 AND @@ROWCOUNT <= 0)
            BEGIN
                SET @ErrorOccurred= 1 -- Significa que fallo
                SELECT @Message= text FROM sys.messages WHERE message_id=@@ERROR
                SET @CodeNumber= @@ERROR
                ROLLBACK TRANSACTION @tranName
            END
        ELSE
            BEGIN
                IF (@idPeriocityType IS NOT NULL AND @periocityValue IS NOT NULL)
                    BEGIN
                        BEGIN TRANSACTION @tranName2 
                        DELETE FROM Periocity WHERE idDocument=@idDocument;
                        INSERT INTO Periocity (
                            createdBy,
                            idDocument,
                            idPeriocityType,
                            lastUpdatedBy,
                            [value],
                            startDate,
                            endDate
                        )
                        VALUES (
                            @createdBy,
                            @idDocument,
                            @idPeriocityType,
                            @createdBy,
                            @periocityValue,
                            @startDate,
                            @endDate
                        )
                        IF (@@ERROR <>0 AND @@ROWCOUNT <= 0)
                            BEGIN
                                SET @ErrorOccurred= 1 -- Significa que fallo
                                SELECT @Message= text FROM sys.messages WHERE message_id=@@ERROR
                                SET @CodeNumber= @@ERROR
                                ROLLBACK TRANSACTION @tranName2
                            END
                        ELSE
                            BEGIN
                                SET @ErrorOccurred= 0
                                SET @Message='Registros insertados correctamente'
                                SET @CodeNumber= 200
                                COMMIT TRANSACTION @tranName2
                            END
                    END
                
                SET @ErrorOccurred= 0
                SET @Message='Registros insertados correctamente'
                SET @CodeNumber= 200
                COMMIT TRANSACTION @tranName2
            END
    -- SELECT @ErrorOccurred AS ErrorOccurred, @Message AS [Message], @CodeNumber AS CodeNumber
    END TRY

    BEGIN CATCH
        IF (XACT_STATE()= -1)
            BEGIN
                ROLLBACK TRANSACTION @tranName
            END
        IF (XACT_STATE()=1)
            BEGIN
                COMMIT TRANSACTION @tranName
            END

        IF @@TRANCOUNT > 0  
            BEGIN
                ROLLBACK TRANSACTION;   
            END
        SELECT 
            1 AS ErrorOccurred, 
            'Problemas con la Base de datos, no se pudo insertar los registros' AS [Message],
            ERROR_NUMBER() AS CodeNumber,
            ERROR_MESSAGE() AS ErrorMessage
    END CATCH


END