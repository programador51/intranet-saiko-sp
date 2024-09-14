-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021
-- Description: When a rol it's created, create all the permissions for that rol (as false)
-- STORED PROCEDURE NAME:	sp_AddPermissionsRol
-- STORED PROCEDURE OLD NAME: sp_CreatePermissionsRol

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @sectionID: ID of the permission
-- @rolID: ID of the rol will have that permissions
-- @createdBy: First name,middle name and lastName1 who created
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddPermissionsRol(

	@sectionID INT,
	@rolID INT,
	@createdBy VARCHAR(50)

)

AS BEGIN

INSERT INTO Permissions 
(
    sectionID,rolID,
    status,createdBy,
    createdDate,lastUpadatedDate,lastUpdatedBy
) 
            
VALUES

(
    @sectionID,@rolID,
    0,@createdBy,
    GETDATE(),GETDATE(),@createdBy
)

END