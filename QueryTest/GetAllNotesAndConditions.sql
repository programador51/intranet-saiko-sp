SELECT 
    Notes.id,
    Notes.[type],
    Notes.content,
    ISNULL(Notes.currency,'NA') AS currency,
    Notes.uen,
    Notes.isDelatable AS [is.deletable],
    Notes.isEditable AS [is.editable],
    Notes.status AS [is.active],
    (SELECT NoteDocType.idDocumentType  FROM NoteAndConditionToDocType AS NoteDocType WHERE NoteDocType.idNoteAndCondition= Notes.id AND NoteDocType.[status]=1 FOR JSON PATH) AS docType
FROM NoteAndCondition AS Notes
FOR JSON PATH, ROOT('Notes'), INCLUDE_NULL_VALUES


