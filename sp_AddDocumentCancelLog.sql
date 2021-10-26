-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-16-2021
-- Description: We add the reminder dependig the level (customer,contact or document)
-- STORED PROCEDURE NAME:	sp_AddDocumentCancelLog
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @executiveId: The executive id
-- @documentId: The document id
-- @motive: The motive it was canceled
             
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
    CREATE PROCEDURE sp_AddDocumentCancelLog(
        @executiveId INT,
        @documentId INT,
        @motive NVARCHAR (256)
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON 
        INSERT INTO DocumentCancellationLog (
            executiveId,
            documentId,
            cancelationStatus,
            cancelationDate,
            motive
        )
        VALUES(
            @executiveId,
            @documentId,
            'Cancelado',
            GETDATE(),
            @motive
        )
END
GO