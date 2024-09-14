-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 12-20-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetControlReport
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
--	2023-12-20		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetControlReport')
    BEGIN 

        DROP PROCEDURE sp_GetControlReport;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 12/20/2023
-- Description: sp_GetControlReport - Some Notes
CREATE PROCEDURE sp_GetControlReport AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    DECLARE @temTable TABLE (
        id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        idOrder INT,
        idOdc INT
    )

    INSERT INTO @temTable (
        idOrder,
        idOdc
    )
    SELECT 
        idDocument,
        idOC
    FROM Documents 
    WHERE 
        idTypeDocument= 2 AND
        idOC is not null


    SELECT 
        client.socialReason AS [client.socialReason],
        clientExecutive.initials AS [client.executive],
        orden.documentNumber AS [client.orden.number],
        ordenCurrency.code AS [client.orden.currency],
        orden.totalAmount AS [client.orden.total],
        ordenStatus.description AS [client.orden.status],
        clientInvoice.noDocument AS [client.invoice.number],
        clientInvoice.createdDate AS [client.invoice.date],
        clientInvoice.currencyCode AS [client.invoice.currency],
        clientInvoice.total AS [client.invoice.total],
        CASE 
            WHEN clientInvoice.total IS NULL THEN NULL
            ELSE orden.protected
        END AS [client.invoice.tc],
        CASE 
            WHEN clientInvoice.acumulated IS NULL OR clientInvoice.acumulated=0 THEN NULL
            ELSE clientInvoice.lastUpadatedDate
        END [client.charged.date],
        clientInvoice.currencyCode AS [client.charged.currency],
        clientInvoice.acumulated AS [client.charged.total],
        clientInvoiceStatus.[description] AS [client.charged.status],
        supplier.socialReason AS [supplier.socialReason],
        odc.documentNumber AS [supplier.odc.number],
        odc.expirationDate AS [supplier.odc.date],
        odcStatus.description AS [supplier.odc.status],
        supplierInvoice.noDocument AS [supplier.invoice.number],
        supplierInvoice.total AS [supplier.invoice.total],
        supplierInvoice.currencyCode AS [supplier.invoice.currency],
        supplierInvoiceStatus.description AS [supplier.invoice.status]
    FROM @temTable AS [control]
    LEFT JOIN Documents AS orden ON orden.idDocument= [control].[idOrder]
    LEFT JOIN Documents AS odc ON odc.idDocument = [control].idOdc
    LEFT JOIN LegalDocuments AS clientInvoice ON clientInvoice.idDocument= [control].[idOrder]
    LEFT JOIN LegalDocumentsAssociations AS odcInvoice ON odcInvoice.idDocument=[control].idOdc
    LEFT JOIN LegalDocuments AS supplierInvoice ON supplierInvoice.id= odcInvoice.idLegalDocuments
    LEFT JOIN Users AS clientExecutive ON clientExecutive.userID= orden.idExecutive
    LEFT JOIN Users AS supplierExecutive ON supplierExecutive.userID= odc.idExecutive
    LEFT JOIN Currencies AS ordenCurrency ON ordenCurrency.currencyID=orden.idCurrency
    LEFT JOIN Currencies AS odcCurrency ON odcCurrency.currencyID=odc.idCurrency
    LEFT JOIN Customers AS client ON client.customerID=orden.idCustomer
    LEFT JOIN Customers AS supplier ON supplier.customerID=odc.idCustomer
    LEFT JOIN LegalDocumentStatus AS clientInvoiceStatus ON clientInvoiceStatus.id= clientInvoice.idLegalDocumentStatus
    LEFT JOIN LegalDocumentStatus AS supplierInvoiceStatus ON supplierInvoiceStatus.id= supplierInvoice.idLegalDocumentStatus
    LEFT JOIN DocumentNewStatus AS ordenStatus ON ordenStatus.id= orden.idStatus
    LEFT JOIN DocumentNewStatus AS odcStatus ON odcStatus.id= odc.idStatus
    FOR JSON PATH, ROOT('control'),INCLUDE_NULL_VALUES

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------