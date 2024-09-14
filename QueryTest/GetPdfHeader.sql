DECLARE  @idDocument INT = 579;
SET LANGUAGE Spanish;

SELECT
    documentNumber AS documentNumber,
    documentType AS documentType,
    createdDate AS fechaCreacion,
    customerType AS CustomerType,
    CONCAT('RFC: ',rfc) AS rfc,
    socialReson AS socialReason,
    CONCAT(street,' ',exteriorNumber,', ',interiorNumber,', ',city) AS Calle,
    CONCAT([state],', ',country,', ',cp) AS Pais,
    contactName AS dirigidoA,
    CONCAT('Telefono: ',phone) AS phoneNumber,
    concat('Celular: ',cel) AS cellNumbe,
    quoteNumber,
    contractNumber,
    originNumber,
    orderNumber,
    invoiceNumber,
    odcNumber,
    contactEmail AS customerEmail,
    contactName AS contactName,
    documentStatus AS [status],
    creditDays AS creditDays,
    expirationDate AS expirationDate,
    currencyCode AS code,
    dbo.fn_FormatCurrency(import) AS subTotal,
    dbo.fn_FormatCurrency(iva) AS IVA,
    dbo.fn_FormatCurrency(total) AS Total,
    executiveInitials AS createdBy,
    executiveEmail AS userEmail,
    executiveName AS[name]


FROM documents_view
WHERE documentId=@idDocument