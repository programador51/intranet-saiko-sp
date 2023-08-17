-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-10-2023
-- Description: Get the invoice documents
-- STORED PROCEDURE NAME:	sp_GetInvoicesDocuments
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
--	2023-02-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/10/2023
-- Description: sp_GetInvoicesDocuments - Get the invoice documents
CREATE PROCEDURE sp_GetInvoicesDocuments(
    @customerId INT,
    @statusId INT,
    @beginDate DATETIME,
    @endDate DATETIME,
    @search NVARCHAR(15),
    @pageRequested INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @noRegisters INT; -- Number of registers founded
    DECLARE @offsetValue INT;-- Since which register start searching the information
    DECLARE @totalPages DECIMAL;-- Total pages founded on the query
    DECLARE @rowsPerPage INT = 10;-- LIMIT of registers that can be returned per query


    IF @search IS NULL
        BEGIN 
            IF @customerId IS NULL
                BEGIN
                    SELECT 
                        @noRegisters = COUNT(*)
                    FROM LegalDocuments AS invoice
                    WHERE 
                        invoice.createdDate >= @beginDate AND 
                        invoice.createdDate<=@endDate AND 
                        invoice.idLegalDocumentStatus=@statusId;
                END
            ELSE
                BEGIN
                    SELECT 
                        @noRegisters = COUNT(*)
                    FROM LegalDocuments AS invoice
                    WHERE 
                        invoice.createdDate >= @beginDate AND 
                        invoice.createdDate<=@endDate AND 
                        invoice.idCustomer= @customerId AND 
                        invoice.idLegalDocumentStatus=@statusId
                END
        END
    ELSE
        BEGIN
            SELECT 
                @noRegisters = COUNT(*)
            FROM LegalDocuments AS invoice
            WHERE 
                invoice.noDocument=@search
        END

        ------------------------------------------
    
    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;

    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    IF @search IS NULL
        BEGIN 
            IF @customerId IS NULL
                BEGIN
                    SELECT  
                        invoice.createdDate AS emited,
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
                        dbo.fn_FormatCurrency(invoice.acumulated) [cobrado],
                        dbo.fn_FormatCurrency(invoice.total - invoice.acumulated) AS [saldo],
                        dbo.FormatDate(document.createdDate) AS [createdDate],
                        dbo.fn_FormatCurrency(document.subTotalAmount) AS [import],
                        dbo.fn_FormatCurrency(document.ivaAmount) AS [iva]
                    FROM LegalDocuments AS invoice
                    LEFT JOIN LegalDocumentStatus AS invoiceStatus ON invoiceStatus.id=invoice.idLegalDocumentStatus
                    LEFT JOIN Documents AS document ON document.idDocument= invoice.idDocument
                    LEFT JOIN Users AS executive ON executive.userID= document.idExecutive
                    LEFT JOIN Customers AS customer ON customer.customerID= invoice.idCustomer
                    WHERE 
                        invoice.createdDate >= @beginDate AND 
                        invoice.createdDate<=@endDate AND 
                        invoice.idLegalDocumentStatus=@statusId
                    ORDER BY invoice.noDocument ASC OFFSET @offsetValue ROWS FETCH NEXT @rowsPerPage ROWS ONLY FOR JSON PATH, INCLUDE_NULL_VALUES ,ROOT('documents');
                END
            ELSE
                BEGIN
                    SELECT  
                        invoice.createdDate AS emited,
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
                        dbo.fn_FormatCurrency(invoice.acumulated) [cobrado],
                        dbo.fn_FormatCurrency(invoice.total - invoice.acumulated) AS [saldo],
                        dbo.FormatDate(document.createdDate) AS [createdDate],
                        dbo.fn_FormatCurrency(document.subTotalAmount) AS [import],
                        dbo.fn_FormatCurrency(document.ivaAmount) AS [iva]
                    FROM LegalDocuments AS invoice
                    LEFT JOIN LegalDocumentStatus AS invoiceStatus ON invoiceStatus.id=invoice.idLegalDocumentStatus
                    LEFT JOIN Documents AS document ON document.idDocument= invoice.idDocument
                    LEFT JOIN Users AS executive ON executive.userID= document.idExecutive
                    LEFT JOIN Customers AS customer ON customer.customerID= invoice.idCustomer
                    WHERE 
                        invoice.createdDate >= @beginDate AND 
                        invoice.createdDate<=@endDate AND 
                        invoice.idCustomer= @customerId AND 
                        invoice.idLegalDocumentStatus=@statusId
                    ORDER BY invoice.noDocument ASC OFFSET @offsetValue ROWS FETCH NEXT @rowsPerPage ROWS ONLY FOR JSON PATH, INCLUDE_NULL_VALUES ,ROOT('documents');
                END
        END
    ELSE
        BEGIN
            SELECT  
                        invoice.createdDate AS emited,
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
                        dbo.fn_FormatCurrency(invoice.acumulated) [cobrado],
                        dbo.fn_FormatCurrency(invoice.total - invoice.acumulated) AS [saldo],
                        dbo.FormatDate(document.createdDate) AS [createdDate],
                        dbo.fn_FormatCurrency(document.subTotalAmount) AS [import],
                        dbo.fn_FormatCurrency(document.ivaAmount) AS [iva]
                    FROM LegalDocuments AS invoice
                    LEFT JOIN LegalDocumentStatus AS invoiceStatus ON invoiceStatus.id=invoice.idLegalDocumentStatus
                    LEFT JOIN Documents AS document ON document.idDocument= invoice.idDocument
                    LEFT JOIN Users AS executive ON executive.userID= document.idExecutive
                    LEFT JOIN Customers AS customer ON customer.customerID= invoice.idCustomer
            WHERE 
                invoice.noDocument=@search
            ORDER BY invoice.noDocument ASC OFFSET @offsetValue ROWS FETCH NEXT @rowsPerPage ROWS ONLY FOR JSON PATH, INCLUDE_NULL_VALUES ,ROOT('documents');
        END
        SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------