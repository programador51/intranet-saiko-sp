-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-16-2021
-- Description: Update the document status
-- STORED PROCEDURE NAME:	sp_UpdateDocumentStatus
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentStatusId: The status id
-- @documentId: The document id
-- @modifyBy: The person how modify the document
             
-- ===================================================================================================================================
-- Returns:
-- If the reminder was added successfully
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-10-16		Adrian Alardin   			1.0.0.0			Initial Revision
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_UpdateDocumentStatus(
        @documentStatusId INT,
        @documentId INT,
        @modifyBy NVARCHAR (30)
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON 
        UPDATE Documents
                SET idStatus=@documentStatusId,lastUpdatedDate=GETDATE(),lastUpdatedBy=@modifyBy
                WHERE
                    idDocument = @documentId
END
GO