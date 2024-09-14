
-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 11-10-2021
-- Description: Get the comments made to an uploaded file to a document
-- STORED PROCEDURE NAME:	sp_GetFileComments
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @idFile: Id of the file to look for his comments

-- *******************************************************************************************************************************
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	11-10-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_GetFileComments(
    @idFile INT
)

AS BEGIN

    SELECT
        documentId AS id,
        createdBy AS commentedBy,
        createdDate AS commentedDate,
        comment AS comment

    FROM Commentation

    WHERE 
        documentId = @idFile AND commentTypeId = 4

    ORDER BY createdDate DESC;

END