-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 25-11-2021
-- ************************************************************************************************************************
-- Description: Check if the email it's already in use by another customer
-- ************************************************************************************************************************
-- PARAMETERS:
-- @email: The email to check if it's already in use
-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
 -- ***********************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  25-11-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************

CREATE PROCEDURE sp_GetEmailDirectory(
    @emailToCheck NVARCHAR(30)
)

AS BEGIN

    DECLARE @email NVARCHAR(30);

    SELECT @email = email FROM Customers WHERE email = @emailToCheck;

    SET @email = ISNULL(DATALENGTH(@email) - DATALENGTH(@email) + 1,0);

    SELECT CONVERT(BIT,@email) AS emailRepeated;

END