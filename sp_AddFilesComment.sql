-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 06-10-2021
-- Description: Add a comment to an associated file register, returns the record inserted
-- STORED PROCEDURE NAME:	sp_AddFilesComment
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @idFile: Id of the file 
-- @comment: Comment content
-- @executive: Fullname of the executive who created the comment
-- *******************************************************************************************************************************
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	06-10-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_AddFilesComment(
    @idFile INT,
    @comment NVARCHAR(300),
    @executive NVARCHAR(30)
)

AS BEGIN

    DECLARE @idInserted INT;
        
    INSERT INTO AssociatedFilesComments

    (
        commentedBy , commentedAt , idAssociatedFile , 
        comment
    )

    VALUES

    (
        @executive , GETDATE() , @idFile , 
        @comment
    );

    SELECT @idINSERTED = SCOPE_IDENTITY();

    SELECT 
        id AS id,
        commentedBy AS commentedBy,
        commentedAt AS commentedDate,
        comment AS comment
    FROM 
        AssociatedFilesComments 
    WHERE id = @idInserted;

END