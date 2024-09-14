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
--  12-02-2021     Adrian Alardin              1.0.0.1         Added the auditory records		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateDocumentNoNumber(
    @idDocument INT,
    @numberDocument INT,
    @modifyBy NVARCHAR (30)
)

AS BEGIN

UPDATE Documents SET
    documentNumber = @numberDocument,
    lastUpdatedBy = @modifyBy,
    lastUpdatedDate = GETDATE()
WHERE idDocument = @idDocument

END