-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-30-2022
-- Description: Add the permissions to te role
-- STORED PROCEDURE NAME:	sp_AddRolePermissions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @createdBy: The user who create the record
-- @rolId: The rol id
-- @status: Status (1:Active | 0:Inactive)
-- @arrayUuid: The id of the permission to which the role has access
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
--	2022-03-30		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/30/2022
-- Description: sp_AddRolePermissions -  Add the permissions to te role
CREATE PROCEDURE sp_AddRolePermissions(
    @createdBy NVARCHAR(30),
    @rolId INT ,
    @status TINYINT ,
    @arrayUuid NVARCHAR(MAX)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    BEGIN TRANSACTION
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
        FROM STRING_SPLIT(@arrayUuid, ',')
        WHERE RTRIM(value)<>''
COMMIT

END