DECLARE @documentId INT=3683;


DECLARE @quoteTable MoreInfoDocument;
DECLARE @orderTable  MoreInfoDocument;
DECLARE @contractTable  MoreInfoDocument;
DECLARE @odcTable  MoreInfoDocument;
DECLARE @invoiceTable  MoreInfoDocument;
DECLARE @recivedInvoiceTable  MoreInfoDocument;

DECLARE @idQuote INT;
DECLARE @idOrder  INT;
DECLARE @idContract  INT;
DECLARE @idOdc  INT;
DECLARE @idInvoice  INT;
DECLARE @idInvoiceRecived   INT;


IF OBJECT_ID(N'tempdb..#Customer') IS NOT NULL 
        BEGIN
    DROP TABLE #Customer
END
CREATE TABLE #Customer
(
    id INT,
    idCustomerType INT,
    customerType NVARCHAR(20),
    socialReason NVARCHAR(128),
    rfc NVARCHAR(30),
    comertialName NVARCHAR(30),
    shortName NVARCHAR(30),
    idDocument INT

)

SELECT 
    @idQuote = 
        CASE 
            WHEN idTypeDocument=1 THEN idDocument 
            ELSE idQuotation
        END,
    @idOrder = 
        CASE 
            WHEN idTypeDocument=2 THEN idDocument 
            ELSE idInvoice
        END,
    @idContract = 
        CASE 
            WHEN idTypeDocument=6 THEN idDocument 
            ELSE idContract
        END,
    @idOdc = 
        CASE 
            WHEN idTypeDocument=3 THEN idDocument 
            ELSE idOC
        END
FROM Documents
WHERE idDocument=@documentId

SELECT 
    @idInvoice= id
FROM LegalDocuments WHERE idDocument=@idOrder
SELECT 
    @idInvoiceRecived= id
FROM LegalDocuments WHERE idDocument=@idOdc

 INSERT INTO #Customer (
    id,
    idCustomerType,
    customerType,
    socialReason,
    rfc,
    comertialName,
    shortName,
    idDocument
 )
 SELECT 
    customer.customerID,
    customer.customerType,
    customerType.[description],
    customer.socialReason,
    customer.rfc,
    customer.commercialName,
    customer.shortName,
    @idQuote
  FROM Customers AS customer
  LEFT JOIN Documents AS document ON document.idCustomer= customer.customerID
  LEFT JOIN CustomerTypes AS customerType ON customerType.customerTypeID = customer.customerType
  WHERE document.idDocument=@idQuote
 INSERT INTO #Customer (
    id,
    idCustomerType,
    customerType,
    socialReason,
    rfc,
    comertialName,
    shortName,
    idDocument
 )
 SELECT 
    customer.customerID,
    customer.customerType,
    customerType.[description],
    customer.socialReason,
    customer.rfc,
    customer.commercialName,
    customer.shortName,
    @idOdc
  FROM Customers AS customer
  LEFT JOIN Documents AS document ON document.idCustomer= customer.customerID
  LEFT JOIN CustomerTypes AS customerType ON customerType.customerTypeID = customer.customerType
  WHERE document.idDocument=@idOdc

