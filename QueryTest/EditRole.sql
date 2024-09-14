DECLARE @createdBy NVARCHAR(30) = 'Adrian Alardin Iracheta'
DECLARE @rolId INT = 122
DECLARE @status TINYINT = 1
DECLARE @description NVARCHAR(30) = 'Testing Role XX'
DECLARE @arrayNewUuid NVARCHAR(MAX)= '200,201,202'
DECLARE @arrayDeleteUuid NVARCHAR(MAX)= '100,101,103'
DECLARE @arrayNewIdChileRoles NVARCHAR(MAX)= '100,101,103'
DECLARE @arrayDeleteIdChileRoles NVARCHAR(MAX)= '100,101,103'


DECLARE @ErrorOccurred TINYINT=0;
DECLARE @TranName NVARCHAR(30)='UpdateRoleTran';
DECLARE @trancount  INT
SET @trancount= @@TRANCOUNT

--* ---------------------------

BEGIN TRY
    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    SET @trancount= @@TRANCOUNT

    BEGIN TRANSACTION  @TranName 

--* ----------------- ↓↓↓ UPDATE JUST THE ROLE ↓↓↓ -----------------------
    UPDATE Roles
    SET 
        [description]= @description,
        [status]= @status,
        lastUpdatedBy= @createdBy,
        lastUpadatedDate= dbo.fn_MexicoLocalTime(GETDATE())
    WHERE rolId= @rolId
--* ----------------- ↑↑↑ UPDATE JUST THE ROLE ↑↑↑ -----------------------


--* ----------------- ↓↓↓ ASSIGN THE NEW PERMISSIONS ↓↓↓ -----------------------
    INSERT INTO RolePermissions (
    createdBy,
    createdDate,
    lastUpdatedBy,
    lastUpdatedDate,
    rolId,
    uuid,
    [status]
    )

    SELECT 
        @createdBy,
        dbo.fn_MexicoLocalTime(GETDATE()),
        @createdBy,
        dbo.fn_MexicoLocalTime(GETDATE()),
        @rolId,
        value,
        1
    FROM STRING_SPLIT(@arrayNewUuid, ',')
    WHERE RTRIM(value)<>''
--* ----------------- ↑↑↑ ASSIGN THE NEW PERMISSIONS ↑↑↑ -----------------------


--* ----------------- ↓↓↓ ASSIGN THE NEW ROLES THE PARENT HAS ACCESS TO ↓↓↓ -----------------------
    INSERT INTO ParentRoles
        (
        createdBy,
        idChildRole,
        idParentRole,
        lastUpdatedBy
        )
    SELECT
        @createdBy,
        CAST(value AS INT),
        @rolId,
        @createdBy
    FROM STRING_SPLIT(@arrayNewIdChileRoles, ',')
    WHERE RTRIM(value)<>''
--* ----------------- ↑↑↑ ASSIGN THE NEW ROLES THE PARENT HAS ACCESS TO ↑↑↑ -----------------------


--* ----------------- ↓↓↓ DELETE THE ROLE PERMISSIONS  ↓↓↓ -----------------------
        DELETE FROM RolePermissions WHERE uuid IN (
            SELECT 
                value
            FROM STRING_SPLIT(@arrayDeleteUuid, ',')
            WHERE RTRIM(value)<>''
        )
--* ----------------- ↑↑↑ DELETE THE ROLE PERMISSIONS ↑↑↑ -----------------------


--* ----------------- ↓↓↓ DELETE THE CHILDS ROLES  ↓↓↓ -----------------------
        DELETE FROM ParentRoles WHERE idChildRole IN (
            SELECT 
                value
            FROM STRING_SPLIT(@arrayDeleteIdChileRoles, ',')
            WHERE RTRIM(value)<>''
        )
--* ----------------- ↑↑↑ DELETE THE CHILDS ROLES ↑↑↑ -----------------------
IF @@ERROR> 0
                BEGIN
                    SET @ErrorOccurred= 1 -- Significa que fallo
                    ROLLBACK TRANSACTION @TranName
                END
            ELSE
                BEGIN
                    IF @@TRANCOUNT = 0	
                        SET @ErrorOccurred= 0 -- significa que no fallo
                        COMMIT;
                    -- COMMIT TRANSACTION @tranName
                END
             SELECT 
                @ErrorOccurred AS ErrorOccurred,
                CASE 
                    WHEN @ErrorOccurred = 0 THEN 'Rol actualizado correctamente'
                    ELSE 'No se pudo actualizar el rol intente mas tarde'
                END AS [Message],
                CASE 
                    WHEN @ErrorOccurred = 0 THEN 200
                    ELSE 500
                END AS CodeNumber
    END TRY

    BEGIN CATCH
        DECLARE @xstate INT
        SELECT @xstate= XACT_STATE();
            IF @xstate = -1
                ROLLBACK TRANSACTION @TranName;
            IF @xstate = 1 and @trancount = 0
                ROLLBACK TRANSACTION @TranName
            IF @xstate = 1 and @trancount > 0
                ROLLBACK TRANSACTION @TranName

        IF @@ERROR> 0
            BEGIN
                SET @ErrorOccurred= 1 -- Significa que fallo
                ROLLBACK TRANSACTION @TranName
            END
        SELECT 
                @ErrorOccurred AS ErrorOccurred,
                CASE 
                    WHEN @ErrorOccurred = 0 THEN 'Rol actualizado correctamente'
                    ELSE 'Problemas con la base de datos, no se pudo actualizar el rol'
                END AS [Message],
                CASE 
                    WHEN @ErrorOccurred = 0 THEN 200
                    ELSE 500
                END AS CodeNumber 
    END CATCH



-- DELETE FROM RolePermissions WHERE uuid IN ('100','101','103')

SELECT * FROM RolePermissions ORDER BY id DESC
SELECT * FROM Roles ORDER BY rolID DESC
SELECT * FROM ParentRoles ORDER BY id DESC