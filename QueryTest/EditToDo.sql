
DECLARE @toDoId INT;
DECLARE @idTag INT
DECLARE @tagDescription NVARCHAR(30);
DECLARE @reminderDate DATETIME;
DECLARE @atentionDate DATETIME;
DECLARE @title NVARCHAR(128);
DECLARE @todoNote NVARCHAR(256);
DECLARE @executiveWhoCreatedId INT;
DECLARE @lastUpdateBy NVARCHAR(30);
DECLARE @idSection INT;

DECLARE @tranName NVARCHAR(30)= 'editTodo'
DECLARE @Message NVARCHAR(MAX);

BEGIN TRY

    BEGIN TRANSACTION @tranName
    IF (@idTag=-1)
        BEGIN
        -- it measn the tag is new
        EXEC @idTag= sp_AddTags @lastUpdateBy,@tagDescription,@executiveWhoCreatedId, @idSection
        END

    IF (@idSection=4)
        BEGIN
            UPDATE ToDo SET 
            idTag=@idTag,
            title=@title,
            tagDescription= @tagDescription,
            reminderDate= @reminderDate,
            atentionDate= @atentionDate,
            toDoNote= @todoNote,
            lastUpdateBy= @lastUpdateBy,
            lastUpdateDate= dbo.fn_MexicoLocalTime(GETDATE())

            WHERE id= @toDoId
        END
    ELSE
        BEGIN
            UPDATE ToDo SET 
                idTag=@idTag,
                tagDescription= @tagDescription,
                reminderDate= @reminderDate,
                atentionDate= @atentionDate,
                toDoNote= @todoNote,
                lastUpdateBy= @lastUpdateBy,
                lastUpdateDate= dbo.fn_MexicoLocalTime(GETDATE())

                WHERE id= @toDoId
        END
    

    COMMIT TRANSACTION @tranName

END TRY

BEGIN CATCH

  DECLARE @Severity  INT= ERROR_SEVERITY()
    DECLARE @State   SMALLINT = ERROR_SEVERITY()

    DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_CancelQuoteDocument ,@atentionDate,
        @lastUpdateBy,
        @idTag,
        @reminderDate,
        @tagDescription,
        @todoNote';
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
    EXEC sp_AddLog @lastUpdateBy,@infoSended,@Message,@Message,@wasAnError,@mustBeSyncManually,@provider;
END CATCH


