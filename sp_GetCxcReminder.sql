-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-08-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetCxcReminder
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
--	2024-03-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCxcReminder')
    BEGIN 

        DROP PROCEDURE sp_GetCxcReminder;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/08/2024
-- Description: sp_GetCxcReminder - Some Notes
CREATE PROCEDURE sp_GetCxcReminder AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @idInvoiceType INT =2;
    DECLARE @idInvoiceCxcStatus INT =7;
    DECLARE @idInvoicePartialStatus INT =9;
    DECLARE @today DATETIME = GETUTCDATE();

    DECLARE @idActive INT =1 
    DECLARE @idCustomerType INT =1;
    DECLARE @isForPayments BIT =1



    -- Obtiene las facturas que venceran durante el mes, pero no tiene facturas expiradas
    SELECT 
        superCustomer.socialReason,
        (
            SELECT 
                invoice.noDocument AS noDocument,
                dbo.FormatDate(invoice.createdDate) AS createdDate,
                dbo.FormatDate(invoice.expirationDate) AS expirationDate,
                invoice.currencyCode AS currency,
                FORMAT(invoice.total , 'C', 'es-MX') AS total,
                FORMAT(invoice.residue, 'C', 'es-MX') AS residue
            FROM LegalDocuments AS invoice
            LEFT JOIN Customers AS client ON client.customerID= invoice.idCustomer
            WHERE 
                client.customerID = superCustomer.customerID
                AND invoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
                FOR JSON PATH
        ) AS invoice,
        ISNULL(
            (
            SELECT 
                    contact.email AS Email,
                    CONCAT(contact.firstName,' ',ISNULL(contact.middleName,''),' ', contact.lastName1,' ',contact.lastName2)AS [Name]
                    FROM Contacts AS contact 
                    LEFT JOIN Customers AS customer ON customer.customerID = contact.customerID
                    WHERE 
                        customer.customerID = superCustomer.customerID
                        AND contact.isForPayments = @isForPayments
                        AND contact.[status]=@idActive
                    FOR JSON PATH, INCLUDE_NULL_VALUES
        ),
        (
            SELECT 
                insideCustomer.email AS Email,
                insideCustomer.socialReason AS [Name]
            FROM Customers AS insideCustomer 
            WHERE
                insideCustomer.customerID= superCustomer.customerID
            FOR JSON PATH, INCLUDE_NULL_VALUES
        )
        )
        AS contact
    FROM Customers AS superCustomer
    LEFT JOIN LegalDocuments AS superInvoice ON superInvoice.idCustomer= superCustomer.customerID
    WHERE 
        superCustomer.[status]= @idActive
        AND superCustomer.customerType= @idCustomerType
        AND DATEDIFF(day,superInvoice.expirationDate,@today)<=0
        AND superInvoice.idTypeLegalDocument= @idInvoiceType
        AND superInvoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
        AND superInvoice.idCustomer IS NOT NULL
    FOR JSON PATH,ROOT('payment1')



    SELECT 
        superCustomer.socialReason,
        (
            SELECT 
                invoice.noDocument AS noDocument,
                dbo.FormatDate(invoice.createdDate) AS createdDate,
                dbo.FormatDate(invoice.expirationDate) AS expirationDate,
                invoice.currencyCode AS currency,
                FORMAT(invoice.total , 'C', 'es-MX') AS total,
                FORMAT(invoice.residue, 'C', 'es-MX') AS residue
            FROM LegalDocuments AS invoice
            LEFT JOIN Customers AS client ON client.customerID= invoice.idCustomer
            WHERE 
                client.customerID = superCustomer.customerID
                AND invoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
            FOR JSON PATH
        ) AS invoice,
        ISNULL(
            (
            SELECT 
                    contact.email AS Email,
                    CONCAT(contact.firstName,' ',ISNULL(contact.middleName,''),' ', contact.lastName1,' ',contact.lastName2)AS [Name]
                    FROM Contacts AS contact 
                    LEFT JOIN Customers AS customer ON customer.customerID = contact.customerID
                    WHERE 
                        customer.customerID = superCustomer.customerID
                        AND contact.isForPayments = @isForPayments
                        AND contact.[status]=@idActive
                    FOR JSON PATH, INCLUDE_NULL_VALUES
        ),
        (
            SELECT 
                insideCustomer.email AS Email,
                insideCustomer.socialReason AS [Name]
            FROM Customers AS insideCustomer 
            WHERE
                insideCustomer.customerID= superCustomer.customerID
            FOR JSON PATH, INCLUDE_NULL_VALUES
        )
        )
        AS contact
    FROM Customers AS superCustomer
    LEFT JOIN LegalDocuments AS superInvoice ON superInvoice.idCustomer= superCustomer.customerID
    WHERE 
        superCustomer.[status]=@idActive
        AND superCustomer.customerType=@idCustomerType
        and DATEDIFF(day,superInvoice.expirationDate,@today)>30
        AND DATEDIFF(day,superInvoice.expirationDate,@today)<=60
        AND superInvoice.idTypeLegalDocument=@idInvoiceType
        AND superInvoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
        AND superInvoice.idCustomer IS NOT NULL
    FOR JSON PATH,ROOT('payment2')

    SELECT 
        superCustomer.socialReason,
        (
            SELECT 
                invoice.noDocument AS noDocument,
                dbo.FormatDate(invoice.createdDate) AS createdDate,
                dbo.FormatDate(invoice.expirationDate) AS expirationDate,
                invoice.currencyCode AS currency,
                FORMAT(invoice.total , 'C', 'es-MX') AS total,
                FORMAT(invoice.residue, 'C', 'es-MX') AS residue
            FROM LegalDocuments AS invoice
            LEFT JOIN Customers AS client ON client.customerID= invoice.idCustomer
            WHERE 
                client.customerID = superCustomer.customerID
                AND invoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
            FOR JSON PATH
        ) AS invoice,
       ISNULL(
            (
            SELECT 
                    contact.email AS Email,
                    CONCAT(contact.firstName,' ',ISNULL(contact.middleName,''),' ', contact.lastName1,' ',contact.lastName2)AS [Name]
                    FROM Contacts AS contact 
                    LEFT JOIN Customers AS customer ON customer.customerID = contact.customerID
                    WHERE 
                        customer.customerID = superCustomer.customerID
                        AND contact.isForPayments = @isForPayments
                        AND contact.[status]=@idActive
                    FOR JSON PATH, INCLUDE_NULL_VALUES
        ),
        (
            SELECT 
                insideCustomer.email AS Email,
                insideCustomer.socialReason AS [Name]
            FROM Customers AS insideCustomer 
            WHERE
                insideCustomer.customerID= superCustomer.customerID
            FOR JSON PATH, INCLUDE_NULL_VALUES
        )
        )
        AS contact
    
    FROM Customers AS superCustomer
    LEFT JOIN LegalDocuments AS superInvoice ON superInvoice.idCustomer= superCustomer.customerID
    WHERE 
        superCustomer.[status]=@idActive
        AND superCustomer.customerType=@idCustomerType
        AND DATEDIFF(day,superInvoice.expirationDate,@today)>60
        AND superInvoice.idTypeLegalDocument=@idInvoiceType
        AND superInvoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
        AND superInvoice.idCustomer IS NOT NULL
    FOR JSON PATH,ROOT('payment3')


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------