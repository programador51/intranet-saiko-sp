-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 05-10-2021
-- Description: Get the files associated to an specific document
-- STORED PROCEDURE NAME:	sp_GetFilesNoRegisters
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: Id of the document
-- @sinceRegister: Since which no. register start returning the rows
-- @limitRegister: How much rows take from the query

-- *******************************************************************************************************************************
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	05-10-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_GetFiles(
    @idDocument INT,
    @sinceRegister INT,
    @limitRegisters INT
)

AS BEGIN

    SET LANGUAGE Spanish;

    SELECT

        AssociatedFiles.id AS id,
        FORMAT(AssociatedFiles.associatedDate,'yyyy-MM-dd') AS [associatedDate.yyyymmdd],
        REPLACE(CONVERT(VARCHAR(10),AssociatedFiles.associatedDate,6),' ','/') AS [associatedDate.parsed],
        REPLACE(CONVERT(VARCHAR(10),AssociatedFiles.associatedDate,6),' ','/') AS createdDate,
        AssociatedFiles.createdBy AS createdBy,
        AssociatedFiles.fileName AS fileName,
        AssociatedFiles.typeFile AS extension,
        AssociatedFiles.urlBlob AS source,
		CONVERT(BIT,AssociatedFiles.status) AS isActive,
		CASE
            WHEN
                AssociatedFiles.status = 1
                THEN 'Disponible'

            ELSE
                'Borrado' END AS isActiveText

    FROM AssociatedFiles

    WHERE AssociatedFiles.idDocument = @idDocument

    ORDER BY id DESC

    OFFSET @sinceRegister ROWS 
    FETCH NEXT @limitRegisters ROWS ONLY

    FOR JSON PATH, ROOT('files'), INCLUDE_NULL_VALUES;

END

-- EXPECTED RESULT IF QUERY SUCCESS
-- "files": [
-- {
--     "id": 4,
--     "associatedDate": {
--         "yyyymmdd": "2021-10-05",
--         "parsed": "05/Oct/21"
--     },
--     "createdDate": "05/Oct/21",
--     "createdBy": "Jose Luis Perez Olguin",
--     "fileName": "prueba",
--     "extension": "png",
--     "source": "https://www.fobiass.com/images/claustrofobia-test1.jpg"
-- },
-- {
--     "id": 3,
--     "associatedDate": {
--         "yyyymmdd": "2021-10-05",
--         "parsed": "05/Oct/21"
--     },
--     "createdDate": "05/Oct/21",
--     "createdBy": "Jose Luis Perez Olguin",
--     "fileName": "testprueba",
--     "extension": "png",
--     "source": "https://citizengo.org/sites/default/files/images/test_3.png"
-- },
-- {
--     "id": 1,
--     "associatedDate": {
--         "yyyymmdd": "2021-10-05",
--         "parsed": "05/Oct/21"
--     },
--     "createdDate": "05/Oct/21",
--     "createdBy": "Jose Luis Perez Olguin",
--     "fileName": "testprueba",
--     "extension": "png",
--     "source": "https://citizengo.org/sites/default/files/images/test_3.png"
-- }
-- ]
-- }