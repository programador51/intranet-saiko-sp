DECLARE @userID INT = 144 -- rol 122
DECLARE @isMod TINYINT;
DECLARE @updateBy NVARCHAR(30);

DECLARE @TranName NVARCHAR(30)= 'resetPermissions';

BEGIN TRY
    BEGIN TRANSACTION @TranName
    SELECT @isMod= isPermissionMod  FROM Users

    IF @isMod = 1
        BEGIN
            UPDATE Users
                SET lastUpdatedBy= @updateBy,
                isPermissionMod=0
            DELETE FROM UsersPermissions WHERE userId=@userID
            
            IF @@ERROR > 0
                BEGIN
                    ROLLBACK TRANSACTION @TranName
                END
            ELSE 
                BEGIN 
                    SELECT 
                        1 AS ErrorOccurred, 
                        'Los permisos del usuario se han actualizado' AS [Message],
                        200 AS CodeNumber
                        COMMIT TRANSACTION @TranName
                END
        END
    ELSE
        BEGIN
            SELECT 
                1 AS ErrorOccurred, 
                'El usuario no tiene permisos espicales del rol' AS [Message],
                400 AS CodeNumber
        END
END TRY

BEGIN CATCH

    IF (XACT_STATE()= -1)
        BEGIN
            ROLLBACK TRANSACTION @TranName
        END
    IF (XACT_STATE()=1)
        BEGIN
            COMMIT TRANSACTION @TranName
        END

    IF @@TRANCOUNT > 0  
        BEGIN
            ROLLBACK TRANSACTION;   
        END
    SELECT 
        1 AS ErrorOccurred, 
        'Problemas con la Base de datos, no se pudo asignar los permisos' AS [Message],
        ERROR_NUMBER() AS CodeNumber

END CATCH
