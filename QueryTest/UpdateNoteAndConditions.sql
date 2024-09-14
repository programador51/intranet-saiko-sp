-- * VARIABLES GLOBALES
DECLARE @idNote INT=4
DECLARE @type INT = 1
DECLARE @documentTypeIdArrayToAdd NVARCHAR(MAX);
DECLARE @documentTypeIdArrayToRemove NVARCHAR(MAX)= '3'
DECLARE @updatedBy NVARCHAR (30)= 'Adrian Alardin Iracheta'
DECLARE @currency NVARCHAR(3) =  'USD'
DECLARE @content NVARCHAR (256) = 'Esto es la prueba de actualizar un mensaje generico'
DECLARE @isDelatable TINYINT = 1
DECLARE @isEditable TINYINT = 1
DECLARE @isActive TINYINT =1
DECLARE @uen INT; -- De momento va ser nula.

-- ? VARIABLES LOCALES
DECLARE @tranName NVARCHAR(30) ='UpdateGenericNotes';
DECLARE @ErrorOccurred TINYINT;
DECLARE @Message NVARCHAR (256);
DECLARE @CodeNumber INT;


DECLARE @toAddLength INT;
DECLARE @toRemoveLength INT;

BEGIN TRY
    BEGIN TRANSACTION @tranName

    SELECT @toAddLength= LEN(@documentTypeIdArrayToAdd)
    SELECT @toRemoveLength= LEN(@documentTypeIdArrayToRemove)


    UPDATE NoteAndCondition SET 
        content=@content,
        currency=@currency,
        isDelatable=@isDelatable,
        isEditable=@isEditable,
        lastUpdatedBy=@updatedBy,
        lastUpdatedDate= dbo.fn_MexicoLocalTime(GETDATE()),
        [status]=@isActive,
        [type]=@type,
        uen= @uen
    WHERE id=@idNote

    IF @toAddLength > 0
        BEGIN
             INSERT INTO NoteAndConditionToDocType (
                createdBy,
                idDocumentType,
                idNoteAndCondition,
                lastUpdatedBy,
                lastUpdatedDate
            )
                SELECT
                    @updatedBy,
                    value,
                    @idNote,
                    @updatedBy,
                    dbo.fn_MexicoLocalTime(GETDATE())
                FROM STRING_SPLIT(@documentTypeIdArrayToAdd, ',')
                WHERE RTRIM(value)<>''
        END
    IF @toRemoveLength > 0
        BEGIN
            DELETE FROM NoteAndConditionToDocType 
            WHERE (idNoteAndCondition= @idNote AND 
            idDocumentType IN (
                SELECT
                    value
                FROM STRING_SPLIT(@documentTypeIdArrayToRemove, ',')
                WHERE RTRIM(value)<>''
                    
                    ))
        END

    IF @@ERROR <>0
        BEGIN
            SET @ErrorOccurred= 1 -- Significa que fallo
            SELECT @Message= text FROM sys.messages WHERE message_id=@@ERROR
            SET @CodeNumber= @@ERROR
            ROLLBACK TRANSACTION @tranName
        END
    ELSE
        BEGIN
            SET @ErrorOccurred= 0
            SET @Message='Registros actualizados correctamente'
            SET @CodeNumber= 200
            COMMIT TRANSACTION @tranName
        END

    SELECT @ErrorOccurred AS ErrorOccurred, @Message AS [Message], @CodeNumber AS CodeNumber


END TRY

BEGIN CATCH
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
    SELECT 
        1 AS ErrorOccurred, 
        'Problemas con la Base de datos, no se pudo insertar los registros' AS [Message],
        ERROR_NUMBER() AS CodeNumber
END CATCH

-- SELECT * FROM NoteAndCondition
-- SELECT * FROM NoteAndConditionToDocType