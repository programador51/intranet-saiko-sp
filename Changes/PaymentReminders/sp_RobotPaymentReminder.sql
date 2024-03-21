-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-15-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_RobotPaymentReminder
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
--	2024-03-15		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_RobotPaymentReminder')
    BEGIN 

        DROP PROCEDURE sp_RobotPaymentReminder;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/15/2024
-- Description: sp_RobotPaymentReminder - Some Notes
CREATE PROCEDURE sp_RobotPaymentReminder AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @today DATE = CAST(GETUTCDATE() AS DATE);
    DECLARE @reminders PaymentReminderType;

    DECLARE @idInvoiceType INT =2;
    DECLARE @idInvoiceCxcStatus INT =7;
    DECLARE @idInvoicePartialStatus INT =9;


    DECLARE @idActive INT =1 
    DECLARE @idCustomerType INT =1;
    DECLARE @isForPayments BIT =1

    DECLARE @tempClients TABLE (
        id INT NOT NULL IDENTITY(1,1),
        idClient INT NOT NULL,
        idContact INT NOT NULL,
        contact NVARCHAR(128),
        phone NVARCHAR(50),
        email NVARCHAR(50)
        
    )

    INSERT INTO @tempClients (
        idClient,
        idContact,
        contact,
        phone,
        email
    )
    SELECT 
        client.customerID,
        ISNULL(
            (
            SELECT 
                TOP(1)  contact.contactID
            FROM Contacts AS contact
            WHERE 
                contact.customerID = client.customerID
                AND contact.isForPayments = @isForPayments
                AND contact.[status]=@idActive
        ),
        -1
        ),
        ISNULL(
            (
            SELECT 
                TOP(1)  CONCAT(contact.firstName,' ',ISNULL(contact.middleName,''),' ', contact.lastName1,' ',contact.lastName2)
            FROM Contacts AS contact
            WHERE 
                contact.customerID = client.customerID
                AND contact.isForPayments = @isForPayments
                AND contact.[status]=@idActive
        ),
        client.socialReason
        ),
        ISNULL(
            (
            SELECT 
                TOP(1)  CONCAT('+',contact.phoneNumberAreaCode,' ',contact.phoneNumber)
            FROM Contacts AS contact
            WHERE 
                contact.customerID = client.customerID
                AND contact.isForPayments = @isForPayments
                AND contact.[status]=@idActive
        ),
        CONCAT('+',client.ladaPhone, ' ',client.phone)
        ),
        ISNULL(
            (
            SELECT 
                TOP(1)  contact.email
            FROM Contacts AS contact
            WHERE 
                contact.customerID = client.customerID
                AND contact.isForPayments = @isForPayments
                AND contact.[status]=@idActive
        ),
        client.email
        )
    FROM LegalDocuments AS invoice
    LEFT JOIN Customers AS client ON client.customerID= invoice.idCustomer
    WHERE
        client.[status]= @idActive
        AND client.customerType= @idCustomerType
        AND invoice.idTypeLegalDocument= @idInvoiceType
        AND invoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
        -- AND DATEDIFF(day,invoice.expirationDate,@today)<=0
        AND invoice.idCustomer IS NOT NULL




    -- Obtiene las facturas que venceran durante el mes, pero no tiene facturas expiradas
    INSERT INTO @reminders (
        idInvoice,
        idClient,
        emitedDate,
        expirationDate,
        indexDate,
        idRule,
        contact,
        phone,
        email,
        total,
        residue,
        currency
    )
    SELECT DISTINCT
        invoice.id,
        invoice.idCustomer,
        invoice.createdDate,
        invoice.expirationDate,
        @today,
        1,
        client.contact,
        client.phone,
        client.email,
        invoice.total,
        invoice.residue,
        invoice.currencyCode
        
    FROM LegalDocuments AS invoice
    LEFT JOIN @tempClients AS client ON client.idClient = invoice.idCustomer
    WHERE 
        invoice.idTypeLegalDocument= @idInvoiceType
        AND invoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
        AND ABS(DATEDIFF(day,invoice.expirationDate,@today))<=14
        AND invoice.idCustomer IS NOT NULL


    INSERT INTO @reminders (
        idInvoice,
        idClient,
        emitedDate,
        expirationDate,
        indexDate,
        idRule,
        contact,
        phone,
        email,
        total,
        residue,
        currency
    )
    SELECT DISTINCT
        invoice.id,
        invoice.idCustomer,
        invoice.createdDate,
        invoice.expirationDate,
        @today,
        2,
        client.contact,
        client.phone,
        client.email,
        invoice.total,
        invoice.residue,
        invoice.currencyCode
        
    FROM LegalDocuments AS invoice
    LEFT JOIN @tempClients AS client ON client.idClient = invoice.idCustomer
    WHERE 
        invoice.idTypeLegalDocument= @idInvoiceType
        AND invoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
        AND DATEDIFF(day,invoice.expirationDate,@today)>0
        AND DATEDIFF(day,invoice.expirationDate,@today)<=30
        AND invoice.idCustomer IS NOT NULL


    INSERT INTO @reminders (
        idInvoice,
        idClient,
        emitedDate,
        expirationDate,
        indexDate,
        idRule,
        contact,
        phone,
        email,
        total,
        residue,
        currency
    )
    SELECT DISTINCT
        invoice.id,
        invoice.idCustomer,
        invoice.createdDate,
        invoice.expirationDate,
        @today,
        3,
        client.contact,
        client.phone,
        client.email,
        invoice.total,
        invoice.residue,
        invoice.currencyCode
        
    FROM LegalDocuments AS invoice
    LEFT JOIN @tempClients AS client ON client.idClient = invoice.idCustomer
    WHERE 
        invoice.idTypeLegalDocument= @idInvoiceType
        AND invoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
        AND DATEDIFF(day,invoice.expirationDate,@today)>30
        AND DATEDIFF(day,invoice.expirationDate,@today)<=60
        AND invoice.idCustomer IS NOT NULL

    INSERT INTO @reminders (
        idInvoice,
        idClient,
        emitedDate,
        expirationDate,
        indexDate,
        idRule,
        contact,
        phone,
        email,
        total,
        residue,
        currency
    )
    SELECT DISTINCT
        invoice.id,
        invoice.idCustomer,
        invoice.createdDate,
        invoice.expirationDate,
        @today,
        4,
        client.contact,
        client.phone,
        client.email,
        invoice.total,
        invoice.residue,
        invoice.currencyCode
        
    FROM LegalDocuments AS invoice
    LEFT JOIN @tempClients AS client ON client.idClient = invoice.idCustomer
    WHERE 
        invoice.idTypeLegalDocument= @idInvoiceType
        AND invoice.idLegalDocumentStatus IN (@idInvoiceCxcStatus,@idInvoicePartialStatus)
        AND DATEDIFF(day,invoice.expirationDate,@today)>60
        AND invoice.idCustomer IS NOT NULL

    EXECUTE sp_AddPaymentReminder @reminders;


    DECLARE @remindersCounts INT;
    SELECT 
        @remindersCounts = COUNT(DISTINCT indexDate)
    FROM PaymentReminder


    IF(@remindersCounts IS NOT NULL AND @remindersCounts >4)
    BEGIN
        DECLARE @indexToRemove DATE 
        SELECT TOP(1) @indexToRemove = indexDate FROM PaymentReminder ORDER BY indexDate ASC
        DELETE FROM PaymentReminder WHERE indexDate = @indexToRemove
    END

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------