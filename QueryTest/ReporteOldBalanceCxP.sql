

DECLARE @currencyToUse NVARCHAR(3)= NULL
DECLARE @currencyToReport NVARCHAR(3)='MXN'
DECLARE @tc DECIMAL (14,2)=18.5


-- SE DECLARARA UNA TABLA TEMPORAL PARA OBTENER LOS DATOS NECESRIOS PARA EL REPORTE

DECLARE @idInvoiceCancelStatus INT =5;
DECLARE @idInvoicePaidStatus INT =2;
DECLARE @idInvoiceType INT =1;

DECLARE @idCxpCancelStatus INT =23;
DECLARE @idCxpPaidStatus INT =22;
DECLARE @idCxpType INT = 4;


DECLARE @todayAsDate DATE;
DECLARE @expired1To7 DATE;
DECLARE @expired7To14 DATE;

IF(@currencyToUse IS NOT NULL)
    BEGIN
        SET @currencyToReport= @currencyToUse
    END


SELECT
    @todayAsDate= CAST(GETUTCDATE() AS DATE),
    @expired1To7= CAST(DATEADD(DAY,-7,GETUTCDATE())  AS DATE),
    @expired7To14=CAST(DATEADD(DAY,-14,GETUTCDATE())  AS DATE)



DECLARE @TempReport TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idDocument INT NOT NULL DEFAULT(-1),
    idCustomer INT,
    socialReason NVARCHAR(128),
    invoiceNumber NVARCHAR(10),
    partiality NVARCHAR(10),
    total DECIMAL(14,4),
    payed DECIMAL(14,4),
    residue DECIMAL(14,4),
    expirationDate DATETIME,
    currency NVARCHAR(3)
)

-- PRIMERA INSERSCION: Es la incersion de todas las cxp que tienen una factura fiscal recibida
INSERT INTO @TempReport
    (
    idCustomer,
    idDocument,
    socialReason,
    invoiceNumber,
    partiality,
    total,
    payed,
    residue,
    expirationDate,
    currency
    )
SELECT
    customer.customerID,
    cxp.idDocument,
    invoice.socialReason,
    -- RTRIM(customer.socialReason),
    invoice.noDocument,
    CONCAT(cxp.currectFaction,'/',cxp.factionsNumber),
    cxp.totalAmount,
    cxp.totalAcreditedAmount,
    cxp.totalAmount - ISNULL(cxp.totalAcreditedAmount,0),
    cxp.expirationDate,
    currency.code
FROM LegalDocuments AS invoice
    LEFT JOIN Documents AS cxp ON cxp.uuid = invoice.uuid
    LEFT JOIN Currencies AS currency ON currency.currencyID= cxp.idCurrency
    LEFT JOIN Customers AS customer ON customer.customerID=cxp.idCustomer
WHERE 
    invoice.idTypeLegalDocument=@idInvoiceType
    AND invoice.idLegalDocumentStatus NOT IN(@idInvoiceCancelStatus,@idInvoicePaidStatus)
    AND cxp.idStatus NOT IN (@idCxpCancelStatus,@idCxpPaidStatus)
    AND cxp.idTypeDocument= @idCxpType
    AND invoice.idConcept IS NULL
    AND invoice.currencyCode LIKE ISNULL(@currencyToUse,'') + '%';



-- SEGUNDA INCERSION: Se insertaran todas las facturas que no tenga cxp en documentos
INSERT INTO @TempReport
    (
    idCustomer,
    socialReason,
    invoiceNumber,
    partiality,
    total,
    payed,
    residue,
    expirationDate,
    currency
    )
SELECT
    ISNULL(invoice.idCustomer,-1),
    LTRIM(RTRIM(invoice.socialReason)),
    invoice.noDocument,
    '1/1',
    invoice.total,
    invoice.acumulated,
    invoice.residue,
    invoice.expirationDate,
    invoice.currencyCode