INSERT INTO @quoteTable (
        idDocument,
        documentNumber,
        currency,
        idDocumentType,
        documentType,
        importAmount,
        ivaAmount,
        totalAmount,
        createdDate,
        expirationDate,
        idContact,
        contactName,
        contactPhone,
        contactCellPhone,
        contactEmail,
        beginDateLable,
        endDateLable
) SELECT 
    document.idDocument,
    CASE 
        WHEN document.documentNumber IS NULL THEN 'ND'
        ELSE FORMAT(document.documentNumber,'0000000')
    END,
    currency.code,
    document.idTypeDocument,
    docType.[description],
    CASE 
        WHEN document.subTotalAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.subTotalAmount)
    END,
    CASE 
        WHEN document.ivaAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.ivaAmount)
    END,
    CASE 
        WHEN document.totalAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.totalAmount)
    END,
    CASE 
        WHEN document.createdDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.createdDate)
    END,
    CASE 
        WHEN document.expirationDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.expirationDate)
    END,
    document.idContact,
    CASE 
        WHEN contact.firstName IS NULL OR contact.firstName=''THEN customer.socialReason
        ELSE CONCAT(contact.firstName,' ',contact.middleName,' ',contact.lastName1,' ',contact.lastName2)
    END,
    CASE
        WHEN (contact.phoneNumber IS NULL OR contact.phoneNumber=' ') THEN CONCAT ('+',customer.ladaPhone,' ',customer.phone)
        WHEN (customer.phone IS NULL OR customer.phone =' ') THEN 'ND'
        ELSE CONCAT('+',contact.phoneNumberAreaCode,'',contact.phoneNumber)
    END,
    CASE
        WHEN contact.cellNumber IS NULL THEN CONCAT ('+',customer.ladaMovil,' ',customer.movil)
        WHEN (customer.movil IS NULL OR customer.movil =' ') THEN 'ND'
        ELSE CONCAT('+',contact.cellNumberAreaCode,' ',contact.cellNumber)
    END,
    ISNULL(contact.email,customer.email),
    'Registro',
    'Vigencia'
    FROM Documents AS document
    LEFT JOIN Currencies AS currency ON document.idCurrency=currency.currencyID
    LEFT JOIN DocumentTypes AS docType ON docType.documentTypeID= document.idTypeDocument
    LEFT JOIN Contacts AS contact ON contact.contactID= document.idContact
    LEFT JOIN Customers AS customer ON customer.customerID= document.idCustomer
    WHERE document.idDocument=@idQuote;


INSERT INTO @orderTable (
        idDocument,
        documentNumber,
        currency,
        idDocumentType,
        documentType,
        importAmount,
        ivaAmount,
        totalAmount,
        createdDate,
        expirationDate,
        idContact,
        contactName,
        contactPhone,
        contactCellPhone,
        contactEmail,
        beginDateLable,
        endDateLable
) SELECT 
    document.idDocument,
    CASE 
        WHEN document.documentNumber IS NULL THEN 'ND'
        ELSE FORMAT(document.documentNumber,'0000000')
    END,
    currency.code,
    document.idTypeDocument,
    docType.[description],
    CASE 
        WHEN document.subTotalAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.subTotalAmount)
    END,
    CASE 
        WHEN document.ivaAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.ivaAmount)
    END,
    CASE 
        WHEN document.totalAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.totalAmount)
    END,
    CASE 
        WHEN document.createdDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.createdDate)
    END,
    CASE 
        WHEN document.expirationDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.expirationDate)
    END,
    document.idContact,
    CASE 
        WHEN contact.firstName IS NULL OR contact.firstName=''THEN customer.socialReason
        ELSE CONCAT(contact.firstName,' ',contact.middleName,' ',contact.lastName1,' ',contact.lastName2)
    END,
    CASE
        WHEN (contact.phoneNumber IS NULL OR contact.phoneNumber=' ') THEN CONCAT ('+',customer.ladaPhone,' ',customer.phone)
        WHEN (customer.phone IS NULL OR customer.phone =' ') THEN 'ND'
        ELSE CONCAT('+',contact.phoneNumberAreaCode,'',contact.phoneNumber)
    END,
    CASE
        WHEN contact.cellNumber IS NULL THEN CONCAT ('+',customer.ladaMovil,' ',customer.movil)
        WHEN (customer.movil IS NULL OR customer.movil =' ') THEN 'ND'
        ELSE CONCAT('+',contact.cellNumberAreaCode,' ',contact.cellNumber)
    END,
    ISNULL(contact.email,customer.email),
    'Registro',
    'Facturación'
    FROM Documents AS document
    LEFT JOIN Currencies AS currency ON document.idCurrency=currency.currencyID
    LEFT JOIN DocumentTypes AS docType ON docType.documentTypeID= document.idTypeDocument
    LEFT JOIN Contacts AS contact ON contact.contactID= document.idContact
    LEFT JOIN Customers AS customer ON customer.customerID= document.idCustomer
    WHERE document.idDocument=@idOrder

