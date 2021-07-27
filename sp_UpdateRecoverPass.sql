-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Set the new password that the user typed after
-- confirming his identity

-- STORED PROCEDURE NAME:	sp_UpdateRecoverPass
-- STORED PROCEDURE OLD NAME: sp_RecoverPass

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @password_front: New password the user will use
-- @userName: user name or email which will be applied this new password.
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateRecoverPass(

	@password_front NVARCHAR(300),
	@userName NVARCHAR(50)

)

AS BEGIN

UPDATE Users 
	SET 
		password = @password_front, 
		temporalPassword = NULL 
	
	WHERE 
		userName = @userName OR 
		email = @userName

END