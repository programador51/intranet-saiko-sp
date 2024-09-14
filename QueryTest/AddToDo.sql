
DECLARE @atentionDate DATETIME;
DECLARE @createdBy NVARCHAR(30);
DECLARE @executiveWhoCreatedId INT;
DECLARE @fromId INT;
DECLARE @idSection INT;
DECLARE @idTag INT
DECLARE @reminderDate DATETIME;
DECLARE @tagDescription NVARCHAR(30);
DECLARE @title NVARCHAR(128);
DECLARE @todoNote NVARCHAR(256);

DECLARE @tranName NVARCHAR(30)= 'addTodo'
DECLARE @Message NVARCHAR(MAX);

BEGIN TRY

    BEGIN TRANSACTION @tranName
    IF (@idTag=-1)
        BEGIN
        -- it measn the tag is new
        EXEC @idTag= sp_AddTags @createdBy,@tagDescription,@executiveWhoCreatedId, @idSection
        END

        INSERT INTO ToDo (
        atentionDate,
        createdBy,
        executiveWhoCreatedId,
        fromId,
        idSection,
        idTag,
        lastUpdateBy,
        reminderDate,
        tagDescription,
        title,
        toDoNote
    )
    VALUES (
        @atentionDate,
        @createdBy,
        @executiveWhoCreatedId,
        @fromId,
        @idSection,
        @idTag,
        @reminderDate,
        @tagDescription,
        @title,
        @todoNote
    )

END TRY

BEGIN CATCH

  DECLARE @Severity  INT= ERROR_SEVERITY()
    DECLARE @State   SMALLINT = ERROR_SEVERITY()

    DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar en orden para el SP sp_CancelQuoteDocument',@atentionDate,
        @createdBy,
        @executiveWhoCreatedId,
        @fromId,
        @idSection,
        @idTag,
        @reminderDate,
        @tagDescription,
        @title,
        @todoNote);
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
