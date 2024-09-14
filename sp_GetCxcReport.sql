-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-03-2023
-- Description: Get the report of the cxp
-- STORED PROCEDURE NAME:	sp_GetCxcReport
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2023-07-03		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/03/2023
-- Description: sp_GetCxcReport - Get the report of the cxp

ALTER PROCEDURE sp_GetCxcReport(
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

    SELECT 
    cxcReport.socialReason,
    SUM(
        CASE 
            WHEN currency = 'MXN' AND [type]='pedido' THEN cxcReport.importe
            ELSE 0
        END
    ) AS mxnFacturas,
    SUM(
        CASE 
            WHEN currency = 'MXN' AND [type]='comprobante' THEN cxcReport.importe
            ELSE 0
        END
    ) AS mxnComprobantes,
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
    SUM(
        CASE 
            WHEN currency = 'USD' AND [type]='pedido' THEN cxcReport.importe
            ELSE 0
        END
    ) AS usdFacturas,
    SUM(
        CASE 
            WHEN currency = 'USD' AND [type]='comprobante' THEN cxcReport.importe
            ELSE 0
        END
    ) AS usdComprobantes,
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
            cxc.importe,
            cxc.residue,
            cxc.socialReason,
            cxc.totalAmount,
            cxc.totalAcreditedAmount,
            cxc.noDocument,
            cxc.[type],
            cxc.idLegalDocumentStatus,
            cxc.uuid,
            pedido.documentNumber AS noPedido,
            pedido.documentNumber AS factura,
            executive.initials AS initialsExecutive
        

        FROM CxcFullReport AS cxc
        LEFT JOIN Documents AS pedido ON pedido.uuid= cxc.uuid
        LEFT JOIN Users AS executive ON  executive.userID= pedido.idExecutive
        WHERE 
            cxc.socialReason=cxcReport.socialReason AND 
            (cxc.emited >=@beginDate AND cxc.emited <= @endDate) AND
            pedido.idTypeDocument=2 AND 
            pedido.idStatus != 6
         FOR JSON PATH),'[]') as cxcs

    
    FROM CxcFullReport AS cxcReport
    WHERE 
        socialReason LIKE ISNULL(@socialReason,'')+'%' AND 
        (emited >=@beginDate AND emited <= @endDate)
    GROUP BY socialReason
     FOR JSON PATH, ROOT('report')

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------