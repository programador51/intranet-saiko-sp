-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-12-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_AddODCDocument
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idContact: Contact id
-- @idCurrency: Curency id
-- @tc: Change rate
-- @expirationDate: Expiration date
-- @reminderDate: Reminder date
-- @idProgress: progress id
-- @creditDays: Credit days
-- @subtotal: Subtotal amount
-- @iva: IVA
-- @totalAmount: Total amount
-- @createdBy: user who create the record
-- @idCustomer: customer id
-- @idStatus: status id
-- @idExecutive: Executive id
-- @autorizationFlag: Autorization flag id
-- @generateCXP: indicates if generate CXP
-- @idPeriocityType: periocity Type id
-- @periocityValue: periocity value
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
--	2022-05-12		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/12/2022
-- Description: sp_AddODCDocument - Some Notes
CREATE PROCEDURE sp_AddODCDocument(
    @idContact INT,
    @idCurrency INT,
    @tc DECIMAL (14,2),
    @expirationDate DATETIME,
    @reminderDate DATETIME,
    @idProgress INT,
    @creditDays INT,
    @subtotal DECIMAL (14,4),
    @iva DECIMAL (14,4),
    @totalAmount DECIMAL (14,4),
    @createdBy NVARCHAR (30),
    @idCustomer INT,
    @idStatus INT,
    @idExecutive INT,
    @autorizationFlag INT,
    @generateCXP TINYINT,
    @idPeriocityType INT,
    @periocityValue INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @idDocument INT
    DECLARE @tranName NVARCHAR(30) ='addODC';
    DECLARE @tranName2 NVARCHAR(30) ='addNotes';
    DECLARE @ErrorOccurred TINYINT;
    DECLARE @Message NVARCHAR (256);
    DECLARE @CodeNumber INT;

    BEGIN TRY
        BEGIN TRANSACTION @tranName

        INSERT INTO Documents (
            idTypeDocument,  
            idCustomer,
            createdBy,
            lastUpdatedBy,
            idContact,
            idCurrency,
            protected,
            idProgress,
            creditDays,
            totalAmount,
            subTotalAmount,
            ivaAmount,
            idStatus,
            createdDate,
            lastUpdatedDate,
            idExecutive,
            generateCXP,
            expirationDate,
            reminderDate,
            documentNumber

        ) VALUES (
            3,--
            @idCustomer, --
            @createdBy,--
            @createdBy,--
            @idContact,--
            @idCurrency,--
            @tc,--
            @idProgress,--?
            @creditDays,--
            @totalAmount,--
            @subtotal,--
            @iva,--
            5, --
            dbo.fn_MexicoLocalTime(GETDATE()),--
            dbo.fn_MexicoLocalTime(GETDATE()),--
            @idExecutive,--
            @generateCXP,--
            @expirationDate,--
            @reminderDate,--
            dbo.fn_NextDocumentNumber(3)--

        )

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
                        SELECT @idDocument= SCOPE_IDENTITY()
                        INSERT INTO Periocity (
                            createdBy,
                            idDocument,
                            idPeriocityType,
                            lastUpdatedBy,
                            [value]
                        )
                        VALUES (
                            @createdBy,
                            @idDocument,
                            @idPeriocityType,
                            @createdBy,
                            @periocityValue
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
    --  SELECT @ErrorOccurred AS ErrorOccurred, @Message AS [Message], @CodeNumber AS CodeNumber
    SELECT SCOPE_IDENTITY() AS id
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