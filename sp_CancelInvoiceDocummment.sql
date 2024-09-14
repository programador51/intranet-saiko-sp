-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-25-2022
-- Description: Cancel the invoice and reverse the related documents
-- STORED PROCEDURE NAME:	sp_CancelInvoiceDocummment
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:

-- @quoteId: Especifys the quote id
-- @orderId: Especifys the order id
-- @isCancelable: Identify if the ODC is cancelable or not
-- @isSpecial: Identify if the ODC is special
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
--	2022-05-25		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/25/2022
-- Description: sp_CancelInvoiceDocummment - Cancel the invoice and reverse the related documents
CREATE PROCEDURE sp_CancelInvoiceDocummment(
   @documentId INT,
   @lastUpdateBy NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @isCancelable BIT;
    DECLARE @orderId INT;
    DECLARE @quoteId INT;
    DECLARE @tranName NVARCHAR(30) = 'cancelInvoice';
    DECLARE @Message NVARCHAR(MAX);

    BEGIN TRY
        BEGIN TRANSACTION @tranName

        SELECT 
        @orderId= document.idDocument,
        @quoteId= document.idQuotation


        FROM LegalDocuments AS legalDocument
        LEFT JOIN Documents AS document ON document.uuid= legalDocument.uuid

        SELECT 

            @isCancelable= CASE 
                                WHEN COUNT(*) = 0 OR COUNT(*) IS NULL THEN 1
                                ELSE 0
                            END

        FROM Documents WHERE idTypeDocument= 5 AND idInvoice=@orderId AND (idStatus = 17 OR idStatus=18)

        IF @isCancelable= 1
            BEGIN
                -- Cambia los Estatus de las CxC a canceladas.
                UPDATE Documents SET
                    idStatus= 19,
                    lastUpdatedBy=   @lastUpdateBy,
                    lastUpdatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                WHERE idTypeDocument= 5 AND idInvoice=@orderId

                -- Cambia el estatus de la Facutra a cancelado
                UPDATE LegalDocuments SET   
                    idLegalDocumentStatus= 8,
                    lastUpdatedBy=   @lastUpdateBy,
                    lastUpadatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                WHERE id= @documentId

                -- Cambia el estatus del pedido a No-Facturado
                UPDATE Documents SET 
                    idStatus= 9,
                    lastUpdatedBy=   @lastUpdateBy,
                    lastUpdatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                WHERE idDocument= @orderId;

                -- Cambia el estatus de la cotizacion a Ganada
                UPDATE Documents SET 
                    idStatus= 2,
                    lastUpdatedBy=   @lastUpdateBy,
                    lastUpdatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                WHERE idDocument= @quoteId;

                SET @Message= 'La factura fue cancelada con exito';
                SELECT @Message AS [Message]
                COMMIT TRANSACTION @tranName
            END
        ELSE
            BEGIN
                SET @Message= 'La factura no puede ser cancelada debido a que ya tiene CXC asociadas a un ingreso';
                RAISERROR(@Message, 1,0);
                COMMIT TRANSACTION @tranName
            END

    END TRY

    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()

        DECLARE @createdBy NVARCHAR(30)= @lastUpdateBy;
        DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar en orden para el SP sp_CancelOrderDocument',@documentId,@lastUpdateBy);
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