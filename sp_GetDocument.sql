-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 26-09-2021

-- Description: Get the information of an specific document

-- ===================================================================================================================================
-- PARAMETERS:
-- @id: Id of the document to fetch his full information

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  26-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query			
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetDocument(
    @id INT
)

AS BEGIN

    SET LANGUAGE Spanish;

    SELECT 
        Documents.idDocument AS id,

        Documents.idTypeDocument AS [type.id],
        DocumentTypes.description AS [type.description],
        
        Documents.idCurrency AS [currency.id],
        Currencies.code AS [currency.code],
        Currencies.symbol AS [currency.symbol],
        Currencies.description AS [currency.description],

        Documents.idProgress AS [progress.id],
        DocumentProgress.description AS [progress.description],
        DocumentProgress.percentage AS [progress.percentage.number],
        CONCAT(DocumentProgress.percentage,'%') AS [progress.percentage.text],

        Documents.idProbability AS [probability.id],
        Probabilities.description AS [probability.description],
        Probabilities.value AS [probability.percentage.number],
        CONCAT(Probabilities.symbol,' ',Probabilities.value) AS [probability.percentage.text],

        Documents.creditDays,

        Documents.totalAmount AS [amount.total.number],
        FORMAT(Documents.totalAmount,'C','en-us') AS [amount.total.text],

        Documents.ivaAmount AS [amount.iva.number],
        FORMAT(Documents.ivaAmount,'C','en-us') AS [amount.iva.text],

        Documents.subTotalAmount AS [amount.subtotal.number],
        FORMAT(Documents.subTotalAmount,'C','en-us') AS [amount.subtotal.text],
        
        Documents.idCustomer AS [customer.id],
        Customers.socialReason AS [customer.socialReason],
        Customers.commercialName AS [customer.commercialName],
        Customers.shortName AS [customer.shortName],
        Customers.rfc AS [customer.rfc],
        Customers.customerType AS [customer.type.id],

        Documents.documentNumber,

        FORMAT(Documents.createdDate,'yyyy-MM-dd') AS [createdDate.yyyymmdd],
        REPLACE(CONVERT(VARCHAR(10),Documents.createdDate,6),' ','/') AS [createdDate.parsed],

        FORMAT(Documents.reminderDate,'yyyy-MM-dd') AS [reminderDate.yyyymmdd],
        REPLACE(CONVERT(VARCHAR(10),Documents.reminderDate,6),' ','/') AS [reminderDate.parsed],

        FORMAT(Documents.lastUpdatedDate,'yyyy-MM-dd') AS [updatedDate.yyyymmdd],
        REPLACE(CONVERT(VARCHAR(10),Documents.lastUpdatedDate,6),' ','/') AS [updatedDate.parsed],

        FORMAT(Documents.expirationDate,'yyyy-MM-dd') AS [expiration.yyyymmdd],
        REPLACE(CONVERT(VARCHAR(10),Documents.expirationDate,6),' ','/') AS [expiration.parsed],

        FORMAT(Documents.reminderDate,'yyyy-MM-dd') AS [reminder.yyyymmdd],
        REPLACE(CONVERT(VARCHAR(10),Documents.reminderDate,6),' ','/') AS [reminder.parsed],

        Documents.idContact AS [contact.id],

        StateDocuments.state AS [status.id],
        StateDocuments.description AS [status.description],

        Users.userID AS [executive.id],
        Users.firstName AS [executive.firstName],
        Users.middleName AS [executive.middleName],
        Users.lastName1 AS [executive.parentName],
        Users.lastName2 AS [executive.motherName],
        CONCAT(Users.firstName,' ',Users.middleName,' ',Users.lastName1,' ',Users.lastName2) AS [executive.fullName],

        
        Documents.idContract AS [documents.contract.id],
        Documents.contract AS [documents.contract.number],
        Documents.idQuotation AS [documents.quote],
        Documents.idInvoice AS [documents.preInvoice],
        Documents.idOC AS [documents.oc],
        Documents.idContractParent AS [documents.origin],
        Documents.invoiceMizarNumber AS [documents.invoice],

        Documents.protected AS [tcp.number],
        FORMAT(Documents.protected,'C','en-us') AS [tcp.text],

        CFDI.idCFDI AS [cfdi.id],
        CFDI.code AS [cfdi.code],
        CFDI.description AS [cfdi.description],

        PaymentMethods.code AS [payMethod.id],
        PaymentMethods.description AS [payMethod.description],
        PaymentMethods.details AS [payMethod.details],

        PaymentForms.idPayForm AS [payForm.id],
        PaymentForms.code AS [payForm.code],
        PaymentForms.description AS [payForm.description],



        CASE 
            WHEN
                Documents.isComplement IS NULL 
                
                THEN 
                
                CONVERT(BIT,0)
                
            ELSE 
                CONVERT(BIT,1) END AS [isComplement.boolean],


        CASE 
            WHEN
                Documents.isComplement IS NULL
                THEN
                'No'

            ELSE
                'Si' END AS [isComplement.text],

        Documents.factionsNumber AS [partialities.totalPartialities],
        Documents.currectFaction AS [partialities.currentPartiality]

        FROM Documents 

        LEFT JOIN Currencies ON Documents.idCurrency = Currencies.currencyID
        LEFT JOIN StateDocuments ON Documents.idStatus = StateDocuments.state
        LEFT JOIN Users ON Documents.idExecutive = Users.userID
        LEFT JOIN DocumentTypes ON Documents.idTypeDocument = DocumentTypes.documentTypeID
        LEFT JOIN DocumentProgress ON Documents.idProgress = DocumentProgress.documentProgressID
        LEFT JOIN Probabilities ON Documents.idProbability = Probabilities.probabilityID
        LEFT JOIN Customers ON Documents.idCustomer = Customers.customerID
        LEFT JOIN CFDI ON Documents.idCfdi = CFDI.idCFDI
        LEFT JOIN PaymentMethods ON Documents.idPaymentMethod = PaymentMethods.code
        LEFT JOIN PaymentForms ON Documents.idPaymentForm = PaymentForms.idPayForm
        
        WHERE 
            Documents.idDocument=@id

        FOR JSON PATH, ROOT('documentInfo'), INCLUDE_NULL_VALUES;

END;