FROM LegalDocuments AS invoice
LEFT JOIN Customers AS customer ON customer.socialReason LIKE invoice.socialReason
WHERE
    invoice.idTypeLegalDocument=@idInvoiceType
    AND invoice.idLegalDocumentStatus NOT IN(@idInvoiceCancelStatus,@idInvoicePaidStatus)
    AND invoice.idConcept IS NOT NULL
    AND invoice.currencyCode LIKE ISNULL(@currencyToUse,'') + '%';

DECLARE @SocialReasonSummary TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idCustomer INT NOT NULL DEFAULT(-1),
    socialReason NVARCHAR(128),
    totalInTime DECIMAL(14,4),
    totalIn7Days DECIMAL(14,4),
    totalIn14Days DECIMAL(14,4),
    totalMore14Days DECIMAL(14,4),
    residueInTime DECIMAL(14,4),
    residueIn7Days DECIMAL(14,4),
    residueIn14Days DECIMAL(14,4),
    residueMore14Days DECIMAL(14,4),
    paiedInTime DECIMAL(14,4),
    paiedIn7Days DECIMAL(14,4),
    paiedIn14Days DECIMAL(14,4),
    paiedMore14Days DECIMAL(14,4)
)

INSERT INTO @SocialReasonSummary
    (
    socialReason,
    totalInTime,
    totalIn7Days,
    totalIn14Days,
    totalMore14Days,
    residueInTime,
    residueIn7Days,
    residueIn14Days,
    residueMore14Days,
    paiedInTime,
    paiedIn7Days,
    paiedIn14Days,
    paiedMore14Days
    )
SELECT
    RTRIM(socialReason),
    SUM(
        CASE 
            WHEN CAST(expirationDate AS DATE) >=@todayAsDate 
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,total,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN (CAST(expirationDate AS DATE) <@todayAsDate AND CAST(expirationDate AS DATE) >= @expired1To7) 
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,total,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN (CAST(expirationDate AS DATE) <@expired1To7 AND CAST(expirationDate AS DATE) >= @expired7To14 )
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,total,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN CAST(expirationDate AS DATE) <@expired7To14 
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,total,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN CAST(expirationDate AS DATE) >=@todayAsDate 
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,residue,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN (CAST(expirationDate AS DATE) <@todayAsDate AND CAST(expirationDate AS DATE) >= @expired1To7 )
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,residue,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN (CAST(expirationDate AS DATE) <@expired1To7 AND CAST(expirationDate AS DATE) >= @expired7To14 )
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,residue,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN CAST(expirationDate AS DATE) <@expired7To14 
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,residue,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN CAST(expirationDate AS DATE) >=@todayAsDate 
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,payed,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN (CAST(expirationDate AS DATE) <@todayAsDate AND CAST(expirationDate AS DATE) >= @expired1To7 )
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,payed,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN (CAST(expirationDate AS DATE) <@expired1To7 AND CAST(expirationDate AS DATE) >= @expired7To14 )
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,payed,@tc)
            ELSE 0
        END
    ),
    SUM(
        CASE 
            WHEN CAST(expirationDate AS DATE) <@expired7To14 
                THEN dbo.fn_currencyConvertion(currency,@currencyToReport,payed,@tc)
            ELSE 0
        END
    )
FROM @TempReport
GROUP BY socialReason



-- SELECT * FROM @SocialReasonSummary


DECLARE @TempIntime TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idDocument INT NOT NULL DEFAULT(-1),
    idCustomer INT,
    socialReason NVARCHAR(128),
    invoiceNumber NVARCHAR(10),
    partiality NVARCHAR(10),
    total DECIMAL(14,4),
    payed DECIMAL(14,4),
    residue DECIMAL(14,4),
    expirationDate DATETIME,
    currency NVARCHAR(3)
)

INSERT INTO @TempIntime (
    idDocument,
    idCustomer,
    socialReason,
    invoiceNumber,
    partiality,
    total,
    payed,
    residue,
    expirationDate,
    currency
)
 SELECT
    tempReport.idDocument,
    tempReport.idCustomer,
    tempReport.socialReason,
    tempReport.invoiceNumber,
    tempReport.partiality,
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.total,@tc),
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.payed,@tc),
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.residue,@tc),
    tempReport.expirationDate,
    tempReport.currency

