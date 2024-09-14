-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-16-2021
-- Description: We add the reminder dependig the level (customer,contact or document)
-- STORED PROCEDURE NAME:	sp_UpdateReminder
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @comments: The comment
             
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
    CREATE PROCEDURE sp_UpdateReminder(
        @comment NVARCHAR (256),
        @commentID BIGINT,
        @previousCommentId BIGINT

    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON 
 UPDATE Commentation
 SET attentionComment=@comment, realAttentionDate= GETDATE(),previousCommentId=@previousCommentId
 WHERE commentId=@commentID
END
GO