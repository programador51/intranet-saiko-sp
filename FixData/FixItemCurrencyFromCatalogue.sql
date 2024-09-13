DECLARE @TemItems TABLE
(
    idItem INT,
    idDocument INT,
    idCatalogue INT,
    docCurrency NVARCHAR(3),
    itemCurrency NVARCHAR(3)
)

INSERT INTO @TemItems(idItem, idDocument, idCatalogue,docCurrency, itemCurrency )


SELECT 
    items.idItem,
    items.document,
    catalogue.id_code,
    docCurrency.code,
    itemCurrency.code
FROM DocumentItems AS items
LEFT JOIN Documents AS docs ON docs.idDocument = items.document
LEFT JOIN Currencies AS docCurrency ON docCurrency.currencyID= docs.idCurrency
LEFT JOIN Catalogue AS catalogue ON catalogue.id_code = items.idCatalogue
LEFT JOIN Currencies AS itemCurrency ON itemCurrency.currencyID= catalogue.currency
WHERE 
    items.currency IS NULL
    AND docs.idTypeDocument= 1
    AND docs.idStatus= 3
GROUP BY 
    items.idItem,
    items.document,
    catalogue.id_code,
    docCurrency.code,
    itemCurrency.code
ORDER BY 
    items.document ASC



UPDATE items SET
    items.currency = temp.itemCurrency
FROM DocumentItems AS items
LEFT JOIN @TemItems AS temp ON temp.idItem = items.idItem
LEFT JOIN Documents AS docs ON docs.idDocument = items.document
WHERE 
    items.currency IS NULL
    AND items.idItem = temp.idItem
    AND docs.idTypeDocument= 1
    AND docs.idStatus= 3

-- SELECT * FROM DocumentNewStatus WHERE idDocumentType=1 

-- ACTIVOS: 27
-- GANADOS: 2
-- CANCELADOS: 42


-- 1857
-- 1858






SELECT 
    items.idItem,
    items.document,
    catalogue.id_code,
    docCurrency.code docCurrency,
    itemCurrency.code AS catalogueCurrency,
    items.currency AS itemCurrency
FROM DocumentItems AS items
LEFT JOIN Documents AS docs ON docs.idDocument = items.document
LEFT JOIN Currencies AS docCurrency ON docCurrency.currencyID= docs.idCurrency
LEFT JOIN Catalogue AS catalogue ON catalogue.id_code = items.idCatalogue
LEFT JOIN Currencies AS itemCurrency ON itemCurrency.currencyID= catalogue.currency
WHERE 
     items.currency IS NULL
    -- items.idItem IN (
    --         1857,
    --         1858
    -- )
    -- AND docs.idTypeDocument= 1
    -- AND docs.idStatus= 3
GROUP BY 
    items.idItem,
    items.document,
    catalogue.id_code,
    docCurrency.code,
    itemCurrency.code,
    items.currency
ORDER BY 
    items.document ASC