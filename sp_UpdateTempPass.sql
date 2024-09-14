-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 10-09-2021
-- STORED PROCEDURE NAME:	sp_UpdateTempPass
-- Description: Update the temporal password
-- ===================================================================================================================================
-- PARAMETERS:
-- @temp_password: The temporal password
-- @user: The user
-- @modifyBy: Last updated by
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  07-13-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
--  12-02-2021     Adrian Alardin              1.0.0.1         Added the auditory records		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateTempPass(
	@temp_password NVARCHAR(300),
	@user NVARCHAR(50),
	@modifyBy NVARCHAR (30)
) AS BEGIN
UPDATE
	Users
SET
	temporalPassword = @temp_password,
	lastUpdatedBy = @modifyBy,
	lastUpdatedDate = GETDATE()
WHERE
	userName = @user
	OR email = @user
END