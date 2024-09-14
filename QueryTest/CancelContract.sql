DECLARE @documentId INT=650;
DECLARE @lastUpdateBy NVARCHAR(256);


DECLARE @tranName NVARCHAR(30) = 'terminateContract';
DECLARE @Message NVARCHAR(MAX);
DECLARE @isCancelable BIT;


BEGIN TRY
    BEGIN TRANSACTION @tranName
    SELECT @isCancelable=  CASE 
                                WHEN idStatus= 13 THEN 1
                                ELSE 0
                            END
    FROM  Documents
    WHERE idDocument= @documentId

    IF @isCancelable= 1
        BEGIN
            UPDATE Documents SET 
                idStatus=  15
            WHERE idDocument= @documentId
            SET @Message= 'El contrato se termino con exito';
            SELECT @Message AS [Message]
            COMMIT TRANSACTION @tranName
        END
    ELSE
        BEGIN
            SET @Message= 'El contrato no peude ser terminado debido a que debe estar vigente';
            RAISERROR(@Message, 1,0);
            COMMIT TRANSACTION @tranName
        END


END TRY

BEGIN CATCH
    DECLARE @Severity  INT= ERROR_SEVERITY()
    DECLARE @State   SMALLINT = ERROR_SEVERITY()

    DECLARE @createdBy NVARCHAR(30)= @lastUpdateBy;
    DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar en orden para el SP sp_CancelContract',@documentId,@lastUpdateBy);
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
   
END CATCH