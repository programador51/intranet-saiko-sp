-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-24-2022
-- Description: Cancel the quote
-- STORED PROCEDURE NAME:	sp_CancelQuoteDocument
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: Document id
-- @lastUpdateBy: User who try to cancel the document.
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @originId: Especifys the contract id
-- @isCancelable: Identify if the quote is cancelable or not
-- @Message: Message to return
-- @tranName: Transaction name
-- @Severity: Severity error
-- @State: State of error
-- @createdBy: user who try to update the record
-- @infoSended: Info that was dended to update the document
-- @wasAnError: Indicates if was an error or not
-- @mustBeSyncManually: Indicates if must sync manually
-- @provider: Identifys the error provider.
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
--	2022-05-24		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/24/2022
-- Description: sp_Name - Cancel the quote
CREATE PROCEDURE sp_CancelQuoteDocument(
    @documentId INT,
    @lastUpdateBy NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    DECLARE @originId INT;
    DECLARE @isCancelable BIT;

    DECLARE @Message NVARCHAR(MAX);
    DECLARE @tranName NVARCHAR(30) = 'cancelQuote';
    -- ----------------- ↓↓↓ IDENTIFICATES IF IS CANCELABLE AND HIS ORIGIN ↓↓↓ -----------------------
    BEGIN TRY
        BEGIN TRANSACTION @tranName
        SELECT 
            @isCancelable= CASE
                            WHEN idStatus =1 THEN 1
                            ELSE 0
                        END,
            @originId= idContractParent
            FROM Documents WHERE idDocument= @documentId;

        -- ----------------- ↑↑↑ IDENTIFICATES IF IS CANCELABLE AND HIS ORIGIN ↑↑↑ -----------------------

        -- ----------------- ↓↓↓ UPDATES THE DOCUMENTS ACORDING THE VALIDATIONS ↓↓↓ -----------------------
        IF @isCancelable = 1
            BEGIN
                UPDATE Documents SET
                    idStatus= 4,
                    lastUpdatedBy=   @lastUpdateBy,
                    lastUpdatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                WHERE idDocument = @documentId
                IF @originId IS NOT NULL
                    BEGIN
                        UPDATE Documents SET
                            idStatus= 15,
                            lastUpdatedBy=   @lastUpdateBy,
                            lastUpdatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                        WHERE idDocument = @originId
                    END
                SELECT 'La cotizacion fue cancelada con exito' AS [Message]
            END
        ELSE
            BEGIN
                SET @Message= 'La cotización no puede ser cancelada, el estatus no es "Abierta" '
                RAISERROR(@Message, 1,0);
            END
        -- ----------------- ↑↑↑ UPDATES THE DOCUMENTS ACORDING THE VALIDATIONS ↑↑↑ -----------------------
        COMMIT TRANSACTION @tranName
    END TRY

    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()

        DECLARE @createdBy NVARCHAR(30)= @lastUpdateBy;
        DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar en orden para el SP sp_CancelQuoteDocument',@documentId,@lastUpdateBy);
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
                            ROLLBACK TRANSACTION;   
                        END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog @createdBy,@infoSended,@Message,@Message,@wasAnError,@mustBeSyncManually,@provider;
        
    END CATCH

    -- SELECT @hasOrigin AS Origin, @isCancelable AS isCancelable

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------