INSERT INTO @contractTable (
        idDocument,
        documentNumber,
        currency,
        idDocumentType,
        documentType,
        importAmount,
        ivaAmount,
        totalAmount,
        createdDate,
        expirationDate,
        idContact,
        contactName,
        contactPhone,
        contactCellPhone,
        contactEmail,
        beginDateLable,
        endDateLable
) SELECT 
    document.idDocument,
    CASE 
        WHEN document.documentNumber IS NULL THEN 'ND'
        ELSE FORMAT(document.documentNumber,'0000000')
    END,
    currency.code,
    document.idTypeDocument,
    docType.[description],
    CASE 
        WHEN document.subTotalAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.subTotalAmount)
    END,
    CASE 
        WHEN document.ivaAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.ivaAmount)
    END,
    CASE 
        WHEN document.totalAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.totalAmount)
    END,
    CASE 
        WHEN document.createdDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.createdDate)
    END,
    CASE 
        WHEN document.expirationDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.expirationDate)
    END,
    document.idContact,
    CASE 
        WHEN contact.firstName IS NULL OR contact.firstName=''THEN customer.socialReason
        ELSE CONCAT(contact.firstName,' ',contact.middleName,' ',contact.lastName1,' ',contact.lastName2)
    END,
    CASE
        WHEN (contact.phoneNumber IS NULL OR contact.phoneNumber=' ') THEN CONCAT ('+',customer.ladaPhone,' ',customer.phone)
        WHEN (customer.phone IS NULL OR customer.phone =' ') THEN 'ND'
        ELSE CONCAT('+',contact.phoneNumberAreaCode,'',contact.phoneNumber)
    END,
    CASE
        WHEN contact.cellNumber IS NULL THEN CONCAT ('+',customer.ladaMovil,' ',customer.movil)
        WHEN (customer.movil IS NULL OR customer.movil =' ') THEN 'ND'
        ELSE CONCAT('+',contact.cellNumberAreaCode,' ',contact.cellNumber)
    END,
    ISNULL(contact.email,customer.email),
    'Recordatorio',
    'Vencimineto'
    FROM Documents AS document
    LEFT JOIN Currencies AS currency ON document.idCurrency=currency.currencyID
    LEFT JOIN DocumentTypes AS docType ON docType.documentTypeID= document.idTypeDocument
    LEFT JOIN Contacts AS contact ON contact.contactID= document.idContact
    LEFT JOIN Customers AS customer ON customer.customerID= document.idCustomer
    WHERE document.idDocument=@idContract;



