-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--  Test
--  STORED PROCEDURE OLD NAME: sp_AssignFilterUsersToRol
--	STORED PROCEDURE NAME:	sp_AddFilterUsersToRol 
--
--	DESCRIPTION:			When add a new rol, set which executives can filter the rol on searchs related with executives
--
--
-- **************************************************************************************************************************************************
-- 
-- PARAMETERS:
-- @rolID - ID of the rol that was added 
-- @userID - ID of the executive(s) that can filter by
-- @createdBy - Name, middlename and 1st last name who performed this action

-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-06-09		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-21      Jose Luis                   1.0.0.1         Documentation and update name of sp		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddFilterUsersToRol(

@rolID INT,
@userID INT,
@createdBy VARCHAR(30)

)

AS BEGIN

INSERT INTO AssociatedUsers

(
    rolID,status,createdBy,
    createdDate,lastUpdatedBy,lastUpadatedDate,
    userID
)
            
VALUES

(
    @rolID,1,@createdBy,
    GETDATE(),@createdBy,GETDATE(),
    @userID
)

END