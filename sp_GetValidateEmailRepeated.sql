-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Use to validate an email it's NOT REPATED when the executive
-- attempts to update another executive

-- STORED PROCEDURE NAME:	sp_GetValidateEmailRepeated
-- STORED PROCEDURE OLD NAME: sp_ValidateEmailRepeated

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @newEmail: Email that the executive attempts to use
-- @userEditing: ID of the user which it's being edited
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetValidateEmailRepeated(

	@newEmail NVARCHAR(50),
	@userEditing INT

)

AS BEGIN

	SELECT email 
		FROM Users 
    
		WHERE 
			email = @newEmail
            AND userID != @userEditing

END