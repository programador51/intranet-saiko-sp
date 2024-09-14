DECLARE @documentId INT=650;
DECLARE @lastUpdateBy NVARCHAR(256);


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
                idStatus= 19
            WHERE idTypeDocument= 5 AND idInvoice=@orderId

            -- Cambia el estatus de la Facutra a cancelado
            UPDATE LegalDocuments SET   
                idLegalDocumentStatus= 8
            WHERE id= @documentId

            -- Cambia el estatus del pedido a No-Facturado
            UPDATE Documents SET 
                idStatus= 9
            WHERE idDocument= @orderId;

            -- Cambia el estatus de la cotizacion a Ganada
            UPDATE Documents SET 
                idStatus= 2
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



