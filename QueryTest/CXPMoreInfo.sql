DECLARE @idMovement INT = 23

SELECT 
    Customers.socialReason AS [socialReson],
    CONCAT (Documents.currectFaction,'/',Documents.partialitiesRequested) AS [CXP.partialities],
    Currencies.code AS [CXP.currency],
    dbo.fn_FormatCurrency(Documents.totalAmount) AS [CXP.total],
    dbo.fn_FormatCurrency(Documents.totalAcreditedAmount) AS [CXP.acumulated],
    dbo.fn_FormatCurrency(Documents.amountToPay) AS [CXP.residue],
    Documents.idInvoice AS [Invoice.noFactura],
    dbo.fn_FormatCurrency(LegalDocuments.total) AS [Invoice.total],
    dbo.fn_FormatCurrency(LegalDocuments.acumulated) AS [Invoice.acumulated],
    dbo.fn_FormatCurrency(LegalDocuments.residue) AS [Invoice.residue]


FROM Documents 
LEFT JOIN ConcilationCxP ON ConcilationCxP.idMovement=@idMovement
LEFT JOIN Customers ON Customers.customerID=Documents.idCustomer
LEFT JOIN Currencies ON Currencies.currencyID=DOCUMENTS.idCurrency
LEFT JOIN LegalDocuments ON LegalDocuments.uuid=Documents.uuid

WHERE Documents.idDocument=ConcilationCxP.idCxP

FOR JSON PATH, ROOT('OverviewCXP')

