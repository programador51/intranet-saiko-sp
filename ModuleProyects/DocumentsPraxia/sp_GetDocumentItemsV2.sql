SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 29-11-2021
-- ************************************************************************************************************************
-- Description: Get the document items from a document
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: Id of the document to get the items
-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
 -- ***********************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ========================================================================================================================
--  29-11-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************
-- ============================================[FOLLOWING RESULT OF QUERY]=================================================
-- {
--     "items": [
--         {
--             "id": 1048,
--             "idDocument": 1508,
--             "description":"Azure"
--             "pu": {
--                 "number": 12.5,
--                 "text": "$12.50"
--             },
--             "puVenta": {
--                 "number": 12.5,
--                 "text": "$12.50"
--             },
--             "cu": {
--                 "number": 4,
--                 "text": "$4.00"
--             },
--             "catalogue": {
--                 "id": 402,
--                 "description": "Microsoft 365 Business STD",
--                 "puVenta": {
--                     "number": 12.5,
--                     "text": "$12.50"
--                 },
--                 "cuVenta": {
--                     "number": 4,
--                     "text": "$4.00"
--                 },
--                 "sku": "CSP-01",
--                 "iva": {
--                     "number": 16,
--                     "text": "16.00%"
--                 }
--             },
--             "quantity": 2,
--             "discount": {
--                 "money": {
--                     "number": 0,
--                     "text": "$0.00"
--                 },
--                 "number": 0,
--                 "text": "0.0000%"
--             },
--             "subtotal": {
--                 "number": 29,
--                 "text": "$29.00"
--             },
--             "importe": {
--                 "number": 25,
--                 "text": "$25.00"
--             },
--             "currency": {
--                 "id": 2,
--                 "code": "USD",
--                 "symbol": "$",
--                 "description": "Moneda estadounidense"
--             },
--             "iva": {
--                 "money": {
--                     "number": 4,
--                     "text": "$4.00"
--                 },
--                 "percentage": {
--                     "number": 16,
--                     "text": "16.00%"
--                 }
--             },
--             "beforeExchange": {
--                 "pu": {
--                     "number": 12.5,
--                     "text": "$12.50"
--                 },
--                 "cu": {
--                     "number": 4,
--                     "text": "$4.00"
--                 },
--                 "iva": {
--                     "number": 4,
--                     "text": "$4.00"
--                 },
--                 "importe": {
--                     "number": 25,
--                     "text": "$25.00"
--                 },
--                 "subtotal": {
--                     "number": 29,
--                     "text": "$29.00"
--                 }
--             },
--             "order": 1,
--             "uen": {
--                 "id": 1,
--                 "description": "Microsoft Office 365",
--                 "family": "Microsoft",
--                 "subFamily": "Office 365",
--                 "iva": {
--                     "number": 16,
--                     "text": "16.00%"
--                 }
--             }
--         }
--     ]
-- }
-- ========================================================================================================================
ALTER PROCEDURE [dbo].[sp_GetDocumentItemsV2](
    @idDocument INT
)

