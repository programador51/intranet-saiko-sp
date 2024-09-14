
DECLARE @idLegalDocument INT=81;
DECLARE @idExecutive INT= 20;


SELECT
    CONCAT (Users.firstName,' ',Users.middleName,' ',Users.lastName1,' ',Users.lastName2) AS fullName,
    LegalDocuments.idLegalDocumentStatus,
    CASE
        WHEN LegalDocuments.idLegalDocumentStatus=7 THEN 1
        ELSE 0
    END AS isCancelabe,
    CASE
        WHEN LegalDocuments.idLegalDocumentStatus=7 THEN Documents.invoiceMizarNumber
        ELSE '-1'
    END AS cfdiId,
    CASE
        WHEN LegalDocuments.idLegalDocumentStatus=7 THEN ISNULL(DocumentFile.id,LegalFile.id)
        ELSE -1
    END AS pdfToDelete,
    CASE
        WHEN LegalDocuments.idDocument IS NULL THEN 1 
        ELSE 0 
    END AS isSpecial,
    ISNULL (LegalDocuments.idDocument,-1) AS idDocument,
    Documents.invoiceNumberSupplier AS folio

FROM LegalDocuments


    LEFT JOIN Documents ON Documents.idDocument=LegalDocuments.idDocument
    LEFT JOIN Documents AS Document ON Document.idDocument = LegalDocuments.idDocument
    LEFT JOIN AssociatedFiles DocumentFile ON DocumentFile.id=Document.pdf
    LEFT JOIN AssociatedFiles AS LegalFile ON LegalFile.id=LegalDocuments.pdf
    LEFT JOIN Users ON Users.userID=@idExecutive


WHERE LegalDocuments.id=@idLegalDocument
