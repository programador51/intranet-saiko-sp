
    DECLARE @currencyToUse NVARCHAR(3)=NULL;
    DECLARE @currencyToReport NVARCHAR(3)='USD';
    DECLARE @tc DECIMAL (14,2)= 20

    DECLARE @todayAsDate DATE;

    DECLARE @expired1To7 DATE;
    DECLARE @expired7To14 DATE;

    SELECT 
        @todayAsDate= CAST(GETUTCDATE() AS DATE),
        @expired1To7= CAST(DATEADD(DAY,-7,GETUTCDATE())  AS DATE),
        @expired7To14=CAST(DATEADD(DAY,-14,GETUTCDATE())  AS DATE)

SELECT 
    cxp.socialReason AS [socialReason],
    -1 AS idCustomer,
    CASE 
        WHEN CAST(cxp.expirationDate AS DATE) >=@todayAsDate THEN  dbo.fn_currencyConvertion(cxp.currencyCode,@currencyToReport,cxp.residue,@tc)
        ELSE 0
    END AS [inTiem.residue],
    ISNULL(
        (
        SELECT 
            subCxp.noDocument AS invoiceNumber,
            '1/1' AS partiality,
            subCxp.id AS idDocument,
            subCxp.total AS total,
            subCxp.acumulated AS payed,
            subCxp.residue AS residue,
            subCxp.expirationDate AS expirationDate,
            @currencyToReport AS currencyToReport,
            subCxp.currencyCode AS currencyDocument,
            @tc AS tcUsed
        FROM LegalDocuments subCxp
        WHERE 
            subCxp.id = cxp.id AND
            CAST(cxp.expirationDate AS DATE) >=@todayAsDate
        FOR JSON PATH
    ),
    '[]') AS [inTiem.invoice],
    CASE 
        WHEN (CAST(cxp.expirationDate AS DATE) <@todayAsDate AND 
            CAST(cxp.expirationDate AS DATE) >= @expired1To7) THEN  dbo.fn_currencyConvertion(cxp.currencyCode,@currencyToReport,cxp.residue,@tc)
        ELSE 0
    END AS [expired1To7.residue],
    ISNULL(
        (
        SELECT 
            subCxp.noDocument AS invoiceNumber,
            '1/1' AS partiality,
            subCxp.id AS idDocument,
            subCxp.total AS total,
            subCxp.acumulated AS payed,
            subCxp.residue AS residue,
            subCxp.expirationDate AS expirationDate,
            @currencyToReport AS currencyToReport,
            subCxp.currencyCode AS currencyDocument,
            @tc AS tcUsed
        FROM LegalDocuments subCxp
        WHERE 
            subCxp.id = cxp.id AND
            (CAST(cxp.expirationDate AS DATE) <@todayAsDate AND 
            CAST(cxp.expirationDate AS DATE) >= @expired1To7)
        FOR JSON PATH
    ),
    '[]') AS [expired1To7.invoice],
    CASE 
        WHEN (CAST(cxp.expirationDate AS DATE) <@expired1To7 AND 
            CAST(cxp.expirationDate AS DATE) >= @expired7To14) THEN  dbo.fn_currencyConvertion(cxp.currencyCode,@currencyToReport,cxp.residue,@tc)
        ELSE 0
    END AS [expired7To14.residue],
    ISNULL(
        (
        SELECT 
            subCxp.noDocument AS invoiceNumber,
            '1/1' AS partiality,
            subCxp.id AS idDocument,
            subCxp.total AS total,
            subCxp.acumulated AS payed,
            subCxp.residue AS residue,
            subCxp.expirationDate AS expirationDate,
            @currencyToReport AS currencyToReport,
            subCxp.currencyCode AS currencyDocument,
            @tc AS tcUsed
        FROM LegalDocuments subCxp
        WHERE 
            subCxp.id = cxp.id AND
            (CAST(cxp.expirationDate AS DATE) <@expired1To7 AND 
            CAST(cxp.expirationDate AS DATE) >= @expired7To14)
        FOR JSON PATH
    ),
    '[]') AS [expired7To14.invoice],
    CASE 
        WHEN CAST(cxp.expirationDate AS DATE) <@expired7To14 THEN  dbo.fn_currencyConvertion(cxp.currencyCode,@currencyToReport,cxp.residue,@tc)
        ELSE 0
    END AS [expiredMore14.residue],
        ISNULL(
        (
        SELECT 
            subCxp.noDocument AS invoiceNumber,
            '1/1' AS partiality,
            subCxp.id AS idDocument,
            subCxp.total AS total,
            subCxp.acumulated AS payed,
            subCxp.residue AS residue,
            subCxp.expirationDate AS expirationDate,
            @currencyToReport AS currencyToReport,
            subCxp.currencyCode AS currencyDocument,
            @tc AS tcUsed
        FROM LegalDocuments subCxp
        WHERE 
            subCxp.id = cxp.id AND
            CAST(cxp.expirationDate AS DATE) <@expired7To14
        FOR JSON PATH
    ),
    '[]') AS [expiredMore14.invoice]
FROM LegalDocuments AS cxp
WHERE 
    cxp.idConcept IS NOT NULL AND
    cxp.uuidReference IS NULL AND
    cxp.idTypeAssociation = 2
FOR JSON PATH, ROOT('oldBalanceVoucher')