AS BEGIN

    SELECT
        items.idItem AS id,
        items.document AS idDocument,
        items.[description] AS [description],

        items.unit_price AS [pu.number],
        FORMAT(items.unit_price,'C','mx-MX') AS [pu.text],

        items.calculationPriceUnitary AS [puVenta.number],
        FORMAT(items.calculationPriceUnitary,'C','mx-MX') AS [puVenta.text],

        items.umDescripcion AS satUmDescription,
        items.claveProductoServicioDescripcion as satCodeDescription,

        items.unit_cost AS [cu.number],
        FORMAT(items.unit_cost,'C','mx-MX') AS [cu.text],
        catalogue.id_code AS [catalogue.id],
        CONCAT(catalogue.sku,' - ',items.[description]) AS [catalogue.description],
        catalogue.unit_price AS [catalogue.puVenta.number],
        FORMAT(catalogue.unit_price,'C','mx-MX') AS [catalogue.puVenta.text],

        catalogue.unit_cost AS [catalogue.cuVenta.number],
        FORMAT(catalogue.unit_cost,'C','mx-MX') AS [catalogue.cuVenta.text],

        catalogue.sku AS [catalogue.sku],

        catalogue.iva AS [catalogue.iva.number],
        CONCAT(catalogue.iva,'%') AS [catalogue.iva.text],

        items.quantity AS quantity,

        (items.unit_price - items.unitSellingPrice) * items.quantity AS [discount.money.number],

        FORMAT(((items.unit_price - items.unitSellingPrice) * items.quantity),'C','mx-MX') AS [discount.money.text],

        items.discount AS [discount.number],
        CONCAT(items.discount,'%') AS [discount.text],
        -- 100 AS [discount.number],
        -- '100%' AS [discount.text],

        CASE 
          WHEN document.idTypeDocument=3 THEN items.calculationCostSubtotal
          ELSE items.calculationPriceSubtotal
        END AS [subtotal.number],

        CASE 
          WHEN document.idTypeDocument=3 THEN FORMAT(items.calculationCostSubtotal,'C','mx-MX')
          ELSE FORMAT(items.calculationPriceSubtotal,'C','mx-MX')
        END AS [subtotal.text],
        
        -- FORMAT(items.subTotal,'C','mx-MX') AS [subtotal.text],

        -- items.subTotal AS [subtotal.number],
        -- items.totalImport AS [importe.number],
        CASE 
          WHEN document.idTypeDocument=3 THEN items.calculationCostImport
          ELSE items.calculationPriceImport
        END AS [importe.number],

        CASE 
          WHEN document.idTypeDocument=3 THEN FORMAT(items.calculationCostImport,'C','mx-MX')
          ELSE FORMAT(items.calculationPriceImport,'C','mx-MX') 
        END AS [importe.text],

        -- FORMAT(items.totalImport,'C','mx-MX') AS [importe.text],

        currency.currencyID AS [currency.id],
        currency.code AS [currency.code],
        currency.symbol AS [currency.symbol],
        currency.description AS [currency.description],

        CASE 
          WHEN document.idTypeDocument=3 THEN items.calculationCostIva
          ELSE items.calculationPriceIva
        END AS [iva.money.number],

        CASE 
          WHEN document.idTypeDocument=3 THEN FORMAT(items.calculationCostIva,'C','mx-MX')
          ELSE FORMAT(items.calculationPriceIva,'C','mx-MX')
        END AS [iva.money.text],

        -- items.iva AS [iva.money.number],

        -- FORMAT(items.iva,'C','mx-MX') AS [iva.money.text],



        items.ivaPercentage AS [iva.percentage.number],
        CONCAT(items.ivaPercentage,'%') AS [iva.percentage.text],

        items.unitPriceBeforeExchange AS [beforeExchange.pu.number],
        FORMAT(items.unitPriceBeforeExchange,'C','mx-MX') AS [beforeExchange.pu.text],

        items.unitCostBeforeExchange AS [beforeExchange.cu.number],
        FORMAT(items.unitCostBeforeExchange,'C','mx-MX') AS [beforeExchange.cu.text],

        items.ivaBeforeExchange AS [beforeExchange.iva.number],
        FORMAT(items.ivaBeforeExchange,'C','mx-MX') AS [beforeExchange.iva.text],

        items.subTotalBeforeExchange AS [beforeExchange.importe.number],
        FORMAT(items.subTotalBeforeExchange,'C','mx-MX') AS [beforeExchange.importe.text],

        items.unitSellingPriceBeforeExchange AS [beforeExchange.subtotal.number],
        FORMAT(items.unitSellingPriceBeforeExchange,'C','mx-MX') AS [beforeExchange.subtotal.text],

        items.[order] AS 'order',

        uen.UENID AS [uen.id],
        uen.description AS [uen.description],
        uen.family AS [uen.family],
        uen.subFamily AS [uen.subFamily],
        uen.iva AS [uen.iva.number],
        CONCAT(uen.iva,'%') AS [uen.iva.text],
        items.um AS [um.clave],
        items.umDescripcion AS [um.description],
        items.claveProductoServicio AS [claveSat.code],
        items.claveProductoServicioDescripcion AS [claveSat.description]
        
      FROM DocumentItems AS items

      LEFT JOIN Catalogue AS catalogue ON items.idCatalogue = catalogue.id_Code
      LEFT JOIN Currencies AS currency ON catalogue.currency = currency.currencyID
      LEFT JOIN UEN AS uen ON catalogue.uen = uen.UENID
      LEFT JOIN Documents AS document ON document.idDocument= items.document

      WHERE 
        document = @idDocument AND
        items.status = 1

      ORDER BY items.[order] ASC

    FOR JSON PATH, ROOT('docItems'), INCLUDE_NULL_VALUES;

END
GO
