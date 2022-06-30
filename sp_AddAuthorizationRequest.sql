-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-30-2022
-- Description: Add an authorization request for the document
-- STORED PROCEDURE NAME:	sp_AddAuthorizationRequest
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
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
--	2022-06-30		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/30/2022
-- Description: sp_AddAuthorizationRequest - Add an authorization request for the document
CREATE PROCEDURE sp_AddAuthorizationRequest(
    @idCustomer INT,
    @idInvoice INT,
    @idOc INT,
    @idUserCreated INT,
    @idUserDestination INT,
    @partialitiesRequested INT,
    @tcRequested DECIMAL(14,2),
    @totalRequested DECIMAL(14,2),
    @isInvalidTc BIT,
    @isInvalidPartialities BIT,
    @requiresCurrencyExchange BIT,
    @createdBy NVARCHAR(30),
    @lasUpdateBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR (50)= 'addAuthorizationRequest';
    DECLARE @authorizationtype INT =1
    BEGIN TRY
        BEGIN TRANSACTION @tranName
        INSERT INTO InvoiceAuthorizations (
            authorizationType,
            idCustomer,
            idInvoice,
            idOc,
            idUserCreated,
            idUserDestination,
            partialitiesRequested,
            tcRequested,
            totalRequested,
            isInvalidTc,
            isInvalidPartialities,
            requiresCurrencyExchange,
            createdBy,
            lasUpdateBy

        )
        VALUES (
            @authorizationtype,
            @idCustomer,
            @idInvoice,
            @idOc,
            @idUserCreated,
            @idUserDestination,
            @partialitiesRequested,
            @tcRequested,
            @totalRequested,
            @isInvalidTc,
            @isInvalidPartialities,
            @requiresCurrencyExchange,
            @createdBy,
            @lasUpdateBy
        )
    COMMIT TRANSACTION @tranName
    END TRY
        
    BEGIN CATCH
                DECLARE @Message NVARCHAR(MAX);
                DECLARE @Severity  INT= ERROR_SEVERITY()
                DECLARE @State   SMALLINT = ERROR_SEVERITY()

                DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar en orden para el SP sp_CancelQuoteDocument',
                    @idCustomer,
                    @idInvoice,
                    @idOc,
                    @idUserCreated,
                    @idUserDestination,
                    @partialitiesRequested,
                    @tcRequested,
                    @totalRequested,
                    @isInvalidTc,
                    @isInvalidPartialities,
                    @requiresCurrencyExchange);
                DECLARE @wasAnError TINYINT=1;
                DECLARE @mustBeSyncManually TINYINT=1;
                DECLARE @provider TINYINT=4;

                SET @Message= ERROR_MESSAGE();
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
                                    ROLLBACK TRANSACTION @tranName;   
                                END
                RAISERROR(@Message, @Severity, @State);
                EXEC sp_AddLog @createdBy,@infoSended,@Message,@Message,@wasAnError,@mustBeSyncManually,@provider;
    END CATCH

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------