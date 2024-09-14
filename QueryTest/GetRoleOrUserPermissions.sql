DECLARE @idUser INT =20
DECLARE @rolId INT


DECLARE @isMod TINYINT

SELECT 
    @isMod = isPermissionMod,
    @rolId= rol
 FROM Users WHERE userID = @idUser

IF(@isMod = 1)
    BEGIN
        SELECT uuid FROM UsersPermissions WHERE userId= @idUser
    END
ELSE 
    BEGIN
        SELECT uuid FROM RolePermissions WHERE rolId= @rolId
    END

SELECT @isMod AS IsMod, @rolId AS rolID


-- SELECT * FROM Users ORDER BY userID DESC

-- SELECT * FROM Roles ORDER BY rolID DESC

-- SELECT * FROM RolePermissions