SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[CxcFullReport]
AS

SELECT 
    Documents.idDocument AS id,
    LegalDocuments.id AS idLegalDocument,
    LegalDocuments.noDocument AS noDocument,
    
    CASE
        WHEN Documents.idCurrency = 2 THEN
            'USD'
        ELSE
            'MXN'
    END AS currency,
    CAST(ROUND(
                    100
                    - ROUND(
                            100
                            * (ROUND(
                                        ROUND(Documents.totalAmount, 4)
                                        - ROUND(Documents.totalAcreditedAmount, 4),
                                        4
                                    )
                                ) / ROUND(Documents.totalAmount, 4),
                            4
                        ),
                    4
                ) AS DECIMAL(14, 4)) AS percentagePayed,
    Documents.currectFaction AS partialitie,
    Documents.partialitiesRequested AS partialities,
    Documents.createdDate AS emited,
    Documents.expirationDate AS expiration,
    -- (
    --     Documents.totalAmount - (
    --         (
    --             CASE 
    --                 WHEN LegalDocuments.ivaTraslados IS NULL OR LegalDocuments.ivaTraslados =0 THEN LegalDocuments.iva
    --                 ELSE LegalDocuments.ivaTraslados
    --             END +
    --             ISNULL(LegalDocuments.isrTraslados,0) +
    --             ISNULL(LegalDocuments.iepsTraslados,0)
    --         )/(SELECT COUNT(*) FROM Documents AS subcxp WHERE subcxp.uuid=LegalDocuments.uuid)
    --     )
    -- ) AS importe,
    ROUND(Documents.totalAmount - Documents.totalAcreditedAmount, 4) AS residue,
    Customers.socialReason AS [socialReason],
    Documents.totalAmount,
    Documents.totalAcreditedAmount,
    LegalDocuments.noDocument AS factura,
    'pedido' AS type,
    LegalDocuments.idLegalDocumentStatus,
    LegalDocuments.uuid

    FROM LegalDocuments
    JOIN Documents ON Documents.uuid = LegalDocuments.uuid
    JOIN Customers ON Documents.idCustomer = Customers.customerID
    WHERE 
        LegalDocuments.idTypeLegalDocument = 2 AND
        LegalDocuments.idLegalDocumentStatus IN (7,9)  AND
        Documents.idTypeDocument = 5 AND
        Documents.idStatus NOT IN (18,19,16,17)  AND
        LegalDocuments.idConcept IS NUll 

UNION ALL

SELECT 
    LegalDocuments.id AS id,
    LegalDocuments.id AS idLegalDocument,
    LegalDocuments.noDocument AS noDocument,
    LegalDocuments.currencyCode AS currency,
    (LegalDocuments.acumulated/LegalDocuments.total )*100 AS percentagePayes,
    1 AS partialitie,
    1 AS partialities,
    LegalDocuments.createdDate AS emited,
    LegalDocuments.expirationDate AS expiration,
    -- LegalDocuments.import AS importe,
    LegalDocuments.residue AS residue,
    LegalDocuments.socialReason AS socialReason,
    LegalDocuments.total AS totalAmount,
    0 AS totalAcreditedAmount,
    LegalDocuments.noDocument AS factura,
    'comprobante' AS type,
    LegalDocuments.idLegalDocumentStatus,
    LegalDocuments.uuid
FROM LegalDocuments
WHERE 
    LegalDocuments.idLegalDocumentStatus NOT IN (8,10)  AND
    LegalDocuments.idConcept IS NOT NULL AND 
    LegalDocuments.uuidReference IS NULL
GO
