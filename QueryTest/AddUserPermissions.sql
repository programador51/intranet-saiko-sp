DECLARE @createdBy NVARCHAR(30)= 'Adrian Alardin Iracheta';
DECLARE @arrayNewUuid NVARCHAR(MAX)='100,101,102'
DECLARE @arrayRemoveUuid NVARCHAR(MAX)=''
DECLARE @rolId INT=122;
DECLARE @userId INT=144;


DECLARE @needRemovePermissions TINYINT
DECLARE @tranName NVARCHAR(30)= 'upDatePermissionTran';


DECLARE @ErrorOccurred TINYINT;
DECLARE @Message NVARCHAR (256);
DECLARE @CodeNumber INT;

SELECT 
    @needRemovePermissions=
        CASE
            WHEN (SELECT LEN(@arrayRemoveUuid)) > 0 THEN 1
            ELSE 0
        END



BEGIN TRY
    BEGIN TRANSACTION @tranName
        UPDATE Users SET isPermissionMod=1 WHERE userID=@userId
        INSERT INTO UsersPermissions (
                createdBy,
                createdDate,
                lastUpdatedBy,
                lastUpdatedDate,
                rolId,
                userId,
                uuid,
                [status]

            )
                SELECT 
                    @createdBy,
                    dbo.fn_MexicoLocalTime(GETDATE()),
                    @createdBy,
                    dbo.fn_MexicoLocalTime(GETDATE()),
                    @rolId,
                    @userId,
                    value,
                    1
                FROM STRING_SPLIT(@arrayNewUuid, ',')
                WHERE RTRIM(value)<>''

        IF (@needRemovePermissions=1)
            BEGIN
                DELETE FROM UsersPermissions WHERE uuid IN (
                    SELECT 
                        value
                    FROM STRING_SPLIT(@arrayRemoveUuid, ',')
                    WHERE RTRIM(value)<>''
                )
                IF @@ERROR >0
                    BEGIN 
                        SET @ErrorOccurred= 1 -- Significa que fallo
                        SET @Message='Hubo problemas con la base de datos, no se pudo actualizar los permisos del usuario'
                        SET @CodeNumber= 500
                        ROLLBACK TRANSACTION @tranName
                    END
                ELSE
                    BEGIN
                        SET @ErrorOccurred= 0
                        SET @Message='Permisos actualizados correctamente'
                        SET @CodeNumber= 200
                        COMMIT TRANSACTION @tranName
                    END
            END
        ELSE
            BEGIN 
                IF @@ERROR >0
                    BEGIN 
                        SET @ErrorOccurred= 1 -- Significa que fallo
                        SET @Message='Hubo problemas con la base de datos, no se pudo actualizar los permisos del usuario'
                        SET @CodeNumber= 500
                        ROLLBACK TRANSACTION @tranName
                    END
                ELSE
                    BEGIN
                        SET @ErrorOccurred= 0
                        SET @Message='Permisos actualizados correctamente'
                        SET @CodeNumber= 200
                        COMMIT TRANSACTION @tranName
                    END
                
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
        'Problemas con la Base de datos, no se pudo actualizar los permisos' AS [Message],
        ERROR_NUMBER() AS CodeNumber
END CATCH

SELECT * FROM UsersPermissions ORDER BY id DESC