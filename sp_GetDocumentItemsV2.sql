-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 25-10-2021
-- ************************************************************************************************************************
-- Description: Get the document items of a document
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: Id of the document to query the number documents related to it

-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
 -- ************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  25-10-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************

CREATE PROCEDURE sp_GetDocumentItemsV2(
    @idDocument INT
)

AS BEGIN

    DECLARE @idTypeDocument INT;
    DECLARE @idQuote INT;

    SET @idTypeDocument = (SELECT
            idTypeDocument AS idTypeDocument

        FROM Documents

        WHERE idDocument = @idDocument);

    SET @idQuote = (SELECT
            idQuotation AS idQuote

        FROM Documents

        WHERE idDocument = @idDocument);



    SELECT @idTypeDocument AS idTypeDocument , @idQuote AS idQuote;

    IF @idTypeDocument = 2 OR @idTypeDocument = 6
    BEGIN
        exec sp_GetDocumentItems @idQuote;
    END

    BEGIN
        exec sp_GetDocumentItems @idDocument;
    END

END