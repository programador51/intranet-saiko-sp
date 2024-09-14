-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-10-2022
-- Description: Create the role, assign the permissions to tha rol and indicates the child roles it has access
-- STORED PROCEDURE NAME:	sp_AddRoleAndPermissions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ? ADD ROLE
-- @description: Name will have the rol
-- @status: Status (1:Active | 0:Inactive)
-- @createdBy: The user who create the record

-- ? ADD ROLE PERMISSIONS
-- @arrayUuid: The id of the permission to which the role has access

-- ? ADD CHILDS TO PARENT ROLE
--  @arrayIdChileRoles: Array of the id of the child role
--  @idParentRole: Id of the parent role that has access to its children
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
--	2022-02-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/10/2022
-- Description: sp_AddRoleAndPermissions - Create the role, assign the permissions to tha rol and indicates the child roles it has access
CREATE PROCEDURE sp_AddRoleAndPermissions(
    @description VARCHAR(50),
    @status TINYINT,
    @createdBy VARCHAR(30),
    @arrayUuid NVARCHAR(MAX),
    @arrayIdChileRoles NVARCHAR (MAX)
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    BEGIN TRANSACTION
    DECLARE @rolIdCreated INT
    
    EXEC sp_AddRol @description,@status,@createdBy,@rolIdCreated OUTPUT
    
    EXEC sp_AddRolePermissions @createdBy, @rolIdCreated, @status, @arrayUuid
    EXEC sp_AddChildsToParentRole @rolIdCreated, @arrayIdChileRoles, @createdBy
    

    COMMIT

END