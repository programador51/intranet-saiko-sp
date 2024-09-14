-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-04-2022
-- Description: Update the role description and status, update the childs roles and the permissions
-- STORED PROCEDURE NAME:	sp_UpdateRoleAndPermissions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @createdBy: The user who update the role
-- @rolId: The rol id to be updated
-- @status: The role status
-- @description: The description rol
-- @arrayNewUuid: The new permission added to the role
-- @arrayDeleteUuid: The permission to be deleted
-- @arrayNewIdChileRoles: The new users the role has acces to
-- @arrayDeleteIdChileRoles: The user the rol no more has acces
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @TranName: The trnasition name
-- @trancount: Holds the transactions
-- @ErrorOccurred: Holds the error count (0: No error | >0: Was a error)
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-04-04		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/04/2022
-- Description: sp_UpdateRoleAndPermissions - Update the role description and status, update the childs roles and the permissions
CREATE PROCEDURE sp_UpdateRoleAndPermissions(
    @createdBy NVARCHAR (30),
    @rolId INT,
    @status TINYINT,
    @description NVARCHAR (30),
    @arrayNewUuid NVARCHAR (MAX),
    @arrayDeleteUuid NVARCHAR (MAX),
    @arrayNewIdChileRoles NVARCHAR (MAX),
    @arrayDeleteIdChileRoles NVARCHAR (MAX)
) AS 


   BEGIN TRY
    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @ErrorOccurred TINYINT=0;
    DECLARE @TranName NVARCHAR(30)='UpdateRoleTran';
    DECLARE @trancount  INT
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

-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------
