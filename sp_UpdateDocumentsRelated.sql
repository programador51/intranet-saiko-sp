-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 10-09-2021

-- Description: Update the documents that are related with an specific document

-- ===================================================================================================================================
-- PARAMETERS:
-- @mizarNumber: Mizar number that gives when it's invoiced
-- @idContract: ID of the contract related with
-- @idQuotation: ID of the quote related with
-- @idInvoice: ID of the pre-invoice related with
-- @idOC: ID of the OC related with
-- @idDocument: Id of the document to updated

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  10-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateDocumentsRelated(
    @mizarNumber NVARCHAR(256),
    @idContract INT,
    @idQuote INT,
    @idPreinvoice INT,
    @idOC INT,
    @idDocument INT
)

AS BEGIN

    UPDATE Documents SET	
        invoiceMizarNumber = @mizarNumber,
        idContract = @idContract,
        idQuotation = @idQuote,
        idInvoice = @idPreinvoice,
        idOC = @idOc

    WHERE idDocument = @idDocument

END