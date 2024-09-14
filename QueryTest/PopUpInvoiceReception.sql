DECLARE @legalDocumentId INT=14;


SELECT 
    LegalDocument.id,
    LegalDocument.socialReason,
    dbo.fn_ConcatPhones(Contact.cellNumberAreaCode,Contact.cellNumber,Customer.ladaMovil,Customer.movil) AS cellPhone,
    dbo.fn_ConcatPhones(Contact.phoneNumber,Contact.phoneNumberAreaCode,Customer.ladaPhone,Customer.phone)AS phoneNumber, 
    ISNULL(Contact.email,Customer.email) AS email,
    LegalDocument.noDocument,
    dbo.fn_FormatCurrency(LegalDocument.import) AS import,
    dbo.fn_FormatCurrency(LegalDocument.iva) as iva,
    dbo.fn_FormatCurrency(LegalDocument.total) as total,
    dbo.fn_FormatCurrency(LegalDocument.acumulated) as acumulated,
    dbo.fn_FormatCurrency(LegalDocument.residue) as residue,
    LegalDocument.idLegalDocumentStatus,
    LegalStatus.description


FROM LegalDocuments AS LegalDocument

LEFT JOIN Contacts AS Contact ON LegalDocument.idLegalDocumentProvider=Contact.customerID
LEFT JOIN Customers AS Customer ON LegalDocument.idLegalDocumentProvider=Customer.customerID
LEFT JOIN LegalDocumentStatus AS LegalStatus ON LegalDocument.idLegalDocumentStatus=LegalStatus.id

WHERE LegalDocument.idTypeLegalDocument=1  AND LegalDocument.id=@legalDocumentId;

-- SELECT * FROM Customers WHERE customerID=306
-- SELECT * FROM LegalDocuments 