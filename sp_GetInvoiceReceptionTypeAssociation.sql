-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 16-02-2022
-- STORED PROCEDURE NAME:	sp_GetInvoiceReceptionTypeAssociation
-- ************************************************************************************************************************
-- Description: Check if the invoice reception was made to associate one or many ODCs or just to associate a concept/egress
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idLegalDocument: Id of the legal document to check
-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
-- ***********************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ========================================================================================================================
--  16-02-2022     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************
CREATE PROCEDURE sp_GetInvoiceReceptionTypeAssociation(@idLegalDocument INT) AS BEGIN
SELECT
    TOP(1) CASE
        WHEN idConcept IS NULL THEN CONVERT(BIT, 0)
        ELSE CONVERT(BIT, 1)
    END AS isConcept
FROM
    LegalDocumentsAssociations
WHERE
    idLegalDocuments = @idLegalDocument;

END