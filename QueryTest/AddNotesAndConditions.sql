-- * VARIABLES GLOBALES
DECLARE @type INT = 1
DECLARE @documentTypeIdArray NVARCHAR(MAX) = '1,2,6'
DECLARE @createdBy NVARCHAR (30)= 'Adrian Alardin Iracheta'
DECLARE @currency NVARCHAR(3) =  'USD'
DECLARE @content NVARCHAR (256) = 'Esto es la prueba de un mensaje generico'
DECLARE @isDelatable TINYINT = 1
DECLARE @isEditable TINYINT = 1
DECLARE @uen INT; -- De momento va ser nula.

-- ? VARIABLES LOCALES
DECLARE @tranName NVARCHAR(30) ='GenericNotes';
DECLARE @idNoteCondition INT;

DECLARE @ErrorOccurred TINYINT;
DECLARE @Message NVARCHAR (256);
DECLARE @CodeNumber INT;

BEGIN TRY
    BEGIN TRANSACTION @tranName
        INSERT INTO NoteAndCondition (
            content,
            createdBy,
            currency,
            isDelatable,
            isEditable,
            lastUpdatedBy,
            [type],
            uen
        )
        VALUES (
            @content,
            @createdBy,
            @currency,
            @isDelatable,
            @isEditable,
            @createdBy,
            @type,
            @uen
        )

    SELECT @idNoteCondition= SCOPE_IDENTITY()

    INSERT INTO NoteAndConditionToDocType (
        createdBy,
        idDocumentType,
        idNoteAndCondition,
        lastUpdatedBy
    )
        SELECT
            @createdBy,
            value,
            @idNoteCondition,
            @createdBy
        FROM STRING_SPLIT(@documentTypeIdArray, ',')
        WHERE RTRIM(value)<>''

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
            SET @Message='Registros insertados correctamente'
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

SELECT * FROM NoteAndCondition
SELECT * FROM NoteAndConditionToDocType