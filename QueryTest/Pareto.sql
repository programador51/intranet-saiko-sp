
-- PASOS PARA OBTENER EL PARETO
-- 1.- OBTENER TODOS LOS PEDIDOS CUYO ESTATUS ESTE FACTURADO Y QUE TENGAN ODC
-- 2.- OBTENER EL ID DEL CUSTOMER
--     2.1.- EN CASO DE QUE EL CUSTOMER TENGA CORPORATIVO ESTE PASA A SER EL ID DEL CUSTOMER
--     2.2.- EN CASO DE QUE EL CUSTOMER NO TENGA CORPORATIVO, EL ID DEL CUSTOMER SERA EL QUE SE UTILICE
-- 3.- OBTENER TODAS LAS ODC RELACIONADAS AL PEDIDO
--     3.1.- LAS ORDENS DE COMPRA SIN MONEDA, SE CACULARA SU TOTAL CORRESPONDIENTE A LA MONEDA DEL DOCUMENTO
--     3.2.- LAS ORDENS DE COMPRA CON MONEDA PASARA EL TOTAL CORRESPONIENTE
-- 4.- SE CALCULARA EL MARGEN IGUAL AL TOTAL DEL PEDIDO  - AL TOTAL DE LA ODC


DECLARE @reportCurrency NVARCHAR(3)= 'MXN';
-- Solo tiene 2 posibles valores 1: Por facturas 2: Por margen de ganancia
DECLARE @reportType TINYINT = 1 


DECLARE @idInvoicedStatus INT = 5;
DECLARE @idDocumentType INT = 2;


DECLARE @temOdcItems TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idOdc INT NOT NULL,
    subtotal DECIMAL(14,4) NOT NULL,
    currency NVARCHAR(3) NOT NULL
)

INSERT INTO @temOdcItems(
    idOdc,
    subtotal,
    currency
)
    SELECT 
        items.document,
        SUM(
            CASE 
                WHEN @reportCurrency = items.currency THEN items.quantity * items.unit_cost
                WHEN @reportCurrency != items.currency AND @reportCurrency='MXN' THEN items.quantity * items.unit_cost*odc.protected
                WHEN @reportCurrency != items.currency AND @reportCurrency='USD' THEN items.quantity * items.unit_cost/odc.protected
            END
        ) AS importe,
        @reportCurrency

    FROM DocumentItems AS items
    LEFT JOIN Documents AS odc ON odc.idDocument= items.document
    WHERE 
        [status] =1 AND
        document IN (
            SELECT 
                idOc
            FROM Documents
            WHERE 
                idTypeDocument= @idDocumentType AND
                idStatus= @idInvoicedStatus AND
                idOC IS NOT NULL
        )
    GROUP BY 
        document

DECLARE @tempPareto TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idOrder INT NOT NULL,
    idOdc INT NOT NULL,
    idCustomer INT NOT NULL,
    sellImport DECIMAL(14,4) NOT NULL,
    costImport DECIMAL(14,4) NOT NULL,
    margin AS CAST((sellImport - costImport) AS DECIMAL(14,4)),
    currency NVARCHAR(3) NOT NULL
)
INSERT INTO @tempPareto (
    idOrder,
    idOdc,
    idCustomer,
    sellImport,
    costImport,
    currency
)
SELECT
    orden.idDocument,
    orden.idOC,
    ISNULL(client.corporative,client.customerID),
    CASE 
        WHEN @reportCurrency = currency.code THEN orden.subTotalAmount
        WHEN @reportCurrency != currency.code AND @reportCurrency ='MXN' THEN orden.subTotalAmount*orden.protected
        WHEN @reportCurrency != currency.code AND @reportCurrency='USD' THEN orden.subTotalAmount/orden.protected
    END,
    odcItems.subtotal,
    @reportCurrency
FROM Documents AS orden
LEFT JOIN Customers AS client ON client.customerID= orden.idCustomer
LEFT JOIN @temOdcItems AS odcItems ON odcItems.idOdc = orden.idOC
LEFT JOIN Currencies AS currency ON currency.currencyID = orden.idCurrency
LEFT JOIN Documents AS odc ON odc.idDocument= orden.idOC
WHERE
    orden.idTypeDocument= @idDocumentType AND
    orden.idStatus= @idInvoicedStatus AND
    orden.idOC IS NOT NULL


DECLARE @totalIncoice DECIMAL(14,4)
DECLARE @totalMargin DECIMAL(14,4)

SELECT @totalIncoice =  SUM(sellImport) FROM @tempPareto
SELECT @totalMargin =  SUM(margin) FROM @tempPareto

DECLARE @pareto TABLE (
    id INT NOT NULL IDENTITY(1,1),
    socialReason NVARCHAR(128) NOT NULL,
    sell DECIMAL (14,4) NOT NULL,
    cost DECIMAL(14,4) NOT NULL,
    margin DECIMAL (14,4) NOT NULL,
    currency NVARCHAR(3) NOT NULL,
    invoicePercentage DECIMAL (8,4) NOT NULL,
    marginPercentage DECIMAL (8,4) NOT NULL

)

INSERT INTO @pareto (
    socialReason,
    sell,
    cost,
    margin,
    currency,
    invoicePercentage,
    marginPercentage
)
SELECT 
    client.socialReason,
    SUM(tempPareto.sellImport) AS sellImport,
    SUM(tempPareto.costImport) AS costImport,
    SUM(tempPareto.margin) AS margin,
    tempPareto.currency,
    SUM(tempPareto.sellImport)/@totalIncoice*100 AS invoicePercentage,
    SUM(tempPareto.margin)/@totalIncoice*100 AS marginPercentage
FROM @tempPareto AS tempPareto
LEFT JOIN Customers AS client ON client.customerID= tempPareto.idCustomer
GROUP BY 
    client.socialReason,
    tempPareto.currency
ORDER BY 
    CASE 
        WHEN @reportType =1 THEN SUM(tempPareto.sellImport)/@totalIncoice*100  
        ELSE SUM(tempPareto.margin)/@totalIncoice*100 
    END DESC
    


    
    SELECT 
        socialReason,
        sell,
        cost,
        margin,
        currency,
        invoicePercentage,
        marginPercentage,
        CASE 
            WHEN @reportType = 1 THEN SUM(invoicePercentage) OVER (ORDER BY Id)
            ELSE SUM(marginPercentage) OVER (ORDER BY Id)
        END AS pareto
FROM @pareto
