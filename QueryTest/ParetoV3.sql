DECLARE @reportCurrency NVARCHAR(3)='MXN';
DECLARE @reportType TINYINT=2;

DECLARE @invoicedMxn DECIMAL(14,4);
DECLARE @invoicedUsd DECIMAL(14,4);
DECLARE @costMxn DECIMAL(14,4);
DECLARE @costUsd DECIMAL(14,4);

DECLARE @marginMxn DECIMAL(14,4);
DECLARE @marginUsd DECIMAL(14,4);

-- Los documentos de tipo pedido
    DECLARE @idDocumentType INT = 2
    -- Los documentos con estatus facturado
    DECLARE @idDocumentStatus INT =5

    -- Estatus Cxc
    DECLARE @idStatusCxc INT = 7
    
    -- Estatus parcial cxc
    DECLARE @idStatusPartialCxc INT = 9
    
    -- Estatus cobrado
    DECLARE @idStatusChargedCxc INT = 10

    -- Facturas emitidas
    DECLARE @idInvoiceTypeE INT =2;



DECLARE @reportTotalSell DECIMAL(14,4);
    DECLARE @reportTotalCost DECIMAL(14,4);
    DECLARE @reportTotalMargin DECIMAL(14,4);
    DECLARE @reportTotalInvoiced DECIMAL(14,4);


    -- Total de todas las facturas en MXN
    DECLARE @mxnTotalSell DECIMAL(14,4);

    -- Total de todas las facturas en USD
    DECLARE @usdTotalSell DECIMAL (14,4);

    -- Total de todas de los costos en MXN
    DECLARE @mxnTotalCost DECIMAL(14,4);

    -- Total de todas de los costos en USD
    DECLARE @usdTotalCost DECIMAL (14,4);

    -- Total del margen en MXN
    DECLARE @mxnTotalMargin DECIMAL(14,4)

    -- Total del margen en USD
    DECLARE @usdTotalMargin DECIMAL(14,4)

    SELECT
        @mxnTotalSell = SUM(
            CASE 
                WHEN invoice.currencyCode = 'MXN' THEN items.calculationPriceUnitary * items.quantity
                ELSE 0
            END
        ),
        @usdTotalSell = SUM(
            CASE 
                WHEN invoice.currencyCode = 'USD' THEN items.calculationPriceUnitary * items.quantity
                ELSE 0
            END
        ),
        @mxnTotalCost = SUM(
            CASE 
                WHEN invoice.currencyCode = 'MXN' THEN items.calculationCostUnitary * items.quantity
                ELSE 0
            END
        ),
        @usdTotalCost = SUM(
            CASE 
                WHEN invoice.currencyCode = 'USD' THEN items.calculationCostUnitary * items.quantity
                ELSE 0
            END
        ),
        @reportTotalSell=SUM(
            CASE 
                WHEN invoice.currencyCode = 'MXN' AND @reportCurrency='MXN' THEN items.calculationPriceUnitary * items.quantity
                WHEN invoice.currencyCode = 'USD' AND @reportCurrency='USD' THEN items.calculationPriceUnitary * items.quantity
                WHEN invoice.currencyCode = 'MXN' AND @reportCurrency='USD' THEN (items.calculationPriceUnitary / orden.protected) * items.quantity
                WHEN invoice.currencyCode = 'USD' AND @reportCurrency='MXN' THEN (items.calculationPriceUnitary * orden.protected) * items.quantity
                ELSE 0
            END
        ),
        @reportTotalCost=SUM(
            CASE 
                WHEN invoice.currencyCode = 'MXN' AND @reportCurrency='MXN' THEN items.calculationCostUnitary * items.quantity
                WHEN invoice.currencyCode = 'USD' AND @reportCurrency='USD' THEN items.calculationCostUnitary * items.quantity
                WHEN invoice.currencyCode = 'MXN' AND @reportCurrency='USD' THEN (items.calculationCostUnitary / orden.protected) * items.quantity
                WHEN invoice.currencyCode = 'USD' AND @reportCurrency='MXN' THEN (items.calculationCostUnitary * orden.protected) * items.quantity
                ELSE 0
            END
        )
    FROM LegalDocuments AS invoice 
    LEFT JOIN Documents AS orden ON orden.idDocument= invoice.idDocument
    LEFT JOIN Customers AS clients ON clients.customerID= invoice.idCustomer
    LEFT JOIN DocumentItems AS items ON items.document=orden.idDocument
    WHERE 
        invoice.idTypeLegalDocument=@idInvoiceTypeE
        AND invoice.idLegalDocumentStatus IN (@idStatusCxc,@idStatusPartialCxc,@idStatusChargedCxc)
        AND orden.idTypeDocument=@idDocumentType
        AND orden.idStatus= @idDocumentStatus
        AND clients.customerType= 1 
        AND clients.[status]=1
        AND items.[status]=1

    SELECT
        @mxnTotalMargin= @mxnTotalSell-@mxnTotalCost,
        @usdTotalMargin= @usdTotalSell-@usdTotalCost,
        @reportTotalMargin = @reportTotalSell - @reportTotalCost,
        @reportTotalInvoiced = @reportTotalSell







