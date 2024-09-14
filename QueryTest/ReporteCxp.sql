

--------------------------------------------------------------------------------------
SELECT 
    headInvoice.socialReason AS [socialReason],
    SUM(
        CASE
            WHEN headInvoice.currencyCode='MXN' THEN total
            ELSE 0
        END
    ) AS mxnImport,
    SUM(
        CASE
            WHEN headInvoice.currencyCode='USD' THEN total
            ELSE 0
        END
    ) AS usdImport,
    (
        SELECT 
            cxpReport.socialReason,
            cxpReport.id,
            cxpReport.totalAmount,
            cxpReport.importe,
            cxpReport.residue,
            cxpReport.currency,
            cxpReport.totalAcreditedAmount,
            CASE 
                WHEN cxpReport.totalAcreditedAmount = 0 THEN 0
                ELSE cxpReport.totalAcreditedAmount /cxpReport.totalAmount
            END  AS percentagePayed,
            cxpReport.noDocument,
            cxpReport.emited,
            cxpReport.partialitie,
            CONCAT(cxpReport.partialitie , '/',cxpReport.partialities) AS partialities,
            cxpReport.expiration,
            cxpReport.[type],
            cxpReport.uuid
        FROM CxpFullReport AS cxpReport
        WHERE headInvoice.socialReason= cxpReport.socialReason
        FOR JSON PATH
    ) AS cxp

FROM LegalDocuments AS headInvoice
WHERE 
    headInvoice.idTypeLegalDocument=1 AND 
    headInvoice.idLegalDocumentStatus!=5
GROUP BY headInvoice.socialReason
FOR JSON PATH, ROOT('report')
