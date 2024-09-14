-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez
-- Create date: 07-13-2021
-- Description: Update the customer associated with an executive
-- STORED PROCEDURE NAME:	sp_UpdateAssociatedCustomerToExecutive
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idExecutive: The id of the executive to which the customer is associated
-- @pkRow: The primary key of the customer id
-- @lastUpdateBy: The user who updated the record
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns:
-- @message: The result message of the operation
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-07-13		Jose Luis Perez   			1.0.0.0			Initial Revision
--	2021-12-31		Adrian Alardin   			1.0.0.1			It was added the audit records
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateAssociatedCustomerToExecutive(

	@idExecutive INT,
	@pkRow INT,
	@lastUpdateBy NVARCHAR

)

AS BEGIN

	UPDATE Customer_Executive SET 
        executiveID = @idExecutive,
		lastUpdatedBy=@lastUpdateBy,
		lastUpdatedDate= GETDATE()
		WHERE customerExecutiveID = @pkRow 

END