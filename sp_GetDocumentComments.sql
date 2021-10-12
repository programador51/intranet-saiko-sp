-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 06-09-2021

-- Description: Get the comments made to an specific document with his ID

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  06-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
--  11-10-2021     Jose Luis Perez             2.0.0.0         Comments are saved on table 'Commentation'		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetDocumentComments(
    @idDocument INT
)

AS BEGIN

    SELECT 
          commentId AS id,
          comment AS name,
          documentId AS idDocument,
          [order],
          CONVERT(BIT,0) AS isNewComment 

    FROM Commentation

    WHERE
        documentId = @idDocument AND
        status = 1

    ORDER BY 'order' ASC;

END