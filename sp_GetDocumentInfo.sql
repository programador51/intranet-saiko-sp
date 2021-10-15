-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 14-10-2021
-- ************************************************************************************************************************
-- Description: Get the number documents related to a document and the number of files associated to that document
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: Id of the document to query the number documents related to it

-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
 -- ************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  14-10-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************

CREATE PROCEDURE sp_GetDocumentInfo(
    @idDocument INT
)

AS BEGIN

    exec sp_GetDocumentNumbers @idDocument;

    SELECT COUNT(*) AS noFiles FROM AssociatedFiles WHERE idDocument = @idDocument;

END