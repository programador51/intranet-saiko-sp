SELECT 

    Notes.id,
    Notes.content,
    ISNULL(Notes.currency,'NA'),
    Notes.isDelatable AS [is.delatable],
    Notes.isEditable AS [is.editable],
    Notes.type,
    Notes.uen

FROM NoteAndCondition AS Notes
LEFT JOIN NoteAndConditionToDocType AS DocNoteTypes ON DocNoteTypes.idNoteAndCondition= Notes.id

WHERE DocNoteTypes.idDocumentType = 2 AND Notes.[status]=1

FOR JSON PATH, ROOT('Notes'), INCLUDE_NULL_VALUES