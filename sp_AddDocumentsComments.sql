-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-03-2022
-- Description: SP that adds notes, considerations and comments, at the same time, for the latter, adds the copies according to the type of document indicated
-- STORED PROCEDURE NAME:	sp_AddDocumentsComments
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: Document id the comment is related to
-- @commnet: Comment content
-- @commentType: Comment type id (1:Notas|2:Consideraciones|3:Comentario)
-- @createdBy: User who created the record
-- @order: Order in which the comment should appear 
-- @ccArray: Arrangement of document type ids
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-05-03		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/03/2022
-- Description: sp_AddDocumentsComments - SP that adds notes, considerations and comments, at the same time, for the latter, adds the copies according to the type of document indicated
CREATE PROCEDURE sp_AddDocumentsComments(
    @documentId INT,
    @commnet NVARCHAR (256),
    @commentType INT,
    @createdBy NVARCHAR (30),
    @order INT,
    @ccArray NVARCHAR (MAX)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @commentId INT;
    INSERT INTO DocumentsComments (
        documentId,
        comment,
        commentType,
        createdBy,
        lastUpdateBy,
        [order]
    )
    VALUES (
        @documentId,
        @commnet,
        @commentType,
        @createdBy,
        @createdBy,
        @order
    )

    SELECT @commentId = SCOPE_IDENTITY();

    IF @commentType = 3
        BEGIN
            IF @ccArray IS NOT NULL 
                BEGIN
                    INSERT INTO CommentsCopiedTo (
                        idComment,
                        idTypeDocument,
                        createdBy,
                        lastUpdateBy
                    )
                    SELECT 
                        @commentId,
                        value,
                        @createdBy,
                        @createdBy
                    FROM STRING_SPLIT(@ccArray, ',')
                    WHERE RTRIM(value)<>''
                END
        END

END