DECLARE @fix DECIMAL (14,4) = 29.29;
DECLARE @dof FLOAT = 29.29
DECLARE @pays FLOAT = 29.29
DECLARE @purchase FLOAT = 29.29
DECLARE @sales FLOAT = 29.29
DECLARE @saiko FLOAT = 29.29

DECLARE @tranName NVARCHAR(30) ='AddTC';
DECLARE @idNoteCondition INT;

DECLARE @ErrorOccurred TINYINT;
DECLARE @Message NVARCHAR (256);
DECLARE @CodeNumber INT;

BEGIN TRY
    BEGIN TRANSACTION @tranName

    INSERT INTO TCP (
        [date],
        fix,
        DOF,
        pays,
        purchase,
        sales,
        saiko

    )
    VALUES (
        dbo.fn_MexicoLocalTime(GETDATE()),
        @fix,
        @dof,
        @pays,
        @purchase,
        @sales,
        @saiko
    )

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