
SET LANGUAGE Spanish
SELECT 
    Document.idDocument,
    DocType.description AS documentType,
    FORMAT(Document.documentNumber,'0000000') AS documentNumber,
    Currency.code AS currency,
    Document.subTotalAmount AS importNumber,
    dbo.fn_FormatCurrency(Document.subTotalAmount) AS importText,
    Document.ivaAmount AS ivaNumber,
    dbo.fn_FormatCurrency(Document.ivaAmount) AS ivaText,
    Document.totalAmount AS totalNumber,
    dbo.fn_FormatCurrency(Document.totalAmount) AS totalText,
    dbo.FormatDate(Document.createdDate) AS registro,
    dbo.FormatDate(Document.expirationDate) AS vigencia,
    DocStatus.description AS status
    
FROM Documents AS Document
LEFT JOIN Currencies AS Currency ON Document.idCurrency=Currency.currencyID
LEFT JOIN DocumentTypes AS DocType ON Document.idTypeDocument=DocType.documentTypeID
LEFT JOIN DocumentStatus AS DocStatus ON Document.idStatus=DocStatus.documentStatusID