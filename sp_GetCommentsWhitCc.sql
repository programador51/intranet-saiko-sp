-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-11-2022
-- Description: Obtains the quote comments that are copied to another type of document
-- STORED PROCEDURE NAME:	sp_GetCommentsWhitCc
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: Document id
-- @documentType: Document type
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- id: comment id
-- comment: comment content
-- commentType: comment type
-- order: ordering number
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-05-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/11/2022
-- Description: sp_GetCommentsWhitCc - Obtains the quote comments that are copied to another type of document
CREATE PROCEDURE sp_GetCommentsWhitCc(
    @documentId INT,
    @documentType INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    SELECT  
    DocComments.id,
    DocComments.comment,
    DocComments.commentType,
    DocComments.[order]

    FROM DocumentsComments AS DocComments
    LEFT JOIN CommentsCopiedTo AS CommentsCC ON CommentsCC.idComment=DocComments.id 
    WHERE DocComments.documentId=@documentId AND CommentsCC.idTypeDocument=@documentType
    ORDER BY CASE
                WHEN DocComments.commentType= 1 THEN 1
                WHEN DocComments.commentType= 2 THEN 3
                WHEN DocComments.commentType= 3 THEN 2
                ELSE NULL END, DocComments.[order]

END