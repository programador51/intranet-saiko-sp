
SELECT 
    idDocument,
    documentNumber,
    rfc,
    amountToBeCredited,
    amountToPay,
    totalAcreditedAmount,
    subTotalAmount,
    iva,
    ivaAmount,
    totalAmount

FROM Documents AS odc
LEFT JOIN Customers AS customer ON customer.customerID = odc.idCustomer
WHERE 
    odc.idTypeDocument = 3 
    AND customer.customerType = 2 
    AND customer.rfc = 'XEXX010101000'


SELECT 
*
    -- calculationCostImport,
    -- calculationCostIva,
    -- calculationCostSubtotal,
    -- calculationPriceImport,
    -- calculationPriceIva,
    -- calculationPriceSubtotal,
    -- iva,
    -- ivaBeforeExchange,
    -- ivaPercentage,
    -- subTotal,
    -- subTotalBeforeExchange,
    -- totalImport,
    -- ivaExcento
FROM DocumentItems AS items
WHERE
    items.document  IN (
        
SELECT 
    idDocument
FROM Documents AS odc
LEFT JOIN Customers AS customer ON customer.customerID = odc.idCustomer
WHERE 
    odc.idTypeDocument = 3 
    AND customer.customerType = 2 
    AND customer.rfc = 'XEXX010101000'
    )
    