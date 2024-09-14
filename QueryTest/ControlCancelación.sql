SELECT 
Documents.idDocument,
Documents.idTypeDocument,
DocumentTypes.[description] AS documentType,
Documents.idStatus,
DocumentStatus.[description],
Documents.pdf

FROM Documents
LEFT JOIN DocumentStatus ON DocumentStatus.documentStatusID = Documents.idStatus
LEFT JOIN DocumentTypes ON DocumentTypes.documentTypeID=Documents.idTypeDocument
WHERE (Documents.createdBy='Adrian   Alardin Iracheta' AND Documents.createdDate >=dbo.fn_MexicoLocalTime(GETDATE()) )
ORDER BY idDocument DESC


SELECT 
    LegalDocuments.id,
    LegalDocuments.idTypeLegalDocument,
    LegalDocumentTypes.[description] AS documentType,
    LegalDocuments.idLegalDocumentStatus,
    LegalDocumentStatus.[description] AS documentStatus,
    LegalDocuments.pdf,
    LegalDocuments.createdDate

 FROM LegalDocuments 
 LEFT JOIN LegalDocumentTypes ON LegalDocumentTypes.id= LegalDocuments.idTypeLegalDocument
 LEFT JOIN LegalDocumentStatus ON LegalDocumentStatus.id= LegalDocuments.idLegalDocumentStatus
 WHERE( LegalDocuments.createdBy='Adrian   Alardin Iracheta' AND LegalDocuments.idTypeLegalDocument=2  ) 
 ORDER BY LegalDocuments.id DESC


--  SELECT * FROM AssociatedFiles ORDER BY id DESC