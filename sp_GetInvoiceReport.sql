-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-28-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetInvoiceReport
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
-- Description: sp_GetInvoiceReport - Some Notes
ALTER PROCEDURE sp_GetInvoiceReport(
    @customerId INT,
    @statusId INT,
    @beginDate DATE,
    @endDate DATE,
    @search NVARCHAR(15)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    SELECT  
    invoice.createdDate AS emited,
    invoice.[xml] AS [xml],
    invoice.pdf AS [pdf],
    document.idDocument AS idPreinvoice,
    invoice.id AS id,
    invoice.uuid AS uuid,
    invoice.noDocument AS [numeroDocumento],
    invoice.currencyCode AS [moneda],
    invoiceStatus.[description] AS [status.description],
    invoiceStatus.id AS [status.id],
    invoice.total AS [total.numero],
    dbo.fn_FormatCurrency(invoice.total ) AS [total.texto],
    dbo.FormatDate(invoice.createdDate) AS [registro.formated],
    dbo.FormatDateYYYMMDD(invoice.createdDate) AS [registro.yyyymmdd],
    dbo.FormatDate(invoice.expirationDate) AS [facturar.formated],
    dbo.FormatDateYYYMMDD(invoice.expirationDate) AS [facturar.yyyymmdd],
    CASE 
        WHEN invoice.expirationDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(invoice.expirationDate)
    END AS [expirationDateFl],
    CASE 
        WHEN invoice.createdDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(invoice.createdDate)
    END AS [emitedDateFl],
    executive.initials AS [iniciales],
    invoiceStatus.[description] AS [estatus],
    customer.socialReason AS [razonSocial],
    customer.socialReason AS [customer.socialReason],
    customer.customerID AS [customer.id],
    dbo.fn_FormatCurrency(document.totalAcreditedAmount) [cobrado],
    dbo.fn_FormatCurrency(invoice.total - document.totalAcreditedAmount) AS [saldo],
    dbo.FormatDate(document.createdDate) AS [createdDate],
    dbo.fn_FormatCurrency(document.subTotalAmount) AS [import],
    dbo.fn_FormatCurrency(document.ivaAmount) AS [iva]

    FROM LegalDocuments AS invoice
    LEFT JOIN LegalDocumentStatus AS invoiceStatus ON invoiceStatus.id=invoice.idLegalDocumentStatus
    LEFT JOIN Documents AS document ON document.idDocument= invoice.idDocument
    LEFT JOIN Users AS executive ON executive.userID= document.idExecutive
    LEFT JOIN Customers AS customer ON customer.customerID= invoice.idCustomer

    WHERE 
        (CAST(invoice.createdDate AS DATE) >= @beginDate AND CAST(invoice.createdDate AS DATE)<=@endDate) AND
        invoice.idCustomer IN (
            SELECT 
                CASE
                    WHEN @customerId IS NULL THEN customerID
                    ELSE @customerId
                END
            FROM Customers
        ) AND
        invoice.idLegalDocumentStatus IN (
            SELECT 
                CASE 
                    WHEN @statusId IS NULL THEN id
                    ELSE @statusId
                END
            FROM LegalDocumentStatus WHERE [status]=1 AND idTypeLegalDocumentType=2
        ) AND
        invoice.noDocument LIKE ISNULL(@search,'') + '%'
        FOR JSON PATH, ROOT('invoices'), INCLUDE_NULL_VALUES



END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------