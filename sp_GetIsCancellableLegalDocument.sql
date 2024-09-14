-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 16-02-2022
-- STORED PROCEDURE NAME:	sp_GetIsCancellableLegalDocument
-- ************************************************************************************************************************
-- Description: Check if the document attempt to be cancelled can be done, that means...
--- * An executive havent cancelled before
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idLegalDocument: Id of the legal document to cancel
-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
-- ***********************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ========================================================================================================================
--  16-02-2022     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************
CREATE PROCEDURE sp_GetIsCancellableLegalDocument(@idLegalDocument INT) AS BEGIN
SELECT
    CASE
        WHEN idLegalDocumentStatus = 5 THEN CONVERT(BIT, 0)
        ELSE CONVERT(BIT, 1)
    END AS isCancellable
FROM
    LegalDocuments
WHERE
    id = @idLegalDocument;

END