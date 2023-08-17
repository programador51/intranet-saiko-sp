DECLARE @beginDate DATETIME='2023-01-01';
DECLARE @endDate DATETIME='2023-12-30';
DECLARE @status INT=NULL;
DECLARE @search NVARCHAR(256)=NULL;

SELECT @endDate = DATEADD(ms, 86399997, @endDate );


IF OBJECT_ID(N'tempdb..#Customer') IS NOT NULL 
        BEGIN
            DROP TABLE #Customer
        END

CREATE TABLE #Customer
        (
            id INT NOT NULL IDENTITY(1,1),
            idProvider INT,
            providerSocialReason NVARCHAR(256), 
            -- clientSocialreason NVARCHAR(256)
        )

INSERT INTO #Customer (
    idProvider,
    providerSocialReason
    -- clientSocialreason
)
SELECT 
    provaider.customerID,
    provaider.socialReason
FROM Customers AS provaider

WHERE provaider.customerID IN (
    SELECT  DISTINCT
        odc.idCustomer,
        provaider.socialReason
    FROM Documents AS odc
    LEFT JOIN Customers AS provaider ON provaider.customerID=odc.idCustomer
    WHERE 
        odc.idTypeDocument = 3 AND
        odc.idStatus LIKE ISNULL(@status,'')+'%' AND
        (odc.createdDate >= @beginDate AND odc.createdDate<=@endDate)
)
-- LEFT JOIN Customer AS client ON client




----------------------------------------------------------
SELECT
    provaider.providerSocialReason,
    client.socialReason

FROM #Customer AS provaider
LEFT JOIN Documents AS odc ON odc.idCustomer = provaider.idProvider
LEFT JOIN Documents AS quote ON quote.idDocument= odc.idQuotation
LEFT JOIN Customers AS client ON client.customerID= quote.idCustomer
LEFT JOIN LegalDocuments AS invoice ON invoice.uuid = odc.uuid
WHERE 
    (
        odc.documentNumber LIKE ISNULL(@search,'')+'%' OR
        client.socialReason LIKE ISNULL(@search,'')+'%' OR
        invoice.noDocument LIKE ISNULL(@search,'')+'%'
    )















SELECT 
    customer.socialReason AS providerSocialReason,
    client.socialReason AS clientSocialReason,
    (
        SELECT 
            odc.documentNumber AS documentNumber,
            ISNULL(invoice.noDocument,'ND') AS folio,
            odc.createdDate AS emitedDate,
            odc.sentDate AS sendDate,
            odc.subTotalAmount AS importe,
            odc.ivaAmount AS iva,
            odc.totalAmount AS total,
            currency.code AS currency
        FROM Documents AS odc
        LEFT JOIN LegalDocuments AS invoice ON  invoice.uuid=odc.uuid
        LEFT JOIN Customers AS subCustomer ON subCustomer.customerID= odc.idCustomer
        LEFT JOIN Currencies AS currency ON currency.currencyID=odc.idCurrency
        WHERE 
            subCustomer.socialReason= customer.socialReason AND 
            (odc.createdDate >= @beginDate AND odc.createdDate<=@endDate) AND
            odc.idStatus IN (
                SELECT 
                    CASE 
                        WHEN @status IS NULL THEN id
                        ELSE @status
                    END
                FROM DocumentNewStatus WHERE idDocumentType = 3 AND [status]=1
            ) AND 
            (
                odc.documentNumber LIKE ISNULL(@search,'')+'%' OR
                customer.socialReason LIKE ISNULL(@search,'')+'%' OR
                invoice.noDocument LIKE ISNULL(@search,'')+'%'
            )
        ORDER BY 
            odc.idDocument 
        FOR JSON PATH
    ) AS odc
 FROM Documents AS odcReport
 LEFT JOIN Customers AS customer ON customer.customerID=odcReport.idCustomer
 LEFT JOIN Documents AS document ON document.idQuotation= odcReport.idQuotation
 LEFT JOIN Customers AS client ON client.customerID=document.idCustomer 
 LEFT JOIN Currencies AS currency ON currency.currencyID=odcReport.idCurrency
 LEFT JOIN LegalDocuments AS invoice ON  invoice.uuid=odcReport.uuid
 WHERE 
    odcReport.idTypeDocument=3 AND 
    (odcReport.createdDate >= @beginDate AND odcReport.createdDate<=@endDate) AND
    odcReport.idStatus IN (
        SELECT 
            CASE 
                WHEN @status IS NULL THEN id
                ELSE @status
            END
        FROM DocumentNewStatus WHERE idDocumentType = 3 AND [status]=1
    ) AND 
    (
        odcReport.documentNumber LIKE ISNULL(@search,'')+'%' OR
        customer.socialReason LIKE ISNULL(@search,'')+'%' OR
        invoice.noDocument LIKE ISNULL(@search,'')+'%'
    )
GROUP BY 
    customer.socialReason,
    client.socialReason
FOR JSON PATH, ROOT('odcReport')