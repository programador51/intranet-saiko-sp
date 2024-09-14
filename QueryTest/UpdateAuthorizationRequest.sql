DECLARE @hasItBeenAttended BIT;
DECLARE @lasUpdateBy NVARCHAR(30);
DECLARE @lastUpdatedDate DATETIME;
DECLARE @limitBillingTime DATETIME;
DECLARE @partialitiesAllowed INT;
DECLARE @tcAllowed DECIMAL(14,2);
DECLARE @wasAccepted BIT;
DECLARE @idAuthorization INT;

DECLARE @tranName NVARCHAR(30)= 'updateAuthorization';


BEGIN TRY
    BEGIN TRANSACTION @tranName
    UPDATE InvoiceAuthorizations SET 
        hasItBeenAttended= @hasItBeenAttended,
        lasUpdateBy= @lasUpdateBy,
        lastUpdatedDate= @lastUpdatedDate,
        limitBillingTime= @limitBillingTime,
        partialitiesAllowed= @partialitiesAllowed,
        tcAllowed= @tcAllowed,
        wasAccepted= @wasAccepted
    WHERE id= @idAuthorization
    COMMIT TRANSACTION @tranName
END TRY

BEGIN CATCH
    DECLARE @Message NVARCHAR(MAX);
            DECLARE @Severity  INT= ERROR_SEVERITY()
            DECLARE @State   SMALLINT = ERROR_SEVERITY()

            DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar para actualizar la autorización',
                @hasItBeenAttended,
                @lasUpdateBy,
                @lastUpdatedDate,
                @limitBillingTime,
                @partialitiesAllowed,
                @tcAllowed,
                @wasAccepted,
                @idAuthorization
               );
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
            EXEC sp_AddLog @lasUpdateBy,@infoSended,@Message,@Message,@wasAnError,@mustBeSyncManually,@provider;
END CATCH

