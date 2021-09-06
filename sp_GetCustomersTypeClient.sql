-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-29-2021
-- Description: We obtain all active customers of type client and client / supplier that the signed user has registered.
-- STORED PROCEDURE NAME:	sp_GetCustomersTypeClient
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @userID: The id of the signed user
-- ===================================================================================================================================
-- Returns:
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-07-29		Adrian Alardin   			1.0.0.0			Initial Revision
-- *****************************************************************************************************************************

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetCustomersTypeClient
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
   SELECT 
Customer_Executive.executiveID AS userID,
Customers.customerID AS customerID,
Customers.commercialName AS comertialName,
Customers.customerType AS customerTypeID,
CASE
	WHEN Customers.customerType = 1 THEN 'Cliente'
	WHEN Customers.customerType = 5 THEN 'Cliente/Proveedor'
END AS customerTypeDescription,
Customer_Executive.status AS status
FROM Customer_Executive

JOIN Customers ON Customer_Executive.customerID =Customers.customerID

WHERE (Customer_Executive.executiveID=@userID) AND (Customers.customerType=1 OR Customers.customerType=5) AND Customer_Executive.status=1

END
GO