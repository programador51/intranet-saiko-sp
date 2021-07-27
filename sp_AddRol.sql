-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Create a new rol on the system AND get the id of the rol created

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @description: Name will have the rol
-- @status: 1 active and 0 inactive
-- @createdBy: Firstname, middlename and lastname1 of the user who created the rol

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddRol(

	 @description VARCHAR(50),
	 @status TINYINT,
	 @createdBy VARCHAR(30)

)

AS BEGIN

	INSERT INTO Roles 
	(
		description,status,
		createdBy,createdDate,lastUpdatedBy,
		lastUpadatedDate)
    VALUES 
	
	(
        @description, @status,
        @createdBy, GETDATE(), @createdBy,
        GETDATE()
    );
            
    SELECT SCOPE_IDENTITY()

END