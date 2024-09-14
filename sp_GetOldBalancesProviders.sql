-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-11-2023
-- Description: Get the old balances from de cxp
-- STORED PROCEDURE NAME:	sp_GetOldBalancesProviders
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
--	2023-09-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/11/2023
-- Description: sp_GetOldBalancesProviders - Get the old balances from de cxp
ALTER PROCEDURE sp_GetOldBalancesProviders(
    @currencyToUse NVARCHAR(3),
    @currencyToReport NVARCHAR(3),
    @tc DECIMAL (14,2)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
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
                            FOR JSON PATH,INCLUDE_NULL_VALUES
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
        FOR JSON PATH,INCLUDE_NULL_VALUES
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
                            FOR JSON PATH,INCLUDE_NULL_VALUES
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
        FOR JSON PATH,INCLUDE_NULL_VALUES
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
                            FOR JSON PATH,INCLUDE_NULL_VALUES
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
        FOR JSON PATH,INCLUDE_NULL_VALUES
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
                            FOR JSON PATH,INCLUDE_NULL_VALUES
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
        FOR JSON PATH,INCLUDE_NULL_VALUES
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
FOR JSON PATH, ROOT('oldBalanceProvider'), INCLUDE_NULL_VALUES

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------