DECLARE @buyAndSelling TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idClient INT NOT NULL,
    rfc NVARCHAR(256) NOT NULL,
    socialReason NVARCHAR(256) NOT NULL,
    sellMxn DECIMAL(14,4) NOT NULL,
    costMxn DECIMAL(14,4) NOT NULL,
    sellUsd DECIMAL(14,4) NOT NULL,
    costUsd DECIMAL(14,4) NOT NULL,
    protected DECIMAL(14,4) NOT NULL,
    executive NVARCHAR(10)
)

INSERT INTO @buyAndSelling (
    idClient,
    rfc,
    socialReason,
    sellMxn,
    costMxn,
    sellUsd,
    costUsd,
    protected,
    executive
)


SELECT 
    clients.customerID,
    clients.rfc,
    clients.socialReason,
    SUM(
            CASE 
                WHEN invoice.currencyCode='MXN' THEN items.calculationPriceUnitary*items.quantity
                ELSE 0
            END
        ), -- mxnSell
        SUM(
            CASE 
                WHEN invoice.currencyCode='MXN' THEN items.calculationCostUnitary*items.quantity
                ELSE 0
            END
        ) , -- mxnCost
        SUM(
            CASE 
                WHEN invoice.currencyCode='USD' THEN items.calculationPriceUnitary*items.quantity
                ELSE 0
            END
        ),-- usdSell
        SUM(
            CASE 
                WHEN invoice.currencyCode='USD' THEN items.calculationCostUnitary*items.quantity
                ELSE 0
            END
        ), -- usdCost
        orden.protected,
        executive.initials

FROM LegalDocuments AS invoice 
LEFT JOIN Documents AS orden ON orden.idDocument= invoice.idDocument
LEFT JOIN Customers AS clients ON clients.customerID= invoice.idCustomer
LEFT JOIN DocumentItems AS items ON items.document=orden.idDocument
LEFT JOIN Customer_Executive AS executiveRelation ON executiveRelation.customerID= clients.customerID
LEFT JOIN Users AS executive ON executive.userID= executiveRelation.executiveID
WHERE 
    invoice.idTypeLegalDocument=@idInvoiceTypeE
    AND invoice.idLegalDocumentStatus IN (@idStatusCxc,@idStatusPartialCxc,@idStatusChargedCxc)
    AND orden.idTypeDocument=@idDocumentType
    AND orden.idStatus= @idDocumentStatus
    AND clients.customerType= 1 
    AND clients.[status]=1
    AND items.[status]=1
