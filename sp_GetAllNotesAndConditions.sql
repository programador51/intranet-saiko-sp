-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-18-2022
-- Description: Gets all notes and considerations
-- STORED PROCEDURE NAME:	sp_GetAllNotesAndConditions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- All notes and considerationse
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-04-18		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/18/2022
-- Description: sp_GetAllNotesAndConditions - Gets all notes and considerations
CREATE PROCEDURE sp_GetAllNotesAndConditions AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        Notes.id,
        Notes.[type],
        Notes.content,
        Notes.currency AS currency,
        Notes.uen,
        Notes.isDelatable AS [is.deletable],
        Notes.isEditable AS [is.editable],
        Notes.status AS [is.active],
        (SELECT NoteDocType.idDocumentType  FROM NoteAndConditionToDocType AS NoteDocType WHERE NoteDocType.idNoteAndCondition= Notes.id AND NoteDocType.[status]=1 FOR JSON PATH) AS docType
    FROM NoteAndCondition AS Notes
    FOR JSON PATH, ROOT('Notes')

END