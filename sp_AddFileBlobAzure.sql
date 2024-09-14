
-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 08-10-2021
-- Description: Add the record information of azure blob storage file inserted
-- STORED PROCEDURE NAME:	sp_AddFileBlobAzure
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @uploadedBy: Name executive who added the file
-- @fileName: File name (without extension)
-- @idDocument: Id of the document it's associated
-- @typeFile: File extension (without the dot .)
-- @urlFile: Url where it's located the file on blob storage
-- *******************************************************************************************************************************
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	08-10-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_AddFileBlobAzure(
    @uploadedBy NVARCHAR(30),
    @fileName NVARCHAR(50),
    @idDocument INT,
    @typeFile NVARCHAR(10),
    @urlFile NVARCHAR(200)
)

AS BEGIN

    INSERT INTO AssociatedFiles

    (
        associatedDate , createdBy , fileName,
        idDocument , typeFile , urlBlob
    )

    VALUES

    (

        GETDATE() , @uploadedBy , @fileName , 
        @idDocument , @typeFile , @urlFile

    )

END