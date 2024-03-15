-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-07-2023
-- Description: Get the old balance from the cxc with the cxc details
-- STORED PROCEDURE NAME:	sp_GetOldBalanceCxc
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2023-09-07		Adrian Alardin   			1.0.0.0			Initial Revision	
--	2023-09-08		Adrian Alardin   			1.0.0.1			It change to get to a specific currency
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/07/2023
-- Description: sp_GetOldBalanceCxc - Get the old balance from the cxc with the cxc details
ALTER PROCEDURE sp_GetOldBalanceCxc (
    @currencyToUse NVARCHAR(3),
    @currencyToReport NVARCHAR(3),
    @tc DECIMAL (14,2)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @idCustomerType INT =1;
    DECLARE @statusActive TINYINT=1;
    DECLARE @idInvoiceType INT = 2;
    DECLARE @invoiceStatusCancel INT = 8;
    DECLARE @idDocumentType INT =5;
    DECLARE @cxcStatusCancel INT =19;
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
            ISNULL(SUM(dbo.fn_currencyConvertion(currency.code,@currencyToReport,subCxc.amountToPay,@tc)),0) AS residue,
            
            (
                ISNULL(
                        (
                            SELECT 
                                invoices.noDocument AS invoiceNumber,
                                CONCAT(cxcDetails.currectFaction,'/',cxcDetails.factionsNumber) AS partiality,
                                cxcDetails.idDocument,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxcDetails.totalAmount,@tc) AS total,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxcDetails.totalAcreditedAmount,@tc) AS payed,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,CAST((cxcDetails.totalAmount - cxcDetails.totalAcreditedAmount) AS DECIMAL(14,2)),@tc) AS residue,
                                cxcDetails.expirationDate,
                                @currencyToReport AS currencyToReport,
                                currency.code AS currencyDocument,
                                @tc AS tcUsed
                            FROM Documents AS cxcDetails 
                            LEFT JOIN LegalDocuments AS invoices ON cxcDetails.uuid = invoices.uuid
                            LEFT JOIN Currencies AS currency ON currency.currencyID= cxcDetails.idCurrency
                            WHERE 
                                cxcDetails.idCustomer=customer.customerID AND
                                CAST(cxcDetails.expirationDate AS DATE) >=@todayAsDate AND
                                cxcDetails.idCurrency=@idUsdCurrency AND
                                cxcDetails.idTypeDocument=@idDocumentType AND
                                cxcDetails.idStatus != @cxcStatusCancel AND
                                currency.code LIKE ISNULL(@currencyToUse,'') + '%'
                            FOR JSON PATH
                        ),
                    '[]'
                    )
            ) AS [invoice]
        FROM Documents AS subCxc 
        LEFT JOIN Currencies AS currency ON currency.currencyID= subCxc.idCurrency
        WHERE 
            subCxc.idCustomer=customer.customerID AND
            CAST(subCxc.expirationDate AS DATE) >=@todayAsDate AND
            subCxc.idCurrency=@idUsdCurrency AND
            subCxc.idTypeDocument=@idDocumentType AND
            subCxc.idStatus != @cxcStatusCancel AND
            currency.code LIKE ISNULL(@currencyToUse,'') + '%'
        FOR JSON PATH 
    ) AS [inTime],
    (
        SELECT 
            ISNULL(SUM(dbo.fn_currencyConvertion(currency.code,@currencyToReport,subCxc.amountToPay,@tc)),0) AS residue,
            (
                ISNULL(
                        (
                            SELECT 
                                invoices.noDocument AS invoiceNumber,
                                CONCAT(cxcDetails.currectFaction,'/',cxcDetails.factionsNumber) AS partiality,
                                cxcDetails.idDocument,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxcDetails.totalAmount,@tc) AS total,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxcDetails.totalAcreditedAmount,@tc) AS payed,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,CAST((cxcDetails.totalAmount - cxcDetails.totalAcreditedAmount) AS DECIMAL(14,2)),@tc) AS residue,
                                cxcDetails.expirationDate,
                                @currencyToReport AS currencyToReport,
                                currency.code AS currencyDocument,
                                @tc AS tcUsed
                            FROM Documents AS cxcDetails 
                            LEFT JOIN LegalDocuments AS invoices ON cxcDetails.uuid = invoices.uuid
                            LEFT JOIN Currencies AS currency ON currency.currencyID= cxcDetails.idCurrency
                            WHERE 
                                cxcDetails.idCustomer=customer.customerID AND
                                (CAST(cxcDetails.expirationDate AS DATE) <@todayAsDate AND 
                                CAST(cxcDetails.expirationDate AS DATE) >= @expired1To7) AND
                                cxcDetails.idCurrency=@idUsdCurrency AND
                                cxcDetails.idTypeDocument=@idDocumentType AND
                                cxcDetails.idStatus != @cxcStatusCancel AND
                                currency.code LIKE ISNULL(@currencyToUse,'') + '%'
                            FOR JSON PATH
                        ),
                    '[]'
                    )
            ) AS [invoice]
        FROM Documents AS subCxc 
        LEFT JOIN Currencies AS currency ON currency.currencyID= subCxc.idCurrency
        WHERE 
            subCxc.idCustomer=customer.customerID AND
            (CAST(subCxc.expirationDate AS DATE) <@todayAsDate AND 
            CAST(subCxc.expirationDate AS DATE) >= @expired1To7) AND
            subCxc.idCurrency=@idUsdCurrency AND
            subCxc.idTypeDocument=@idDocumentType AND
            subCxc.idStatus != @cxcStatusCancel AND
            currency.code LIKE ISNULL(@currencyToUse,'') + '%'
        FOR JSON PATH
    ) AS [expired1To7],
    (
        SELECT 
            ISNULL(SUM(dbo.fn_currencyConvertion(currency.code,@currencyToReport,subCxc.amountToPay,@tc)),0) AS residue,
            (
                ISNULL(
                        (
                            SELECT 
                                invoices.noDocument AS invoiceNumber,
                                CONCAT(cxcDetails.currectFaction,'/',cxcDetails.factionsNumber) AS partiality,
                                cxcDetails.idDocument,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxcDetails.totalAmount,@tc) AS total,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxcDetails.totalAcreditedAmount,@tc) AS payed,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,CAST((cxcDetails.totalAmount - cxcDetails.totalAcreditedAmount) AS DECIMAL(14,2)),@tc) AS residue,
                                cxcDetails.expirationDate,
                                @currencyToReport AS currencyToReport,
                                currency.code AS currencyDocument,
                                @tc AS tcUsed
                            FROM Documents AS cxcDetails 
                            LEFT JOIN LegalDocuments AS invoices ON cxcDetails.uuid = invoices.uuid
                            LEFT JOIN Currencies AS currency ON currency.currencyID= cxcDetails.idCurrency
                            WHERE 
                                cxcDetails.idCustomer=customer.customerID AND
                                (CAST(cxcDetails.expirationDate AS DATE) <@expired1To7 AND 
                                CAST(cxcDetails.expirationDate AS DATE) >= @expired7To14) AND
                                cxcDetails.idCurrency=@idUsdCurrency AND
                                cxcDetails.idTypeDocument=@idDocumentType AND
                                cxcDetails.idStatus != @cxcStatusCancel AND
                                currency.code LIKE ISNULL(@currencyToUse,'') + '%'
                            FOR JSON PATH
                        ),
                    '[]'
                    )
            ) AS [invoice]
        FROM Documents AS subCxc 
        LEFT JOIN Currencies AS currency ON currency.currencyID= subCxc.idCurrency
        WHERE 
            subCxc.idCustomer=customer.customerID AND
            (CAST(subCxc.expirationDate AS DATE) <@expired1To7 AND 
            CAST(subCxc.expirationDate AS DATE) >= @expired7To14) AND
            subCxc.idCurrency=@idUsdCurrency AND
            subCxc.idTypeDocument=@idDocumentType AND
            subCxc.idStatus != @cxcStatusCancel AND
            currency.code LIKE ISNULL(@currencyToUse,'') + '%'
        FOR JSON PATH 
    ) AS [expired7To14],
    (
        SELECT 
            ISNULL(SUM(dbo.fn_currencyConvertion(currency.code,@currencyToReport,subCxc.amountToPay,@tc)),0) AS residue,
            (
                ISNULL(
                        (
                            SELECT 
                                invoices.noDocument AS invoiceNumber,
                                CONCAT(cxcDetails.currectFaction,'/',cxcDetails.factionsNumber) AS partiality,
                                cxcDetails.idDocument,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxcDetails.totalAmount,@tc) AS total,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,cxcDetails.totalAcreditedAmount,@tc) AS payed,
                                dbo.fn_currencyConvertion(currency.code,@currencyToReport,CAST((cxcDetails.totalAmount - cxcDetails.totalAcreditedAmount) AS DECIMAL(14,2)),@tc) AS residue,
                                cxcDetails.expirationDate,
                                @currencyToReport AS currencyToReport,
                                currency.code AS currencyDocument,
                                @tc AS tcUsed
                            FROM Documents AS cxcDetails 
                            LEFT JOIN LegalDocuments AS invoices ON cxcDetails.uuid = invoices.uuid
                            LEFT JOIN Currencies AS currency ON currency.currencyID= cxcDetails.idCurrency
                            WHERE 
                                cxcDetails.idCustomer=customer.customerID AND
                                CAST(cxcDetails.expirationDate AS DATE) <@expired7To14 AND
                                cxcDetails.idCurrency=@idUsdCurrency AND
                                cxcDetails.idTypeDocument=@idDocumentType AND
                                cxcDetails.idStatus != @cxcStatusCancel AND
                                currency.code LIKE ISNULL(@currencyToUse,'') + '%'
                            FOR JSON PATH
                        ),
                    '[]'
                    )
            ) AS [invoice]
        FROM Documents AS subCxc 
        LEFT JOIN Currencies AS currency ON currency.currencyID= subCxc.idCurrency
        WHERE 
            subCxc.idCustomer=customer.customerID AND
            CAST(subCxc.expirationDate AS DATE) <@expired7To14 AND
            subCxc.idCurrency=@idUsdCurrency AND
            subCxc.idTypeDocument=@idDocumentType AND
            subCxc.idStatus != @cxcStatusCancel AND
            currency.code LIKE ISNULL(@currencyToUse,'') + '%'
        FOR JSON PATH 
    ) AS [expiredMore14]

FROM Customers AS customer
LEFT JOIN LegalDocuments AS invoice ON invoice.idCustomer = customer.customerID
LEFT JOIN Documents AS cxc ON cxc.idCustomer=customer.customerID
LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
WHERE 
    customer.customerType =@idCustomerType AND
    customer.[status] =@statusActive AND
    cxc.idTypeDocument=@idDocumentType AND
    cxc.idStatus != @cxcStatusCancel AND
    currency.code LIKE ISNULL(@currencyToUse,'') + '%'
GROUP BY 
    customer.socialReason,
    customer.customerID
FOR JSON PATH, ROOT('oldBalance'), INCLUDE_NULL_VALUES


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------