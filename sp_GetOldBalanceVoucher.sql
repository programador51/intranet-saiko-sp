-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-11-2023
-- Description: Get the old balances from de cxp
-- STORED PROCEDURE NAME:	sp_GetOldBalanceVoucher
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
-- Description: sp_GetOldBalanceVoucher - Get the old balances from de cxp
CREATE PROCEDURE sp_GetOldBalanceVoucher(
    @currencyToUse NVARCHAR(3),
    @currencyToReport NVARCHAR(3),
    @tc DECIMAL (14,2)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON


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

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------