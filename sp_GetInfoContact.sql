/****** Object:  StoredProcedure [dbo].[sp_GetContacts]    Script Date: 7/2/2021 12:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--
--	STORED PROCEDURE NAME:	sp_GetContacts  
--
--	DESCRIPTION:			This SP retrieves the contacts for a given status
--
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-06-29		Iván Díaz   				1.0.0.0			Initial Revision		
-- **************************************************************************************************************************************************

ALTER PROCEDURE [dbo].[sp_GetContacts]
	@status	TINYINT = 3 
	
	
AS
BEGIN
-- **************************************************************************************************************************************************                    
-- RETURN DATA                   
-- **************************************************************************************************************************************************                    

IF @status = 3
	BEGIN
		SELECT	contactID,
				firstName,
				middleName,
				lastName1,
				lastName2,
				phoneNumberAreaCode,
				phoneNumber,
				cellNumberAreaCode,
				cellNumber,
				email,
				position,
				[status],
				CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
				CONCAT(phoneNumberAreaCode,' ',phoneNumber) AS phone,
				CONCAT(cellNumberAreaCode, ' ',cellNumber)AS cellPhone
        FROM Contacts
	END
ELSE
	BEGIN
		SELECT	contactID,
				firstName,
				middleName,
				lastName1,
				lastName2,
				phoneNumberAreaCode,
				phoneNumber,
				cellNumberAreaCode,
				cellNumber,
				email,
				position,
				[status],
				CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
				CONCAT(phoneNumberAreaCode,' ',phoneNumber) AS phone,
				CONCAT(cellNumberAreaCode, ' ',cellNumber)AS cellPhone
        FROM Contacts 
		WHERE [status] = @status
	END

END
