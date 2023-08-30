-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-28-2023
-- Description: Get the invoice reception report
-- STORED PROCEDURE NAME:	sp_GetInvoiceReceptionreport
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
--	2023-08-28		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/28/2023
-- Description: sp_GetInvoiceReceptionreport - Get the invoice reception report
ALTER PROCEDURE sp_GetInvoiceReceptionreport(
    @querySearch NVARCHAR(256),
    @idLegalDocumentStatus INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idInvoiceType INT=1;

    IF OBJECT_ID(N'tempdb..#TempStatus') IS NOT NULL 
        BEGIN
            DROP TABLE #TempStatus
        END

    CREATE TABLE #TempStatus (
        id INT NOT NULL IDENTITY(1,1),
        idStatus INT NOT NULL
    )
    IF (@idLegalDocumentStatus IS NULL)
        BEGIN
            INSERT INTO #TempStatus (
                idStatus
            )
            SELECT id
            FROM LegalDocumentStatus WHERE [status]=1 AND idTypeLegalDocumentType=1
        END
    IF(@idLegalDocumentStatus = 20)
        BEGIN
            INSERT INTO #TempStatus (idStatus)
            VALUES
            (1),
            (11)
        END
    ELSE
        BEGIN
            INSERT INTO #TempStatus (idStatus)
            VALUES(@idLegalDocumentStatus)
        END

    SELECT 
        invoice.emitedDate, 
        invoice.xml,
        invoice.pdf, 
        invoice.expirationDate ,
        invoice.id, 
        invoice.currencyCode AS currency , 
        invoice.idLegalDocumentStatus,
        dbo.fn_FormatCurrency(invoice.discount) AS discount, 
        dbo.fn_FormatCurrency(invoice.ivaTraslados) AS ivaTraslados, 
        CASE 
            WHEN invoice.acumulated = 0 THEN CONVERT(BIT,1) 
            ELSE CONVERT(BIT,0) 
        END AS isCancellable, 
        invoice.socialReason , 
        invoice.noDocument ,
        dbo.fn_FormatCurrency(invoice.import) AS import, 
        dbo.fn_FormatCurrency(invoice.residue) AS saldo, 
        dbo.fn_FormatCurrency(invoice.applied) AS cobrado ,
        dbo.fn_FormatCurrency(invoice.iva) AS iva, 
        dbo.fn_FormatCurrency(invoice.total) AS total ,
        LegalDocumentStatus.description, 
        invoice.iepsTraslados + invoice.ivaTraslados AS traslados, 
        invoice.ivaRetenidos + invoice.isrRetenidos + invoice.iepsRetenidos AS retenidos , 
        invoice.idLegalDocumentProvider AS customerId,
        invoice.uuid, 
        ISNULL(customer.commercialName,invoice.socialReason) AS comertialName  
        FROM LegalDocuments AS invoice
        
        INNER JOIN LegalDocumentStatus on invoice.idLegalDocumentStatus = LegalDocumentStatus.id 
        LEFT JOIN Customers AS customer ON customer.customerID=invoice.idCustomer
        WHERE 
            invoice.idTypeLegalDocument =@idInvoiceType AND
            (invoice.noDocument LIKE ISNULL(@querySearch,'') + '%' OR
            invoice.socialReason LIKE ISNULL(@querySearch,'') + '%' ) AND
            invoice.idLegalDocumentStatus IN (SELECT idStatus FROM #TempStatus)
IF OBJECT_ID(N'tempdb..#TempStatus') IS NOT NULL 
        BEGIN
            DROP TABLE #TempStatus
        END

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------