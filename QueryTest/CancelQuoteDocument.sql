DECLARE @documentId INT=658;
DECLARE @lastUpdateBy NVARCHAR(256);


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
                idStatus= 4
            WHERE idDocument = @documentId
            IF @originId IS NOT NULL
                BEGIN
                    UPDATE Documents SET
                        idStatus= 15
                    WHERE idDocument = @originId
                END
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