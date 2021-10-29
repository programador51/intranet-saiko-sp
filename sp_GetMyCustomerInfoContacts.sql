-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-29-2021
-- Description: We obtain all active contacts the customer has
-- STORED PROCEDURE NAME:	sp_GetMyCustomerInfoContacts
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @userID: The id of the signed user
-- ===================================================================================================================================
-- Returns:
-- fullName
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ========================================================================================================================================
--	2021-07-30		Adrian Alardin   			1.0.0.0			Initial Revision
..	2021-10-29		Iván Díaz				1.0.0.1			JOIN nor required
-- *****************************************************************************************************************************

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetMyCustomerInfoContacts(
    @customerID INT
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
   SELECT
	contactID,
	customerID,
	firstName,
	middleName,
	lastName1,
	lastName2,
	CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
	[status]
FROM Contacts
--JOIN Customers ON Contacts.customerID= Customers.customerID     --1.0.0.1	
WHERE Contacts.customerID=@customerID AND Contacts.status=1	

END
GO
