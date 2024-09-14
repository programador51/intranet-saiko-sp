DECLARE @idCustomer INT 
DECLARE @idInvoice INT 
DECLARE @idOc INT 
DECLARE @idUserCreated INT 
DECLARE @idUserDestination INT 
DECLARE @partialitiesRequested INT 
DECLARE @tcRequested DECIMAL (14,2)
DECLARE @totalRequested DECIMAL (14,2)
DECLARE @isInvalidTc BIT
DECLARE @isInvalidPartialities BIT
DECLARE @requiresCurrencyExchange BIT
DECLARE @createdBy NVARCHAR(30)
DECLARE @lasUpdateBy NVARCHAR(30)


DECLARE @tranName NVARCHAR (50)= 'addAuthorizationRequest';

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