GROUP BY 
    -- executive.initials,
    clients.customerID,
    clients.rfc,
    clients.socialReason,
    orden.protected,
    executive.initials
    





 DECLARE @Pareto TABLE (
        id INT NOT NULL IDENTITY(1,1),
        executive NVARCHAR(5) NOT NULL,
        idCustomer INT NOT NULL,
        rfc NVARCHAR(128) NOT NULL,
        socialReason NVARCHAR(256) NOT NULL,
        mxnSell DECIMAL(14,4) NOT NULL,
        usdSell DECIMAL(14,4) NOT NULL,
        mxnCost DECIMAL(14,4) NOT NULL,
        usdCost DECIMAL(14,4) NOT NULL,
        mxnMargin DECIMAL(14,4) NOT NULL,
        usdMargin DECIMAL(14,4) NOT NULL,
        reportMargin DECIMAL(14,4) NOT NULL,
        reportInvoiced DECIMAL(14,4) NOT NULL,
        marginPercentage DECIMAL(14,4) NOT NULL,
        invoicedPercentage DECIMAL(14,4) NOT NULL
        
    )

    INSERT INTO @Pareto (
        executive,
        idCustomer,
        rfc,
        socialReason,
        mxnSell,
        usdSell,
        mxnCost,
        usdCost,
        mxnMargin,
        usdMargin,
        reportMargin,
        reportInvoiced,
        marginPercentage,
        invoicedPercentage
    )
    SELECT 
        executive,
        idClient,
        rfc,
        socialReason,
        sellMxn,
        sellUsd,
        costMxn,
        costUsd,
        (sellMxn - costMxn),-- mxnMargin
        (sellUsd - costUsd),-- usdMargin
        CASE
            WHEN @reportCurrency ='MXN' THEN (sellMxn - costMxn) + ((sellUsd - costUsd)*protected)
            ELSE (sellUsd - costUsd) + ((sellMxn - costMxn)/protected)
        END, -- reportMargin
        CASE 
            WHEN @reportCurrency ='MXN' THEN sellMxn + (sellUsd * protected)
            ELSE  sellUsd + (sellMxn / protected)
        END, --reportInvoiced
        ((sellMxn - costMxn) + ((sellUsd - costUsd)*protected))/@reportTotalMargin*100, --marginPercentage
        (sellMxn + (sellUsd * protected))/@reportTotalSell*100 --invoicedPercentage
    FROM @buyAndSelling
    ORDER BY 
        CASE 
            WHEN @reportType =2 THEN ((sellMxn - costMxn) + ((sellUsd - costUsd)*protected))/@reportTotalMargin 
            ELSE (sellMxn + (sellUsd * protected))/@reportTotalSell 
        END DESC

SELECT 
    *,
    CASE 
            WHEN @reportType = 2 THEN SUM(marginPercentage) OVER (ORDER BY Id)
            ELSE SUM(invoicedPercentage) OVER (ORDER BY Id)
        END AS pareto
 FROM @Pareto ORDER BY id

    -- SELECT 
    --     *,
    --     sellMxn - costMxn AS marginMxn,
    --     sellUsd - costUsd AS marginUsd,
    --     (sellMxn - costMxn) + ((sellUsd - costUsd)*protected) AS reportMargin,
    --     sellMxn + (sellUsd*protected) AS invoicedMxn,
    --     sellUsd + (sellMxn/protected) AS invoicedUsd,
    --    ( sellMxn + (sellUsd*protected)) /(@mxnTotalSell + (@usdTotalSell * protected)) *100 AS reportInvoicedPercentage,
    --    ((sellMxn - costMxn) + ((sellUsd - costUsd)*protected))/ (@mxnTotalMargin +(@usdTotalMargin*protected))*100 AS reportMarginPercentage
    --     -- @mxnTotalSell + (@usdTotalSell * 18.2) AS totalReportInvoiced,
    --     -- @mxnTotalMargin +(@usdTotalMargin*18.2) AS totalReportMargin,
    --  FROM @buyAndSelling
    -- ORDER BY ( sellMxn + (sellUsd*protected)) /(@mxnTotalSell + (@usdTotalSell * protected)) *100 DESC