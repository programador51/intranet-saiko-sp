-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 01-11-2021

-- Description: Validate that the customer has a value on the column "mizarId" that means the customer
-- is already sync with the web service to create an invoice.

-- STORED PROCEDURE NAME:	sp_GetIsCustomerSync
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @idCustomer: Id of the customer to validate it's sync
-- *******************************************************************************************************************************
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	01-11-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_GetIsCustomerSync(
    @idCustomer INT
)

AS BEGIN

    DECLARE @idProviderInvoice NVARCHAR(50);

    SELECT @idProviderInvoice = mizarId FROM Customers WHERE customerID = @idCustomer;

    SELECT 
      CASE
        WHEN @idProviderInvoice IS NULL THEN CONVERT(BIT,0)
        ELSE CONVERT(BIT,1)
		END AS isSync,

		@idProviderInvoice AS idFacturama;

END