INSERT INTO @odcTable (
        idDocument,
        documentNumber,
        currency,
        idDocumentType,
        documentType,
        importAmount,
        ivaAmount,
        totalAmount,
        createdDate,
        expirationDate,
        idContact,
        contactName,
        contactPhone,
        contactCellPhone,
        contactEmail,
        beginDateLable,
        endDateLable
) SELECT 
    document.idDocument,
    CASE 
        WHEN document.documentNumber IS NULL THEN 'ND'
        ELSE FORMAT(document.documentNumber,'0000000')
    END,
    currency.code,
    document.idTypeDocument,
    docType.[description],
    CASE 
        WHEN document.subTotalAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.subTotalAmount)
    END,
    CASE 
        WHEN document.ivaAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.ivaAmount)
    END,
    CASE 
        WHEN document.totalAmount IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.totalAmount)
    END,
    CASE 
        WHEN document.createdDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.createdDate)
    END,
    CASE 
        WHEN document.expirationDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.expirationDate)
    END,
    document.idContact,
    CASE 
        WHEN contact.firstName IS NULL OR contact.firstName=''THEN customer.socialReason
        ELSE CONCAT(contact.firstName,' ',contact.middleName,' ',contact.lastName1,' ',contact.lastName2)
    END,
    CASE
        WHEN (contact.phoneNumber IS NULL OR contact.phoneNumber=' ') THEN CONCAT ('+',customer.ladaPhone,' ',customer.phone)
        WHEN (customer.phone IS NULL OR customer.phone =' ') THEN 'ND'
        ELSE CONCAT('+',contact.phoneNumberAreaCode,'',contact.phoneNumber)
    END,
    CASE
        WHEN contact.cellNumber IS NULL THEN CONCAT ('+',customer.ladaMovil,' ',customer.movil)
        WHEN (customer.movil IS NULL OR customer.movil =' ') THEN 'ND'
        ELSE CONCAT('+',contact.cellNumberAreaCode,' ',contact.cellNumber)
    END,
    ISNULL(contact.email,customer.email),
    'Recordatorio',
    'Vencimineto'
    FROM Documents AS document
    LEFT JOIN Currencies AS currency ON document.idCurrency=currency.currencyID
    LEFT JOIN DocumentTypes AS docType ON docType.documentTypeID= document.idTypeDocument
    LEFT JOIN Contacts AS contact ON contact.contactID= document.idContact
    LEFT JOIN Customers AS customer ON customer.customerID= document.idCustomer
    WHERE document.idDocument=@idOdc


INSERT INTO @invoiceTable (
        idDocument,
        documentNumber,
        currency,
        idDocumentType,
        documentType,
        importAmount,
        ivaAmount,
        totalAmount,
        createdDate,
        expirationDate,
        idContact,
        contactName,
        contactPhone,
        contactCellPhone,
        contactEmail,
        beginDateLable,
        endDateLable
) SELECT 
    document.id,
    CASE
        WHEN document.noDocument IS NULL THEN 'ND'
        ELSE document.noDocument
    END,
    document.currencyCode,
    document.idTypeLegalDocument,
    docType.[description],
    CASE 
        WHEN document.import IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.import)
    END,
    
    CASE 
        WHEN document.iva IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.iva)
    END,
    
    CASE 
        WHEN document.total IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.total)
    END,
    CASE 
        WHEN document.createdDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.createdDate)
    END,
    CASE 
        WHEN document.expirationDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.expirationDate)
    END,
    documentInfo.idContact,
    documentInfo.contactName,
    documentInfo.contactPhone,
    documentInfo.contactCellPhone,
    documentInfo.contactEmail,
    'Recordatorio',
    'Vencimineto'
    FROM LegalDocuments AS document
    LEFT JOIN LegalDocumentTypes AS docType ON docType.id= document.idTypeLegalDocument
    LEFT JOIN @quoteTable AS documentInfo ON documentInfo.idDocument=@idQuote
    WHERE document.id=@idInvoice;

INSERT INTO @recivedInvoiceTable (
        idDocument,
        documentNumber,
        currency,
        idDocumentType,
        documentType,
        importAmount,
        ivaAmount,
        totalAmount,
        createdDate,
        expirationDate,
        idContact,
        contactName,
        contactPhone,
        contactCellPhone,
        contactEmail,
        beginDateLable,
        endDateLable
) SELECT 
    document.id,
    CASE
        WHEN document.noDocument IS NULL THEN 'ND'
        ELSE document.noDocument
    END,
    document.currencyCode,
    document.idTypeLegalDocument,
    docType.[description],
    CASE 
        WHEN document.import IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.import)
    END,
    
    CASE 
        WHEN document.iva IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.iva)
    END,
    
    CASE 
        WHEN document.total IS NULL THEN 'ND'
        ELSE dbo.fn_FormatCurrency(document.total)
    END,
    CASE 
        WHEN document.createdDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.createdDate)
    END,
    CASE 
        WHEN document.expirationDate IS NULL THEN 'ND'
        ELSE dbo.FormatDate(document.expirationDate)
    END,
    documentInfo.idContact,
    documentInfo.contactName,
    documentInfo.contactPhone,
    documentInfo.contactCellPhone,
    documentInfo.contactEmail,
    'Emisión',
    'Vencimineto'
    FROM LegalDocuments AS document
    LEFT JOIN LegalDocumentTypes AS docType ON docType.id= document.idTypeLegalDocument
    LEFT JOIN @odcTable AS documentInfo ON documentInfo.idDocument=@idOdc
    WHERE document.id=@idInvoiceRecived;
