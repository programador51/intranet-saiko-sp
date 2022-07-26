
-- Previus id 1924
SELECT COUNT(*) FROM  DocumentItems AS docItems
        LEFT JOIN Catalogue AS catalogo ON catalogo.id_code=docItems.idCatalogue 
         WHERE docItems.document=1929 AND catalogo.currency=2
SELECT COUNT(*) FROM  DocumentItems AS docItems
        LEFT JOIN Catalogue AS catalogo ON catalogo.id_code=docItems.idCatalogue 
         WHERE docItems.document=1929 AND catalogo.currency=1


SELECT 
    subTotalAmount, 
    ivaAmount ,
    totalAmount
    FROM Documents 
WHERE idExecutive=20 AND documentNumber=141

SELECT 
    ROUND(SUM(docItems.unit_price*quantity),1) AS importe,
    ROUND(SUM(docItems.unit_price*quantity*catalogo.iva/100),1) AS iva,
    ROUND(SUM(docItems.unit_price*quantity) + SUM(docItems.unit_price*quantity*catalogo.iva/100),1) AS total
 FROM DocumentItems AS docItems
 
 LEFT JOIN Catalogue AS catalogo ON catalogo.id_code= docItems.idCatalogue
 WHERE document=1929



--   CASE 
--                 WHEN tempCotizacion.idCurrency= catalogo.currency THEN 
--                     (ROUND(SUM(catalogo.unit_price*quantity) + SUM(catalogo.unit_price*quantity*catalogo.iva/100),1) )
--                 WHEN tempCotizacion.idCurrency=1 AND catalogo.currency=2 THEN 
--                     (ROUND((SUM(catalogo.unit_price*quantity) + SUM(catalogo.unit_price*quantity*catalogo.iva/100)*@currentTc),1))
--                 ELSE
--                     (ROUND((SUM(catalogo.unit_price*quantity) + SUM(catalogo.unit_price*quantity*catalogo.iva/100)/@currentTc),1))
--             END,--totalImport


-- CASE 
--                 WHEN tempCotizacion.idCurrency= catalogo.currency THEN 
--                     (ROUND(SUM(catalogo.unit_price*quantity*catalogo.iva/100),1) )
--                 WHEN tempCotizacion.idCurrency=1 AND catalogo.currency=2 THEN 
--                     (ROUND((SUM(catalogo.unit_price*quantity*catalogo.iva/100)*@currentTc),1) )
--                 ELSE
--                     (ROUND((SUM(catalogo.unit_price*quantity*catalogo.iva/100)/@currentTc),1) )
--             END,--Se calcula del importe (cantidad * precio unitario)* i






IF OBJECT_ID(N'tempdb..#TempCotizaciones') IS NOT NULL
        BEGIN
            DROP TABLE #TempCotizaciones
        END

CREATE TABLE #TempCotizaciones(
    id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    countInactiveItems INT DEFAULT 0,
    currentDocumentId INT
)

INSERT INTO #TempCotizaciones (
    currentDocumentId
)
VALUES (
    1929
),(1924)

 UPDATE #TempCotizaciones SET 
          countInactiveItems= (
            SELECT 
                COUNT(*) 
            FROM DocumentItems 
            LEFT JOIN Catalogue AS catalogo ON catalogo.id_code=DocumentItems.idCatalogue
            WHERE catalogo.[status]=0 AND tempDocument.currentDocumentId=documentItems.document
          )
        FROM #TempCotizaciones AS tempDocument
        LEFT JOIN DocumentItems AS documentItems ON documentItems.document=tempDocument.currentDocumentId
        WHERE tempDocument.currentDocumentId=documentItems.document

SELECT * FROM #TempCotizaciones

IF OBJECT_ID(N'tempdb..#TempCotizaciones') IS NOT NULL
        BEGIN
            DROP TABLE #TempCotizaciones
        END