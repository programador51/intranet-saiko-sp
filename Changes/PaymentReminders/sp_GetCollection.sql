-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-19-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetCollection
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
--	2024-03-19		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCollection')
    BEGIN 

        DROP PROCEDURE sp_GetCollection;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/19/2024
-- Description: sp_GetCollection - Some Notes
CREATE PROCEDURE sp_GetCollection(
    @date DATE,
    @tag INT,
    @page INT,
    @columnOrder NVARCHAR(50),
    @orderBy NVARCHAR(4)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    DECLARE @offset INT;
    DECLARE @noRegisters INT;
    DECLARE @pages INT;
    DECLARE @rowsPerPage INT = 100;

    SELECT DISTINCT
        @noRegisters = COUNT(*) 
    FROM PaymentReminder AS paymentReminder
    LEFT JOIN Customers AS client ON client.customerID = paymentReminder.idClient
    LEFT JOIN LegalDocuments AS invoice ON invoice.id= paymentReminder.idInvoice
    LEFT JOIN Contacts AS contact ON contact.email = paymentReminder.email
    WHERE 
        paymentReminder.indexDate = @date
        -- AND paymentReminder.idTag IN (
        --     CASE 
        --         WHEN @tag IS NULL THEN (SELECT id FROM PaymentReminderTags)
        --         ELSE @tag
        --     END
        -- )


    SELECT @offset = (@page - 1) * @rowsPerPage;

    SELECT @pages = CEILING((@noRegisters*1.0)/@rowsPerPage);


    SELECT 
        invoice.noDocument AS [folio],
        invoice.createdDate AS [createdDate],
        invoice.expirationDate AS [expiration],
        DATEDIFF(day,invoice.expirationDate,invoice.createdDate) AS [expirationDays],
        paymentReminder.idRule AS [rule],
        paymentReminder.currency AS [currency],
        paymentReminder.total AS [total],
        executive.initials AS [executive],
        client.customerID AS [customer.id],
        client.shortName AS [customer.shortName],
        client.socialReason AS [customer.socialReason],
        CONCAT('+',client.ladaPhone,' ',client.phone) AS [customer.phone],
        client.email AS [customer.email],
        paymentReminder.contact AS [contact.fullName],
        paymentReminder.phone AS [contact.phone],
        paymentReminder.email AS [contact.email],
        contact.contactID AS [contact.id]

    FROM PaymentReminder AS paymentReminder
    LEFT JOIN Customers AS client ON client.customerID = paymentReminder.idClient
    LEFT JOIN LegalDocuments AS invoice ON invoice.id= paymentReminder.idInvoice
    LEFT JOIN Contacts AS contact ON contact.email = paymentReminder.email
    LEFT JOIN Documents AS orden ON orden.idDocument = invoice.idDocument
    LEFT JOIN Users AS executive ON executive.userID = orden.idExecutive
    WHERE 
        paymentReminder.indexDate = @date
        -- AND paymentReminder.idTag IN (
        --     CASE 
        --         WHEN @tag IS NULL THEN (SELECT id FROM PaymentReminderTags)
        --         ELSE @tag
        --     END
        -- )

    ORDER BY 
        CASE WHEN @orderBy = 'ASC' THEN
            CASE 
                WHEN @columnOrder='folio' THEN invoice.noDocument
                WHEN @columnOrder='expedicion' THEN CAST(invoice.createdDate AS nvarchar(50))
                WHEN @columnOrder='expiracion' THEN CAST(invoice.expirationDate AS nvarchar(50))
                WHEN @columnOrder='vencidos' THEN DATEDIFF(day,invoice.expirationDate,invoice.createdDate)
                WHEN @columnOrder='regla' THEN paymentReminder.idRule
                WHEN @columnOrder='cliente' THEN client.shortName
                WHEN @columnOrder='total' THEN paymentReminder.total
                WHEN @columnOrder='tag' THEN paymentReminder.idTag
            END
        END ASC,
        CASE WHEN @orderBy = 'DESC' THEN
            CASE 
                WHEN @columnOrder='folio' THEN invoice.noDocument
                WHEN @columnOrder='expedicion' THEN CAST(invoice.createdDate AS nvarchar(50))
                WHEN @columnOrder='expiracion' THEN CAST(invoice.expirationDate AS nvarchar(50))
                WHEN @columnOrder='vencidos' THEN DATEDIFF(day,invoice.expirationDate,invoice.createdDate)
                WHEN @columnOrder='regla' THEN paymentReminder.idRule
                WHEN @columnOrder='cliente' THEN client.shortName
                WHEN @columnOrder='total' THEN paymentReminder.total
                WHEN @columnOrder='tag' THEN paymentReminder.idTag
            END
        END DESC
    OFFSET @offset ROWS FETCH NEXT @rowsPerPage ROWS ONLY
    FOR JSON PATH, ROOT('paymentReminder')

    SELECT @pages AS pages;
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------