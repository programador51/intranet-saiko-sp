-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 08-10-2021
-- Description: Delete the file from database (change status column to 0)
-- STORED PROCEDURE NAME:	sp_DeleteFile
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @idFile: Id of the file
-- @editedBy: Name executive who performed the delete

-- *******************************************************************************************************************************
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	08-10-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision

CREATE PROCEDURE sp_DeleteFile(
    @idFile INT,
    @editedBy NVARCHAR(30)
)

AS BEGIN

    UPDATE AssociatedFiles

    SET 
        status = 0,
        editedDate = GETDATE(),
        editedBy = @editedBy

    WHERE id = @idFile

END