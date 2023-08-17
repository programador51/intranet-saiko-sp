-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-13-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetOdcConcecutive
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
--	2023-07-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/13/2023
-- Description: sp_GetOdcConcecutive - Some Notes
ALTER PROCEDURE sp_GetOdcConcecutive(
    @beginDate DATETIME,
    @endDate DATETIME,
    @status INT,
    @search NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT
        provaider.socialReason AS providerSocialReason,
        client.socialReason AS clientSocialReason,
        ISNULL((
            SELECT
            odcSub.documentNumber AS documentNumber,
            provaiderSub.socialReason AS providerSocialReason,
            ISNULL(invoice.noDocument,'ND') AS folio,
            odcSub.createdDate AS emitedDate,
            odcSub.sentDate AS sendDate,
            odcSub.subTotalAmount AS importe,
            odcSub.ivaAmount AS iva,
            odcSub.totalAmount AS total,
            currencySub.code AS currency
        FROM Documents AS odcSub
        LEFT JOIN LegalDocuments AS invoiceSub ON  invoiceSub.uuid=odcSub.uuid
        LEFT JOIN Customers AS provaiderSub ON provaiderSub.customerID= odcSub.idCustomer
        LEFT JOIN Documents AS quoteSub ON quoteSub.idDocument= odcSub.idQuotation
        LEFT JOIN Currencies AS currencySub ON currencySub.currencyID=odcSub.idCurrency
        WHERE 
            (odcSub.createdDate >= @beginDate AND odcSub.createdDate<=@endDate) AND
            -- provaiderSub.socialReason=provaider.socialReason AND
            odcSub.idStatus IN (
                SELECT 
                    CASE 
                        WHEN @status IS NULL THEN id
                        ELSE @status
                    END
                FROM DocumentNewStatus WHERE idDocumentType = 3 AND [status]=1
            ) AND 
            (
                odcSub.documentNumber LIKE ISNULL(@search,'')+'%' OR
                invoiceSub.noDocument LIKE ISNULL(@search,'')+'%' OR
                provaiderSub.socialReason LIKE ISNULL(@search,'')+'%'
            )
        ORDER BY 
            odcSub.documentNumber
        FOR JSON PATH, INCLUDE_NULL_VALUES
        ),'[]') AS [odc]
    FROM Documents AS odc
    LEFT JOIN LegalDocuments AS invoice ON  invoice.uuid=odc.uuid
    LEFT JOIN Customers AS provaider ON provaider.customerID= odc.idCustomer
    LEFT JOIN Documents AS quote ON quote.idDocument= odc.idQuotation
    LEFT JOIN Customers AS client ON client.customerID = quote.idCustomer
    LEFT JOIN Currencies AS currency ON currency.currencyID=odc.idCurrency
    WHERE 
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
            provaider.socialReason LIKE ISNULL(@search,'')+'%' OR
            invoice.noDocument LIKE ISNULL(@search,'')+'%'
        )
    ORDER BY 
        odc.documentNumber
    FOR JSON PATH, ROOT('report')

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------


