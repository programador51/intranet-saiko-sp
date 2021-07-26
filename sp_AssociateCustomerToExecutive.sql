-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021
-- Description: When adds a new customer, associate an executive with that customer created
-- STORED PROCEDURE NAME:	sp_AddCustomerToExecutive
-- STORED PROCEDURE OLD NAME: sp_AssociateCustomerToExecutive
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerID: Is the id of the customer that is associated with
-- @executiveID: ID of the executive who attends
-- @status: 1 active 0 inactive
-- @createdBy: First name,middle name and lastName1 who created made the relation
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddCustomerToExecutive(

	@customerID INT,
	@executiveID INT,
	@status TINYINT,
	@createdBy NVARCHAR(30)

)

AS BEGIN

	INSERT INTO Customer_Executive
        (
            customerID,executiveID,status,
            createdBy,createdDate,lastUpdatedBy,
            lastUpdatedDate
        )
        
        VALUES

        (
            @customerID,@executiveID,@status,
            @createdBy,GETDATE(),@createdBy,
            GETDATE()
        )

END