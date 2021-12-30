-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 30-12-2021
-- Description: Update the pay method, pay form and cfdi to use on the invoice 
-- STORED PROCEDURE NAME:	sp_UpdateInvoicePays
-- ===============================================================================================================================
-- PARAMETERS:
-- @idCfdi: Id of the cfdi to use when update
-- @idPaymethod: Id of the pay method to use when update
-- @idPayform: Id of the pay form to use when update
-- @idDocument: Id of the document (invoice) to uodate
-- ===============================================================================================================================
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ===============================================================================================================================
--	30-12-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************
CREATE PROCEDURE sp_UpdateInvoicePays(
    @idCfdi INT,
    @idPaymethod INT,
    @idPayform INT,
    @idDocument INT
)

AS
BEGIN

    UPDATE Documents SET idCfdi = @idCfdi , idPaymentForm = @idPayform , idPaymentMethod = @idPaymethod WHERE idDocument = @idDocument;

END