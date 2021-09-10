-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 10-09-2021

-- Description: Update the numberDocument of an specific document
-- this it's used when a quote have just won because other documents are created
-- and they depend each other to fill the data

-- ===================================================================================================================================
-- PARAMETERS:
-- @idDocument: ID of the document to edit
-- @numberDocument: Number of document to use. Must be the number incremented of the last
-- document number founded of that kind

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  10-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateDocumentNoNumber(
    @idDocument INT,
    @numberDocument INT
)

AS BEGIN

UPDATE Documents SET
    documentNumber = @numberDocument
WHERE idDocument = @idDocument

END