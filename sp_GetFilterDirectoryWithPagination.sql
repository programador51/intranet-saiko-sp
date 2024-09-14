-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Get the number of rows when filtering the directory
-- in order to calculate the number of pages for the directory

-- STORED PROCEDURE NAME:	sp_GetFilterDirectoryWithPagination
-- STORED PROCEDURE OLD NAME: sp_FilterDirectory_Pagination

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @type: ID of the type of customer to fetch
-- @status: 1 active and 0 inactive customer
-- @executive: ID of the executive that attends the customer
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_GetFilterDirectoryWithPagination](

	@type INT,
	@status TINYINT,
	@executive INT
)

AS BEGIN

SELECT 

Customers.customerID AS ID,
Customers.status AS Estatus_cliente,
Customers.customerType AS Customers_Tipo_Cliente,
Customer_Executive.customerID,
Customer_Executive.executiveID,
Users.userID AS ID_Ejecutivo,
CustomerTypes.customerTypeID AS ID_tipo_cliente
                
FROM Customers 
                
JOIN Customer_Executive ON Customers.customerID = Customer_Executive.customerID
JOIN Users ON Customer_Executive.executiveID = Users.userID
JOIN CustomerTypes on Customers.customerType = CustomerTypes.customerTypeID

WHERE

(Customers.status = @status OR @status IS NULL) AND
(Customer_Executive.executiveID = @executive OR @executive IS NULL) AND
(Customers.customerType = @type OR @type IS NULL)

END