FROM @TempReport AS tempReport
WHERE 
    CAST(tempReport.expirationDate AS DATE) >=@todayAsDate

DECLARE @TempIn7Days TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idDocument INT NOT NULL DEFAULT(-1),
    idCustomer INT,
    socialReason NVARCHAR(128),
    invoiceNumber NVARCHAR(10),
    partiality NVARCHAR(10),
    total DECIMAL(14,4),
    payed DECIMAL(14,4),
    residue DECIMAL(14,4),
    expirationDate DATETIME,
    currency NVARCHAR(3)
)

INSERT INTO @TempIn7Days (
    idDocument,
    idCustomer,
    socialReason,
    invoiceNumber,
    partiality,
    total,
    payed,
    residue,
    expirationDate,
    currency
)
 SELECT
    tempReport.idDocument,
    tempReport.idCustomer,
    tempReport.socialReason,
    tempReport.invoiceNumber,
    tempReport.partiality,
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.total,@tc),
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.payed,@tc),
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.residue,@tc),
    tempReport.expirationDate,
    tempReport.currency
FROM @TempReport AS tempReport
WHERE 
    CAST(tempReport.expirationDate AS DATE) <@todayAsDate 
    AND CAST(tempReport.expirationDate AS DATE) >= @expired1To7

    SELECT * FROM @TempIn7Days

DECLARE @TempIn14Days TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idDocument INT NOT NULL DEFAULT(-1),
    idCustomer INT,
    socialReason NVARCHAR(128),
    invoiceNumber NVARCHAR(10),
    partiality NVARCHAR(10),
    total DECIMAL(14,4),
    payed DECIMAL(14,4),
    residue DECIMAL(14,4),
    expirationDate DATETIME,
    currency NVARCHAR(3)
)

INSERT INTO @TempIn14Days (
    idDocument,
    idCustomer,
    socialReason,
    invoiceNumber,
    partiality,
    total,
    payed,
    residue,
    expirationDate,
    currency
)
 SELECT
    tempReport.idDocument,
    tempReport.idCustomer,
    tempReport.socialReason,
    tempReport.invoiceNumber,
    tempReport.partiality,
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.total,@tc),
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.payed,@tc),
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.residue,@tc),
    tempReport.expirationDate,
    tempReport.currency
FROM @TempReport AS tempReport
WHERE 
    CAST(tempReport.expirationDate AS DATE) <@expired1To7 
    AND CAST(tempReport.expirationDate AS DATE) >= @expired7To14

DECLARE @TempMore14Days TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idDocument INT NOT NULL DEFAULT(-1),
    idCustomer INT,
    socialReason NVARCHAR(128),
    invoiceNumber NVARCHAR(10),
    partiality NVARCHAR(10),
    total DECIMAL(14,4),
    payed DECIMAL(14,4),
    residue DECIMAL(14,4),
    expirationDate DATETIME,
    currency NVARCHAR(3)
)

INSERT INTO @TempMore14Days (
    idDocument,
    idCustomer,
    socialReason,
    invoiceNumber,
    partiality,
    total,
    payed,
    residue,
    expirationDate,
    currency
)
 SELECT
    tempReport.idDocument,
    tempReport.idCustomer,
    tempReport.socialReason,
    tempReport.invoiceNumber,
    tempReport.partiality,
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.total,@tc),
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.payed,@tc),
    dbo.fn_currencyConvertion(currency,@currencyToReport,tempReport.residue,@tc),
    tempReport.expirationDate,
    tempReport.currency
FROM @TempReport AS tempReport
WHERE 
    CAST(tempReport.expirationDate AS DATE) <@expired7To14 





