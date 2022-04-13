-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-13-2022
-- Description: Gets the notes and consideration by the document type id
-- STORED PROCEDURE NAME:	sp_GetNotesAndConditionsByDocument
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idDocType: Document type id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- The list of all the notes 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-04-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/13/2022
-- Description: sp_GetNotesAndConditionsByDocument - Gets the notes and consideration by the document type id
CREATE PROCEDURE sp_GetNotesAndConditionsByDocument(
    @idDocType INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 

        Notes.id,
        Notes.content,
        Notes.currency,
        Notes.isDelatable AS [is.delatable],
        Notes.isEditable AS [is.editable],
        Notes.type,
        Notes.uen

    FROM NoteAndCondition AS Notes
    LEFT JOIN NoteAndConditionToDocType AS DocNoteTypes ON DocNoteTypes.idNoteAndCondition= Notes.id

    WHERE DocNoteTypes.idDocumentType = @idDocType AND Notes.[status]=1

    FOR JSON PATH, ROOT('Notes'), INCLUDE_NULL_VALUES

END