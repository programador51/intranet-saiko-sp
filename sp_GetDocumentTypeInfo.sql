-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 25-11-2021
-- ************************************************************************************************************************
-- Description: Get the type document information of the requested document
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: Id of the document to get the type information
-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
 -- ***********************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  25-11-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************

CREATE PROCEDURE sp_GetDocumentTypeInfo(
    @idDocument INT
)

AS BEGIN

    SELECT 

        Documents.idDocument AS id,
        Documents.documentNumber AS number,
        Documents.idTypeDocument AS [typeDocument.id],
        DocumentTypes.description AS [typeDocument.description]
        
    FROM Documents

    LEFT JOIN DocumentTypes ON Documents.idTypeDocument = DocumentTypes.documentTypeID

    WHERE Documents.idDocument = @idDocument

    FOR JSON PATH, ROOT('docInfo'), INCLUDE_NULL_VALUES

END

---------------------------------------- RESULT ----------------------------------------

-- {
--     "id": 1421,
--     "number": 17,
--     "typeDocument": {
--         "id": 1,
--         "description": "Cotización"
--     }
-- }

---------------------------------------- OR ----------------------------------------

-- {
--     "id": null,
--     "number": null,
--     "typeDocument": {
--         "id": null,
--         "description": null
--     }
-- }

-- On both cases, the object structure must be there even with null values