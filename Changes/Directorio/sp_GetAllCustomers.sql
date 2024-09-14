-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-21-2024
-- Description: Get the directory of customers
-- STORED PROCEDURE NAME:	sp_GetAllCustomers
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- The directory of customers
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-05-21		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetAllCustomers')
    BEGIN 

        DROP PROCEDURE sp_GetAllCustomers;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/21/2024
-- Description: sp_GetAllCustomers - Get the directory of customers
CREATE PROCEDURE sp_GetAllCustomers AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    SELECT 
        customers.customerID AS idCustomer,
        customers.socialReason AS socialReason,
        customers.rfc AS rfc,
        customerType.[description] AS customerType
    FROM Customers AS customers
    LEFT JOIN CustomerTypes AS customerType ON customers.customerType = customerType.customerTypeID
    ORDER BY 
        customerType.customerTypeID,
        customers.socialReason;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------

