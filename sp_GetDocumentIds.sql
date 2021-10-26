-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 25-10-2021
-- ************************************************************************************************************************
-- Description: Get the ids of the documents related to it
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: Id of the document to fetch his related id documents

-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
 -- ************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  25-10-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************

CREATE PROCEDURE sp_GetDocumentIds(
    @idDocument INT
)

AS BEGIN

    SELECT
        idContract AS idContract,
        idQuotation AS idQuote,
        idInvoice AS idPreinvoice,
        idOC AS idOc,
        invoiceMizarNumber AS idMizar,
        idTypeDocument AS idTypeDocument

    FROM Documents

    WHERE idDocument = @idDocument

END