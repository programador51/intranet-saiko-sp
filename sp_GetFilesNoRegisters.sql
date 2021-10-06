-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 05-10-2021
-- Description: Get the numbers of registers that exist according to the idDocument, it workds to paginate the data on the UI
-- STORED PROCEDURE NAME:	sp_GetFilesNoRegisters
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: Id of the document to fetch the overview info of the label

-- *******************************************************************************************************************************
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	05-10-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_GetFilesNoRegisters(
    @idDocument INT
)

AS BEGIN

    SELECT COUNT(*) AS noRegisters FROM AssociatedFiles WHERE idDocument = @idDocument;

END