-- EMPIEZA EL SELECT COMPLETO.

SELECT 
    
    'Cliente' AS [client.customerType],

    quoteDoc.idDocument AS [client.documents.quote.id],
    quoteDoc.documentNumber AS [client.documents.quote.number],
    quoteDoc.currency AS [client.documents.quote.currency],
    quoteDoc.idDocumentType AS [client.documents.quote.documentTypeID],
    quoteDoc.documentType AS [client.documents.quote.documentType],
    quoteDoc.importAmount AS [client.documents.quote.import],
    quoteDoc.ivaAmount AS [client.documents.quote.iva],
    quoteDoc.totalAmount AS [client.documents.quote.total],
    quoteDoc.createdDate AS [client.documents.quote.beginDate],
    quoteDoc.expirationDate AS [client.documents.quote.endDate],
    clientCustomer.socialReason AS [client.documents.quote.customer.socialReson],
    clientCustomer.rfc AS [client.documents.quote.customer.rfc],
    clientCustomer.comertialName AS [client.documents.quote.customer.commercialName],
    clientCustomer.shortName AS [client.documents.quote.customer.shortName],
    quoteDoc.contactName AS [client.documents.quote.contact.name],
    quoteDoc.contactPhone AS [client.documents.quote.contact.phone],
    quoteDoc.contactCellPhone AS [client.documents.quote.contact.cellphone],
    quoteDoc.contactEmail AS [client.documents.quote.contact.mail],
    quoteDoc.beginDateLable AS [client.documents.quote.beginDateLabel],
    quoteDoc.endDateLable AS [client.documents.quote.endDateLabel],

    --? ORDER

    orederDoc.idDocument AS [client.documents.preInvoice.id],
    orederDoc.documentNumber AS [client.documents.preInvoice.number],
    orederDoc.currency AS [client.documents.preInvoice.currency],
    orederDoc.idDocumentType AS [client.documents.preInvoice.documentTypeID],
    orederDoc.documentType AS [client.documents.preInvoice.documentType],
    orederDoc.importAmount AS [client.documents.preInvoice.import],
    orederDoc.ivaAmount AS [client.documents.preInvoice.iva],
    orederDoc.totalAmount AS [client.documents.preInvoice.total],
    orederDoc.createdDate AS [client.documents.preInvoice.beginDate],
    orederDoc.expirationDate AS [client.documents.preInvoice.endDate],
    clientCustomer.socialReason AS [client.documents.preInvoice.customer.socialReson],
    clientCustomer.rfc AS [client.documents.preInvoice.customer.rfc],
    clientCustomer.comertialName AS [client.documents.preInvoice.customer.commercialName],
    clientCustomer.shortName AS [client.documents.preInvoice.customer.shortName],
    orederDoc.contactName AS [client.documents.preInvoice.contact.name],
    orederDoc.contactPhone AS [client.documents.preInvoice.contact.phone],
    orederDoc.contactCellPhone AS [client.documents.preInvoice.contact.cellphone],
    orederDoc.contactEmail AS [client.documents.preInvoice.contact.mail],
    orederDoc.beginDateLable AS [client.documents.preInvoice.beginDateLabel],
    orederDoc.endDateLable AS [client.documents.preInvoice.endDateLabel],

    --? CONTRACT

    contractDoc.idDocument AS [client.documents.contract.id],
    contractDoc.documentNumber AS [client.documents.contract.number],
    contractDoc.currency AS [client.documents.contract.currency],
    contractDoc.idDocumentType AS [client.documents.contract.documentTypeID],
    contractDoc.documentType AS [client.documents.contract.documentType],
    contractDoc.importAmount AS [client.documents.contract.import],
    contractDoc.ivaAmount AS [client.documents.contract.iva],
    contractDoc.totalAmount AS [client.documents.contract.total],
    contractDoc.createdDate AS [client.documents.contract.beginDate],
    contractDoc.expirationDate AS [client.documents.contract.endDate],
    clientCustomer.socialReason AS [client.documents.contract.customer.socialReson],
    clientCustomer.rfc AS [client.documents.contract.customer.rfc],
    clientCustomer.comertialName AS [client.documents.contract.customer.commercialName],
    clientCustomer.shortName AS [client.documents.contract.customer.shortName],
    contractDoc.contactName AS [client.documents.contract.contact.name],
    contractDoc.contactPhone AS [client.documents.contract.contact.phone],
    contractDoc.contactCellPhone AS [client.documents.contract.contact.cellphone],
    contractDoc.contactEmail AS [client.documents.contract.contact.mail],
    contractDoc.beginDateLable AS [client.documents.contract.beginDateLabel],
    contractDoc.endDateLable AS [client.documents.contract.endDateLabel],

        
    --? INVOICE

    invoceDoc.idDocument AS [client.documents.invoice.id],
    invoceDoc.documentNumber AS [client.documents.invoice.number],
    invoceDoc.currency AS [client.documents.invoice.currency],
    invoceDoc.idDocumentType AS [client.documents.invoice.documentTypeID],
    invoceDoc.documentType AS [client.documents.invoice.documentType],
    invoceDoc.importAmount AS [client.documents.invoice.import],
    invoceDoc.ivaAmount AS [client.documents.invoice.iva],
    invoceDoc.totalAmount AS [client.documents.invoice.total],
    invoceDoc.createdDate AS [client.documents.invoice.beginDate],
    invoceDoc.expirationDate AS [client.documents.invoice.endDate],
    clientCustomer.socialReason AS [client.documents.invoice.customer.socialReson],
    clientCustomer.rfc AS [client.documents.invoice.customer.rfc],
    clientCustomer.comertialName AS [client.documents.invoice.customer.commercialName],
    clientCustomer.shortName AS [client.documents.invoice.customer.shortName],
    invoceDoc.contactName AS [client.documents.invoice.contact.name],
    invoceDoc.contactPhone AS [client.documents.invoice.contact.phone],
    invoceDoc.contactCellPhone AS [client.documents.invoice.contact.cellphone],
    invoceDoc.contactEmail AS [client.documents.invoice.contact.mail],
    invoceDoc.beginDateLable AS [client.documents.invoice.beginDateLabel],
    invoceDoc.endDateLable AS [client.documents.invoice.endDateLabel],

    --? ODC

    odcDoc.idDocument AS [provider.documents.odc.id],
    odcDoc.documentNumber AS [provider.documents.odc.number],
    odcDoc.currency AS [provider.documents.odc.currency],
    odcDoc.idDocumentType AS [provider.documents.odc.documentTypeID],
    odcDoc.documentType AS [provider.documents.odc.documentType],
    odcDoc.importAmount AS [provider.documents.odc.import],
    odcDoc.ivaAmount AS [provider.documents.odc.iva],
    odcDoc.totalAmount AS [provider.documents.odc.total],
    odcDoc.createdDate AS [provider.documents.odc.beginDate],
    odcDoc.expirationDate AS [provider.documents.odc.endDate],
    providerCustomer.socialReason AS [provider.documents.odc.customer.socialReson],
    providerCustomer.rfc AS [provider.documents.odc.customer.rfc],
    providerCustomer.comertialName AS [provider.documents.odc.customer.commercialName],
    providerCustomer.shortName AS [provider.documents.odc.customer.shortName],
    odcDoc.contactName AS [provider.documents.odc.contact.name],
    odcDoc.contactPhone AS [provider.documents.odc.contact.phone],
    odcDoc.contactCellPhone AS [provider.documents.odc.contact.cellphone],
    odcDoc.contactEmail AS [provider.documents.odc.contact.mail],
    odcDoc.beginDateLable AS [provider.documents.odc.beginDateLabel],
    odcDoc.endDateLable AS [provider.documents.odc.endDateLabel],
    
    --? RECIBEDINVOICE

    recivedInvoiceDoc.idDocument AS [provider.documents.invoiceReception.id],
    recivedInvoiceDoc.documentNumber AS [provider.documents.invoiceReception.number],
    recivedInvoiceDoc.currency AS [provider.documents.invoiceReception.currency],
    recivedInvoiceDoc.idDocumentType AS [provider.documents.invoiceReception.documentTypeID],
    recivedInvoiceDoc.documentType AS [provider.documents.invoiceReception.documentType],
    recivedInvoiceDoc.importAmount AS [provider.documents.invoiceReception.import],
    recivedInvoiceDoc.ivaAmount AS [provider.documents.invoiceReception.iva],
    recivedInvoiceDoc.totalAmount AS [provider.documents.invoiceReception.total],
    recivedInvoiceDoc.createdDate AS [provider.documents.invoiceReception.beginDate],
    recivedInvoiceDoc.expirationDate AS [provider.documents.invoiceReception.endDate],
    providerCustomer.socialReason AS [provider.documents.invoiceReception.customer.socialReson],
    providerCustomer.rfc AS [provider.documents.invoiceReception.customer.rfc],
    providerCustomer.comertialName AS [provider.documents.invoiceReception.customer.commercialName],
    providerCustomer.shortName AS [provider.documents.invoiceReception.customer.shortName],
    recivedInvoiceDoc.contactName AS [provider.documents.invoiceReception.contact.name],
    recivedInvoiceDoc.contactPhone AS [provider.documents.invoiceReception.contact.phone],
    recivedInvoiceDoc.contactCellPhone AS [provider.documents.invoiceReception.contact.cellphone],
    recivedInvoiceDoc.contactEmail AS [provider.documents.invoiceReception.contact.mail],
    recivedInvoiceDoc.beginDateLable AS [provider.documents.invoiceReception.beginDateLabel],
    recivedInvoiceDoc.endDateLable AS [provider.documents.invoiceReception.endDateLabel],

    'Proveedor' AS [provider.customerType] 

FROM @quoteTable AS quoteDoc
LEFT JOIN @orderTable AS orederDoc ON  orederDoc.idDocument=@idOrder
LEFT JOIN @contractTable AS contractDoc ON  contractDoc.idDocument=@idContract
LEFT JOIN @odcTable AS odcDoc ON  odcDoc.idDocument=@idOdc
LEFT JOIN @invoiceTable AS invoceDoc ON  invoceDoc.idDocument=@idInvoice
LEFT JOIN @recivedInvoiceTable AS recivedInvoiceDoc ON  recivedInvoiceDoc.idDocument=@idInvoiceRecived
LEFT JOIN #Customer AS clientCustomer ON clientCustomer.idDocument=@idQuote
LEFT JOIN #Customer AS providerCustomer ON providerCustomer.idDocument=@idOdc

FOR JSON PATH, ROOT('DocumentPopUp'), INCLUDE_NULL_VALUES

IF OBJECT_ID(N'tempdb..#Customer') IS NOT NULL 
    BEGIN
        DROP TABLE #Customer
    END