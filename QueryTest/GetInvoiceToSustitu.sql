-- DECLARE @search NVARCHAR (256)='EKU9003173C9%'
-- DECLARE @search NVARCHAR (256)='Cliente con facturas cancelables%'
DECLARE @search NVARCHAR (256)='2%'

SELECT 
    id,
    currencyCode,
    emitedDate,
    facturamaNoDocument,
    idCustomer,
    rfcReceptor,
    socialReason,
    dbo.fn_FormatCurrency(total) AS total,
    uuid

 FROM LegalDocuments
 WHERE idTypeLegalDocument=2 AND idLegalDocumentStatus=7 AND (socialReason LIKE @search OR rfcReceptor LIKE @search OR facturamaNoDocument LIKE @search)