SELECT
    sumary.socialReason AS [socialReason],
    -1 AS [idCustomer],
    (
        SELECT
            insideSumary.residueInTime AS [residue],
            ISNULL(
                (
                    SELECT
                        inTime.invoiceNumber AS [invoiceNumber],
                        inTime.partiality AS [partiality],
                        inTime.idDocument AS [idDocument],
                        inTime.total AS [total],
                        inTime.payed AS [payed],
                        inTime.residue AS [residue],
                        inTime.expirationDate AS [expirationDate],
                        @currencyToReport AS [currencyToReport],
                        inTime.currency AS [currencyDocument],
                        @tc AS [tcUsed]
                    FROM @TempIntime AS inTime
                    WHERE 
                        inTime.socialReason= sumary.socialReason
                    ORDER BY 
                        inTime.expirationDate
                    FOR JSON PATH
                ),
                '[]'
            ) AS [invoice]
        FROM @SocialReasonSummary AS insideSumary
        WHERE insideSumary.id=sumary.id
    FOR JSON PATH
    ) AS [inTime],
    (
        SELECT
            insideSumary.residueIn7Days AS [residue],
            ISNULL(
                (
                    SELECT
                        inTime7.invoiceNumber AS [invoiceNumber],
                        inTime7.partiality AS [partiality],
                        inTime7.idDocument AS [idDocument],
                        inTime7.total AS [total],
                        inTime7.payed AS [payed],
                        inTime7.residue AS [residue],
                        inTime7.expirationDate AS [expirationDate],
                        @currencyToReport AS [currencyToReport],
                        inTime7.currency AS [currencyDocument],
                        @tc AS [tcUsed]
                    FROM @TempIn7Days AS inTime7
                    WHERE 
                        inTime7.socialReason = sumary.socialReason
                    ORDER BY 
                        inTime7.expirationDate
                    FOR JSON PATH
                ),
                '[]'
            ) AS [invoice]
        FROM @SocialReasonSummary AS insideSumary
        WHERE insideSumary.id=sumary.id
    FOR JSON PATH
    ) AS [expired1To7],
    (
        SELECT
            insideSumary.residueIn14Days AS [residue],
            ISNULL(
                (
                    SELECT
                        inTime14.invoiceNumber AS [invoiceNumber],
                        inTime14.partiality AS [partiality],
                        inTime14.idDocument AS [idDocument],
                        inTime14.total AS [total],
                        inTime14.payed AS [payed],
                        inTime14.residue AS [residue],
                        inTime14.expirationDate AS [expirationDate],
                        @currencyToReport AS [currencyToReport],
                        inTime14.currency AS [currencyDocument],
                        @tc AS [tcUsed]
                    FROM @TempIn14Days AS inTime14
                    WHERE 
                        inTime14.socialReason= sumary.socialReason
                    ORDER BY 
                        inTime14.expirationDate
                    FOR JSON PATH
                ),
                '[]'
            ) AS [invoice]
        FROM @SocialReasonSummary AS insideSumary
        WHERE insideSumary.id=sumary.id
    FOR JSON PATH
    ) AS [expired7To14],
    (
        SELECT
            insideSumary.residueMore14Days AS [residue],
            ISNULL(
                (
                    SELECT
                        more14.invoiceNumber AS [invoiceNumber],
                        more14.partiality AS [partiality],
                        more14.idDocument AS [idDocument],
                        more14.total AS [total],
                        more14.payed AS [payed],
                        more14.residue AS [residue],
                        more14.expirationDate AS [expirationDate],
                        @currencyToReport AS [currencyToReport],
                        more14.currency AS [currencyDocument],
                        @tc AS [tcUsed]
                    FROM @TempMore14Days AS more14
                    WHERE 
                        more14.socialReason= sumary.socialReason
                    ORDER BY 
                        more14.expirationDate
                    FOR JSON PATH
                ),
                '[]'
            ) AS [invoice]
        FROM @SocialReasonSummary AS insideSumary
        WHERE insideSumary.id=sumary.id
    FOR JSON PATH
    ) AS [expiredMore14]

FROM @SocialReasonSummary AS sumary
ORDER BY sumary.socialReason
FOR JSON PATH, ROOT('oldBalance')

