-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-30-2022
-- Description: Create the role, assign the permissions to tha rol and indicates the child roles it has access
-- STORED PROCEDURE NAME:	sp_AddChildsToParentRole
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
--  @arrayIdChileRoles: Array of the id of the child role
--  @createdBy: The user who create the record
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
--	2022-03-30		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/30/2022
-- Description: sp_AddChildsToParentRole - Add childs to a parent role
CREATE PROCEDURE sp_AddChildsToParentRole(
    @idParentRole INT,
    @arrayIdChileRoles NVARCHAR (MAX),
    @createdBy NVARCHAR (40)

)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    BEGIN TRANSACTION
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
        @idParentRole,
        @createdBy
    FROM STRING_SPLIT(@arrayIdChileRoles, ',')
    WHERE RTRIM(value)<>''
    COMMIT

END