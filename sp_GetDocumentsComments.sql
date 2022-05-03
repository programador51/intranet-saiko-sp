-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-03-2022
-- Description: Get the comments sorted by type and by order
-- STORED PROCEDURE NAME:	sp_GetDocumentsComments
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: The document id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
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
-- Description: sp_GetDocumentsComments - Get the comments sorted by type and by order
CREATE PROCEDURE sp_GetDocumentsComments(
    @documentId INT
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT
        [comment],
        [order],
        commentType
    FROM DocumentsComments
    WHERE documentId= @documentId
    ORDER BY commentType, [order]

END