    
    DECLARE @currencyToUse NVARCHAR(3)=NULL;
    DECLARE @currencyToReport NVARCHAR(3)='USD';
    DECLARE @tc DECIMAL (14,2)= 20
    
    DECLARE @idCustomerType INT =2;
    DECLARE @statusActive TINYINT=1;
    DECLARE @idInvoiceType INT = 1;
    DECLARE @invoiceStatusCancel INT = 5;
    DECLARE @idDocumentType INT =4;
    DECLARE @cxcStatusCancel INT =23;
    DECLARE @idUsdCurrency INT = 2;
    DECLARE @idMxnCurrency INT = 1;



    DECLARE @todayAsDate DATE;

    DECLARE @expired1To7 DATE;
    DECLARE @expired7To14 DATE;

    SELECT 
        @todayAsDate= CAST(GETUTCDATE() AS DATE),
        @expired1To7= CAST(DATEADD(DAY,-7,GETUTCDATE())  AS DATE),
        @expired7To14=CAST(DATEADD(DAY,-14,GETUTCDATE())  AS DATE)


SELECT DISTINCT
    customer.socialReason AS socialReason,
    customer.customerID AS idCustomer,
    (
        SELECT
            ISNULL(SUM(dbo.fn_currencyConvertion(currency.code,@currencyToReport,subCxp.amountToPay,@tc)),0) AS residue,
            
            (
                ISNULL(
                        (
                            SELECT 
                                invoices.noDocument AS invoiceNumber,
                                CONCAT(cxpDetails.currectFaction,'/',cxpDetails.factionsNumber) AS partiality,
                                cxpDetails.idDocument,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxpDetails.totalAmount,@tc) AS total,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxpDetails.totalAcreditedAmount,@tc) AS payed,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,CAST((cxpDetails.totalAmount - cxpDetails.totalAcreditedAmount) AS DECIMAL(14,2)),@tc) AS residue,
                                cxpDetails.expirationDate,
                                @currencyToReport AS currencyToReport,
                                currency.code AS currencyDocument,
                                @tc AS tcUsed
                            FROM Documents AS cxpDetails 
                            LEFT JOIN LegalDocuments AS invoices ON cxpDetails.uuid = invoices.uuid
                            LEFT JOIN Currencies AS currency ON currency.currencyID= cxpDetails.idCurrency
                            WHERE 
                                cxpDetails.idCustomer=customer.customerID AND
                                CAST(cxpDetails.expirationDate AS DATE) >=@todayAsDate AND
                                cxpDetails.idCurrency=@idUsdCurrency AND
                                cxpDetails.idTypeDocument=@idDocumentType AND
                                cxpDetails.idStatus != @cxcStatusCancel AND
                                currency.code LIKE ISNULL(@currencyToUse,'') + '%'
                            FOR JSON PATH
                        ),
                    '[]'
                    )
            ) AS [invoice]
        FROM Documents AS subCxp 
        LEFT JOIN Currencies AS currency ON currency.currencyID= subCxp.idCurrency
        WHERE 
            subCxp.idCustomer=customer.customerID AND
            CAST(subCxp.expirationDate AS DATE) >=@todayAsDate AND
            subCxp.idCurrency=@idUsdCurrency AND
            subCxp.idTypeDocument=@idDocumentType AND
            subCxp.idStatus != @cxcStatusCancel AND
            currency.code LIKE ISNULL(@currencyToUse,'') + '%'
        FOR JSON PATH 
    ) AS [inTime],
    (
        SELECT 
            ISNULL(SUM(dbo.fn_currencyConvertion(currency.code,@currencyToReport,subCxp.amountToPay,@tc)),0) AS residue,
            (
                ISNULL(
                        (
                            SELECT 
                                invoices.noDocument AS invoiceNumber,
                                CONCAT(cxpDetails.currectFaction,'/',cxpDetails.factionsNumber) AS partiality,
                                cxpDetails.idDocument,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxpDetails.totalAmount,@tc) AS total,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxpDetails.totalAcreditedAmount,@tc) AS payed,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,CAST((cxpDetails.totalAmount - cxpDetails.totalAcreditedAmount) AS DECIMAL(14,2)),@tc) AS residue,
                                cxpDetails.expirationDate,
                                @currencyToReport AS currencyToReport,
                                currency.code AS currencyDocument,
                                @tc AS tcUsed
                            FROM Documents AS cxpDetails 
                            LEFT JOIN LegalDocuments AS invoices ON cxpDetails.uuid = invoices.uuid
                            LEFT JOIN Currencies AS currency ON currency.currencyID= cxpDetails.idCurrency
                            WHERE 
                                cxpDetails.idCustomer=customer.customerID AND
                                (CAST(cxpDetails.expirationDate AS DATE) <@todayAsDate AND 
                                CAST(cxpDetails.expirationDate AS DATE) >= @expired1To7) AND
                                cxpDetails.idCurrency=@idUsdCurrency AND
                                cxpDetails.idTypeDocument=@idDocumentType AND
                                cxpDetails.idStatus != @cxcStatusCancel AND
                                currency.code LIKE ISNULL(@currencyToUse,'') + '%'
                            FOR JSON PATH
                        ),
                    '[]'
                    )
            ) AS [invoice]
        FROM Documents AS subCxp 
        LEFT JOIN Currencies AS currency ON currency.currencyID= subCxp.idCurrency
        WHERE 
            subCxp.idCustomer=customer.customerID AND
            (CAST(subCxp.expirationDate AS DATE) <@todayAsDate AND 
            CAST(subCxp.expirationDate AS DATE) >= @expired1To7) AND
            subCxp.idCurrency=@idUsdCurrency AND
            subCxp.idTypeDocument=@idDocumentType AND
            subCxp.idStatus != @cxcStatusCancel AND
            currency.code LIKE ISNULL(@currencyToUse,'') + '%'
        FOR JSON PATH
    ) AS [expired1To7],
    (
        SELECT 
            ISNULL(SUM(dbo.fn_currencyConvertion(currency.code,@currencyToReport,subCxp.amountToPay,@tc)),0) AS residue,
            (
                ISNULL(
                        (
                            SELECT 
                                invoices.noDocument AS invoiceNumber,
                                CONCAT(cxpDetails.currectFaction,'/',cxpDetails.factionsNumber) AS partiality,
                                cxpDetails.idDocument,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxpDetails.totalAmount,@tc) AS total,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxpDetails.totalAcreditedAmount,@tc) AS payed,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,CAST((cxpDetails.totalAmount - cxpDetails.totalAcreditedAmount) AS DECIMAL(14,2)),@tc) AS residue,
                                cxpDetails.expirationDate,
                                @currencyToReport AS currencyToReport,
                                currency.code AS currencyDocument,
                                @tc AS tcUsed
                            FROM Documents AS cxpDetails 
                            LEFT JOIN LegalDocuments AS invoices ON cxpDetails.uuid = invoices.uuid
                            LEFT JOIN Currencies AS currency ON currency.currencyID= cxpDetails.idCurrency
                            WHERE 
                                cxpDetails.idCustomer=customer.customerID AND
                                (CAST(cxpDetails.expirationDate AS DATE) <@expired1To7 AND 
                                CAST(cxpDetails.expirationDate AS DATE) >= @expired7To14) AND
                                cxpDetails.idCurrency=@idUsdCurrency AND
                                cxpDetails.idTypeDocument=@idDocumentType AND
                                cxpDetails.idStatus != @cxcStatusCancel AND
                                currency.code LIKE ISNULL(@currencyToUse,'') + '%'
                            FOR JSON PATH
                        ),
                    '[]'
                    )
            ) AS [invoice]
        FROM Documents AS subCxp 
        LEFT JOIN Currencies AS currency ON currency.currencyID= subCxp.idCurrency
        WHERE 
            subCxp.idCustomer=customer.customerID AND
            (CAST(subCxp.expirationDate AS DATE) <@expired1To7 AND 
            CAST(subCxp.expirationDate AS DATE) >= @expired7To14) AND
            subCxp.idCurrency=@idUsdCurrency AND
            subCxp.idTypeDocument=@idDocumentType AND
            subCxp.idStatus != @cxcStatusCancel AND
            currency.code LIKE ISNULL(@currencyToUse,'') + '%'
        FOR JSON PATH 
    ) AS [expired7To14],
    (
        SELECT 
            ISNULL(SUM(dbo.fn_currencyConvertion(currency.code,@currencyToReport,subCxp.amountToPay,@tc)),0) AS residue,
            (
                ISNULL(
                        (
                            SELECT 
                                invoices.noDocument AS invoiceNumber,
                                CONCAT(cxpDetails.currectFaction,'/',cxpDetails.factionsNumber) AS partiality,
                                cxpDetails.idDocument,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxpDetails.totalAmount,@tc) AS total,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxpDetails.totalAcreditedAmount,@tc) AS payed,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,CAST((cxpDetails.totalAmount - cxpDetails.totalAcreditedAmount) AS DECIMAL(14,2)),@tc) AS residue,
                                cxpDetails.expirationDate,
                                @currencyToReport AS currencyToReport,
                                currency.code AS currencyDocument,
                                @tc AS tcUsed
                            FROM Documents AS cxpDetails 
                            LEFT JOIN LegalDocuments AS invoices ON cxpDetails.uuid = invoices.uuid
                            LEFT JOIN Currencies AS currency ON currency.currencyID= cxpDetails.idCurrency
                            WHERE 
                                cxpDetails.idCustomer=customer.customerID AND
                                CAST(cxpDetails.expirationDate AS DATE) <@expired7To14 AND
                                cxpDetails.idCurrency=@idUsdCurrency AND
                                cxpDetails.idTypeDocument=@idDocumentType AND
                                cxpDetails.idStatus != @cxcStatusCancel AND
                                currency.code LIKE ISNULL(@currencyToUse,'') + '%'
                            FOR JSON PATH
                        ),
                    '[]'
                    )
            ) AS [invoice]
        FROM Documents AS subCxp 
        LEFT JOIN Currencies AS currency ON currency.currencyID= subCxp.idCurrency
        WHERE 
            subCxp.idCustomer=customer.customerID AND
            CAST(subCxp.expirationDate AS DATE) <@expired7To14 AND
            subCxp.idCurrency=@idUsdCurrency AND
            subCxp.idTypeDocument=@idDocumentType AND
            subCxp.idStatus != @cxcStatusCancel AND
            currency.code LIKE ISNULL(@currencyToUse,'') + '%'
        FOR JSON PATH 
    ) AS [expiredMore14]

FROM Customers AS customer
LEFT JOIN LegalDocuments AS invoice ON invoice.socialReason = customer.socialReason
LEFT JOIN Documents AS cxp ON cxp.idCustomer=customer.customerID
LEFT JOIN Currencies AS currency ON currency.currencyID= cxp.idCurrency
WHERE 
    customer.customerType =@idCustomerType AND
    customer.[status] =@statusActive AND
    cxp.idTypeDocument=@idDocumentType AND
    cxp.idStatus != @cxcStatusCancel AND
    currency.code LIKE ISNULL(@currencyToUse,'') + '%'
GROUP BY 
    customer.socialReason,
    customer.customerID
FOR JSON PATH, ROOT('oldBalance'), INCLUDE_NULL_VALUES