SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/03/2023
-- Description: sp_GetCxcReport - Get the report of the cxp

ALTER PROCEDURE [dbo].[sp_GetCxcReport](
    @socialReason NVARCHAR(256),
    @beginDate DATETIME,
    @endDate DATETIME
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    IF(@beginDate IS NULL OR @endDate IS NULL)
        BEGIN
            SELECT 
                @beginDate =FIRST_VALUE(emited) 
            OVER (ORDER BY emited) 
            FROM CxcFullReport;
            SELECT 
                @endDate =FIRST_VALUE(emited) 
            OVER (ORDER BY emited DESC) 
            FROM CxcFullReport;
        END
    DECLARE @idInvoiceCxc INT = 7;
    DECLARE @idInvoicePartialCxc INT = 9;

    SELECT 
    cxcReport.socialReason,
    -- SUM(
    --     CASE 
    --         WHEN currency = 'MXN' AND [type]='pedido' THEN cxcReport.importe
    --         ELSE 0
    --     END
    -- ) AS mxnFacturas,
    -- SUM(
    --     CASE 
    --         WHEN currency = 'MXN' AND [type]='comprobante' THEN cxcReport.importe
    --         ELSE 0
    --     END
    -- ) AS mxnComprobantes,
    SUM(
        CASE 
            WHEN currency = 'MXN' AND [type]='pedido' THEN cxcReport.residue
            ELSE 0
        END
    ) AS mxnFacturasSaldo,
    SUM(
        CASE 
            WHEN currency = 'MXN' AND [type]='comprobante' THEN cxcReport.residue
            ELSE 0
        END
    ) AS mxnComprobantesSaldo,
    -- SUM(
    --     CASE 
    --         WHEN currency = 'USD' AND [type]='pedido' THEN cxcReport.importe
    --         ELSE 0
    --     END
    -- ) AS usdFacturas,
    -- SUM(
    --     CASE 
    --         WHEN currency = 'USD' AND [type]='comprobante' THEN cxcReport.importe
    --         ELSE 0
    --     END
    -- ) AS usdComprobantes,
    SUM(
        CASE 
            WHEN currency = 'USD' AND [type]='pedido' THEN cxcReport.residue
            ELSE 0
        END
    ) AS usdFacturasSaldo,
    SUM(
        CASE 
            WHEN currency = 'USD' AND [type]='comprobante' THEN cxcReport.residue
            ELSE 0
        END
    ) AS usdComprobantesSaldo,
    SUM(
        CASE 
            WHEN currency = 'MXN'  THEN cxcReport.totalAmount
            ELSE 0
        END
    ) AS totalMxn,
    SUM(
        CASE 
            WHEN currency = 'USD' THEN cxcReport.totalAmount
            ELSE 0
        END
    ) AS totalUsd,
    SUM(
        CASE 
            WHEN currency = 'MXN'  THEN cxcReport.residue
            ELSE 0
        END
    ) AS totalMxnResidue,
    SUM(
        CASE 
            WHEN currency = 'USD' THEN cxcReport.residue
            ELSE 0
        END
    ) AS totalUsdResidue,
    ISNULL(      (SELECT 
            cxc.id,
            
            cxc.idLegalDocument,
            cxc.currency,
            cxc.percentagePayed,
            cxc.partialitie,
            cxc.partialities,
            cxc.emited,
            cxc.expiration,
            -- cxc.importe,
            cxc.residue,
            cxc.socialReason,
            cxc.totalAmount,
            cxc.totalAcreditedAmount,
            cxc.noDocument,
            cxc.[type],
            cxc.idLegalDocumentStatus,
            cxc.uuid,
            -- pedido.documentNumber AS noPedido,
            cxc.factura AS factura,
            executive.initials AS initialsExecutive
        

        FROM CxcFullReport AS cxc
        LEFT JOIN Documents AS pedido ON pedido.uuid= cxc.uuid
        LEFT JOIN Users AS executive ON  executive.userID= pedido.idExecutive
        WHERE 
            cxc.socialReason=cxcReport.socialReason AND 
            (cxc.emited >=@beginDate AND cxc.emited <= @endDate) 
            AND pedido.idTypeDocument=2 
            AND pedido.idStatus = 5
            -- AND cxc.idLegalDocumentStatus  IN( @idInvoiceCxc,@idInvoicePartialCxc)
            
            
         FOR JSON PATH),'[]') as cxcs

    
    FROM CxcFullReport AS cxcReport
    LEFT JOIN Documents AS pedido ON pedido.uuid= cxcReport.uuid
    WHERE 
        cxcReport.socialReason LIKE ISNULL(@socialReason,'')+'%' AND 
        (CAST(cxcReport.emited  AS DATE)>=@beginDate AND CAST(cxcReport.emited AS DATE) <= @endDate) 
        AND pedido.idTypeDocument=2 
        AND pedido.idStatus = 5
        -- AND cxcReport.idLegalDocumentStatus  IN(@idInvoiceCxc,@idInvoicePartialCxc)
    GROUP BY socialReason
     FOR JSON PATH, ROOT('report')

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
GO
