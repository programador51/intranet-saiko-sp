-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-24-2021
-- Description: We obtain the customer by his type, depending of the executive signed
-- STORED PROCEDURE NAME:	sp_GetMyCustomersByClientType
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- Returns:
-- The executive id, customer id, his comertial name, his type, status
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-09-24		Adrian Alardin   			1.0.0.0			Initial Revision
-- *****************************************************************************************************************************

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetMyCustomersByClientType
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    SET LANGUAGE Spanish;

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
    WHERE (Customer_Executive.executiveID=@userID) AND (Customers.customerType=1 OR Customers.customerType=5) AND Customers.status=1

END
GO