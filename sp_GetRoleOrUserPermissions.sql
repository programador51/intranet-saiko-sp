-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-05-2022
-- Description: Obtains the permissions of the role or the user depending on whether the user is a mod 
-- STORED PROCEDURE NAME:	sp_GetRoleOrUserPermissions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-04-05		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/05/2022
-- Description: sp_GetRoleOrUserPermissions - Obtains the permissions of the role or the user depending on whether the user is a mod
CREATE PROCEDURE sp_GetRoleOrUserPermissions(
    @idUser INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
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

END