-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-27-2022
-- Description: Updates the contract document
-- STORED PROCEDURE NAME:	sp_UpdateContractDocument
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idContact: The contact id
-- @idTypeDocument: The document type id
-- @idCurrency: Currency id 
-- @tc: Exchange rate
-- @expirationDate: Expiration date
-- @reminderDate: reminder date
-- @idProbability: the probability id
-- @creditDays: total of credit days
-- @subtotal: The total amount without taxes
-- @iva: total IVA amount
-- @totalAmount: Total amount with IVA
-- @createdBy: The user full name who create the record
-- @idCustomer: The customer id this document is for
-- @idExecutive: The executive who create the document
-- @autorizationFlag: Indicates if the document requires authorization before any process (1 = Does not require authorization | 2 = Requires authorization | 3 = In authorization process | 4 = Authorized)
-- @idPeriocityType: The periocity type the document belongs
-- @periocityValue: The current month or the number of days
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
--	2022-05-27		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/27/2022
-- Description: sp_UpdateContractDocument - Updates the contract document
CREATE PROCEDURE sp_UpdateContractDocument(
    @idDocument INT,
    @idContact INT,
    @currencyCode NVARCHAR(3),
    @tc DECIMAL (14,2),
    @expirationDate DATETIME,
    @reminderDate DATETIME,
    @creditDays INT,
    @subtotal DECIMAL (14,4),
    @iva DECIMAL (14,4),
    @totalAmount DECIMAL (14,4),
    @createdBy NVARCHAR (30),
    @idCustomer INT,
    @idExecutive INT,
    @autorizationFlag INT,
    @idPeriocityType INT,
    @periocityValue INT,
    @contractKey NVARCHAR (50),
    @startDate DATETIME,
    @endDate DATETIME
) AS 
BEGIN
    DECLARE @idCurrency INT;
    exec @idCurrency = sp_GetIdCurrencyCode @currencyCode = @currencyCode;

    DECLARE @tranName NVARCHAR(30) ='updateContract';
    DECLARE @tranName2 NVARCHAR(30) ='addNotes';
    DECLARE @ErrorOccurred TINYINT;
    DECLARE @Message NVARCHAR (256);
    DECLARE @CodeNumber INT;

    BEGIN TRY
        BEGIN TRANSACTION @tranName

        UPDATE Documents SET
        idCustomer= @idCustomer,
        idContact= @idContact,
        subTotalAmount= @subtotal,
        ivaAmount= @iva,
        totalAmount= @totalAmount,
        expirationDate= @expirationDate,
        reminderDate= @reminderDate,
        idCurrency= @idCurrency,
        protected= @tc,
        [contract]= @contractKey,
        lastUpdatedDate= dbo.fn_MexicoLocalTime(GETDATE()),
        lastUpdatedBy= @createdBy
        WHERE documentId =@documentId
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