-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-16-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetDocumentsRelatedPopUp
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: The document id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: From the selected document, it obtains the data of the client, supplier and all the documents related to that record.
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-16		Adrian Alardin   			1.0.0.0			Initial Revision	
--	2022-03-07		Adrian Alardin   			1.0.0.1			It was added the info contact and the customer info to every document	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/09/2022
-- Description: sp_GetDocumentsRelatedPopUp -From the selected document, it obtains the data of the client, supplier and all the documents related to that record.
-- =============================================
CREATE PROCEDURE sp_GetDocumentsRelatedPopUp
    (
    @documentId INT
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    --* ----------------- ↓↓↓ DYNIMIC QUERY VARIABLES ↓↓↓ -----------------------

DECLARE @PARAMS NVARCHAR (MAX);-- LOS 'PARAMETROS' PARA OBTENER LOS REGISTROS DE LA TABLA
DECLARE @JOIN_CLAUSE NVARCHAR(MAX);-- 'JOINS' .SE CONFIGURAN SEGUN EL TIPO DE DOCUMENTO
DECLARE @FROM_CLAUSE NVARCHAR (MAX);-- 'FROM' .SE CONFIGURA SEGUN EL TIPO DE DOCUMENTO
DECLARE @WHERE_CLAUSE NVARCHAR (MAX);-- CONDICION 'WHERE'. SE CONFIGURA SEGUN EL TIPO DE DOCUMENTO
DECLARE @SELECT_CLAUSE NVARCHAR (MAX);-- LA SENTENCIA 'SELECT'. SE REPITE EN TODAS LAS CONSULTAS
DECLARE @JSON_PATH NVARCHAR (MAX);-- LA SENTENCIA PARA ARMAR EL JSON

--* ----------------- ↑↑↑ DYNIMIC QUERY VARIABLES ↑↑↑ -----------------------


--* ----------------- ↓↓↓ DYNIMIC STOREPROCEDURES↓↓↓ -----------------------

DECLARE @SP_GET_POPUP_DOCUMENT NVARCHAR (MAX);-- VARIABLE DONDE SE GUARDA EL STOREPROCEDURE FINAL PARA OBTENER LAS INFORMACION DE LOS DOCUMENTOS RELACIONADOS

--* ----------------- ↑↑↑ DYNIMIC STOREPROCEDURES ↑↑↑ -----------------------


--* ----------------- ↓↓↓ Local varibles ↓↓↓ -----------------------

DECLARE @documentType INT-- TIPO DE DOCUMENTO
DECLARE @quoteID INT-- ID DE LA COTIZACION
DECLARE @preinvoiceId INT-- ID DE LA PREFACTURA
DECLARE @odcId INT;-- ID DE LA ODC
DECLARE @contractID INT-- ID DEL CONTRATO
DECLARE @invoiceId INT-- ID DE LA FACTURA

DECLARE @customerProviderId INT;-- ID DEL PROVEEDOR
DECLARE @odcUUID NVARCHAR(256);-- ES EL UUID DE LA ODC QUE SE RELACIONA CON FACTURA RECEBIDA (LegalDocuments)

DECLARE @invoiceReceptionNumber NVARCHAR(256);-- EL NUMERO DE LA FACTURA  RECIBIDA PARA LA ODC (FOLIO)
DECLARE @invoiceReceptionDocType NVARCHAR(256);-- EL TIPO DE DOCUMENTO (FACTURA RECIBIDA)
DECLARE @invoiceReceptionDocTypeID INT;-- EL TIPO DE DOCUMENTO (FACTURA RECIBIDA)
DECLARE @invoiceReceptionCurrency NVARCHAR(3);-- EL TIPO DE MONEDA DE LA FACTURA RESIBIDA
DECLARE @invoiceReceptionImport NVARCHAR(MAX);-- EL IMPORTE DE LA FACTURA RECIBIDA
DECLARE @invoiceReceptionIva NVARCHAR(MAX);-- EL IVA DE LA FACTURA RECIBIDA
DECLARE @invoiceReceptionTotal NVARCHAR(MAX);-- EL TOTAL DE LA FACTURA RECIBIDA
DECLARE @invoiceReceptionBeginDate NVARCHAR(30);-- LA FECHA DE EMISION DE LA FACTURA RECIBIDA
DECLARE @invoiceReceptionEndDate NVARCHAR(30);-- LA FECHA DE REGISTRO DE LA FACTURA RECIBIDA


--* ----------------- ↑↑↑ Local varibles ↑↑↑ -----------------------



--? ----------------- ↓↓↓ Prepare PARAMS ↓↓↓ -----------------------

    SET @PARAMS ='@documentId INT, @invoiceReceptionNumber NVARCHAR(256),@invoiceReceptionDocTypeID INT,@invoiceReceptionDocType NVARCHAR(256),@invoiceReceptionCurrency NVARCHAR(3),@invoiceReceptionImport NVARCHAR(MAX),@invoiceReceptionIva NVARCHAR(MAX),@invoiceReceptionTotal NVARCHAR(MAX),@invoiceReceptionBeginDate NVARCHAR(30),@invoiceReceptionEndDate NVARCHAR(30), @quoteID INT, @preinvoiceId INT, @odcId INT, @contractID INT, @invoiceId INT, @customerProviderId INT '; 

--? ----------------- ↑↑↑ Prepare PARAMS ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare documents id releated and the DocumentType ID ↓↓↓ -----------------------
    -- SE OBTIENEN TODOS LOS IDs DE LOS DOCUMENTOS RELACIONADOS Y EL TIPO DE DOCUMENTO SEGUN EL ID DE DOCUMENTO QUE RECIBIMOS
    SELECT 
        @quoteID=idQuotation,
        @preinvoiceId= idInvoice,
        @odcId=CASE 
            WHEN idTypeDocument=3 THEN idDocument
            ELSE idOC
        END,
        -- @odcId=idOC,
        @contractID= idContract,
        @documentType=idTypeDocument

    FROM Documents WHERE idDocument=@documentId

--? ----------------- ↑↑↑ Prepare documents id releated and the DocumentType ID ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare the customerProvider id and UUID ↓↓↓ -----------------------
    -- SE GUARDA EL ID DEL PROVEEDOR Y EL UUID DE LA ORDEN DE COMPRA 
    SELECT 
       @customerProviderId= idCustomer,
       @odcUUID= uuid
    FROM Documents WHERE idDocument=@odcId

--? ----------------- ↑↑↑ Preapare invoice reception number ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Preapare invoice reception number ↓↓↓ -----------------------
    -- SE GUARDA EL NUMERO DE LA FACTURA RECIBIDA DE LA ODC RELACIONADA
    SELECT 
       @invoiceReceptionNumber= LegalDocuments.noDocument,
       @invoiceReceptionDocTypeID= LegalDocuments.idTypeLegalDocument,
       @invoiceReceptionDocType= DocumentType.[description],
       @invoiceReceptionCurrency=LegalDocuments.currencyCode,
       @invoiceReceptionImport=dbo.fn_FormatCurrency(LegalDocuments.import),
       @invoiceReceptionIva=dbo.fn_FormatCurrency(LegalDocuments.iva),
       @invoiceReceptionTotal=dbo.fn_FormatCurrency(LegalDocuments.total),
       @invoiceReceptionBeginDate=dbo.FormatDate(LegalDocuments.emitedDate),
       @invoiceReceptionEndDate=dbo.FormatDate(LegalDocuments.expirationDate)
    FROM LegalDocuments 
    LEFT JOIN LegalDocumentTypes AS DocumentType ON DocumentType.id=LegalDocuments.idTypeLegalDocument
    WHERE uuid=@odcUUID

--? ----------------- ↑↑↑ Prepare the customerProvider id and UUID ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare FROM ↓↓↓ -----------------------
    -- SE CONFIGURA EL FROM INICIAL DEPENDIENDO DEL TIPO DE DOCUMENTO
SET @FROM_CLAUSE= 
    CASE 
        WHEN  @documentType=1 THEN 'FROM Documents AS QuoteDoc ' -- COTIZACION
        WHEN  @documentType=2 THEN 'FROM Documents AS PreInvoiceDoc ' --PRE-FACTURA
        WHEN  @documentType=3 THEN 'FROM Documents AS OdcDoc ' -- ODC 
        WHEN  @documentType=6 THEN 'FROM Documents AS ContractDoc ' -- CONTRATO
        ELSE 'FROM Documents AS InvoiceDoc ' -- FACTURA
    END


--? ----------------- ↑↑↑ Prepare FROM ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare JOINS ↓↓↓ -----------------------
    -- SE CONFIGURA LOS JOINS DEPENDIENDO DEL TIPO DE DOCUMENTO
SET @JOIN_CLAUSE= 
    CASE 
        WHEN  @documentType=1 
            THEN 'LEFT JOIN Documents AS PreInvoiceDoc ON PreInvoiceDoc.idDocument=@preinvoiceId
                  LEFT JOIN Documents AS OdcDoc ON  OdcDoc.idDocument=@odcId
                  LEFT JOIN Documents AS ContractDoc ON  ContractDoc.idDocument=@contractID
                  LEFT JOIN Customers AS CustomerClient ON QuoteDoc.idCustomer=CustomerClient.customerID ' -- COTIZACION
        WHEN  @documentType=2 
            THEN 'LEFT JOIN Documents AS QuoteDoc ON QuoteDoc.idDocument=@quoteID
                  LEFT JOIN Documents AS OdcDoc ON  OdcDoc.idDocument=@odcId
                  LEFT JOIN Documents AS ContractDoc ON  ContractDoc.idDocument=@contractID
                  LEFT JOIN Customers AS CustomerClient ON PreInvoiceDoc.idCustomer=CustomerClient.customerID ' --PRE-FACTURA

        WHEN  @documentType=3 
            THEN 'LEFT JOIN Documents AS QuoteDoc ON QuoteDoc.idDocument=@quoteID
                  LEFT JOIN Documents AS PreInvoiceDoc ON PreInvoiceDoc.idDocument=@preinvoiceId
                  LEFT JOIN Documents AS ContractDoc ON  ContractDoc.idDocument=@contractID 
                  LEFT JOIN Customers AS CustomerClient ON QuoteDoc.idCustomer=CustomerClient.customerID ' -- ODC 

        WHEN  @documentType=6 
            THEN 'LEFT JOIN Documents AS QuoteDoc ON QuoteDoc.idDocument=@quoteID
                  LEFT JOIN Documents AS PreInvoiceDoc ON PreInvoiceDoc.idDocument=@preinvoiceId
                  LEFT JOIN Documents AS OdcDoc ON  OdcDoc.idDocument=@odcId
                  LEFT JOIN Customers AS CustomerClient ON ContractDoc.idCustomer=CustomerClient.customerID ' -- CONTRATO

        ELSE 'LEFT JOIN Documents AS QuoteDoc ON QuoteDoc.idDocument=@quoteID
              LEFT JOIN Documents AS PreInvoiceDoc ON PreInvoiceDoc.idDocument=@preinvoiceId
              LEFT JOIN Documents AS OdcDoc ON  OdcDoc.idDocument=@odcId
              LEFT JOIN Documents AS ContractDoc ON  ContractDoc.idDocument=@contractID
              LEFT JOIN Customers AS CustomerClient ON InvoiceDoc.idCustomer=CustomerClient.customerID ' -- FACTURA
    END

    -- JOINS GENERICOS
    SET @JOIN_CLAUSE= @JOIN_CLAUSE + 'LEFT JOIN Customers AS CustomerProvider ON CustomerProvider.customerID=@customerProviderId
                  LEFT JOIN Currencies AS QuoteCurrency ON QuoteCurrency.currencyID=QuoteDoc.idCurrency
                  LEFT JOIN Currencies AS PreInvoiceCurrency ON PreInvoiceCurrency.currencyID=PreInvoiceDoc.idCurrency
                  LEFT JOIN Currencies AS OdcCurrency ON OdcCurrency.currencyID=OdcDoc.idCurrency
                  LEFT JOIN Currencies AS ContractCurrency ON ContractCurrency.currencyID=ContractDoc.idCurrency 
                  LEFT JOIN DocumentTypes AS QuoteType ON QuoteType.documentTypeID=QuoteDoc.idTypeDocument
                  LEFT JOIN DocumentTypes AS PreInvoiceType ON PreInvoiceType.documentTypeID=PreInvoiceDoc.idTypeDocument
                  LEFT JOIN DocumentTypes AS OdcType ON OdcType.documentTypeID=OdcDoc.idTypeDocument
                  LEFT JOIN DocumentTypes AS ContractType ON ContractType.documentTypeID=ContractDoc.idTypeDocument
                  LEFT JOIN LegalDocuments AS InvoiceDoc ON InvoiceDoc.idDocument=PreInvoiceDoc.idDocument
                  LEFT JOIN LegalDocumentTypes AS InvoiceType ON InvoiceType.id=InvoiceDoc.idTypeLegalDocument
                  LEFT JOIN Customers AS QuoteCustomer ON QuoteCustomer.customerID=QuoteDoc.idCustomer
                  LEFT JOIN Customers AS PreInvoiceCustomer ON PreInvoiceCustomer.customerID=PreInvoiceDoc.idCustomer
                  LEFT JOIN Customers AS ContractCustomer ON ContractCustomer.customerID=ContractDoc.idCustomer
                  LEFT JOIN Customers AS InvoiceCustomer ON InvoiceCustomer.customerID=InvoiceDoc.idCustomer
                  LEFT JOIN Customers AS ProviderCustomer ON ProviderCustomer.customerID=OdcDoc.idCustomer
                  LEFT JOIN Contacts AS QuoteContact ON QuoteContact.contactID=QuoteDoc.idContact
                  LEFT JOIN Contacts AS PreInvoiceContact ON PreInvoiceContact.contactID=PreInvoiceDoc.idContact
                  LEFT JOIN Contacts AS ContractContact ON ContractContact.contactID=ContractDoc.idContact
                  LEFT JOIN Contacts AS InvoiceContact ON InvoiceContact.contactID=PreInvoiceDoc.idContact
                  LEFT JOIN Contacts AS ProviderContact ON ProviderContact.contactID=OdcDoc.idContact '

--? ----------------- ↑↑↑ Prepare JOINS ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare WHERE AND JSON PATH ↓↓↓ -----------------------
    -- SE CONFIGURA EL WHERE DEPENDIENDO DEL TIPO DE DOCUMENTO
SET @WHERE_CLAUSE=CASE 
        WHEN  @documentType=1 THEN 'WHERE  QuoteDoc.idDocument= @documentId ' -- COTIZACION
        WHEN  @documentType=2 THEN 'WHERE  PreInvoiceDoc.idDocument= @documentId ' --PRE-FACTURA
        WHEN  @documentType=3 THEN 'WHERE  OdcDoc.idDocument= @documentId ' -- ODC 
        WHEN  @documentType=6 THEN 'WHERE  ContractDoc.idDocument= @documentId ' -- CONTRATO
        ELSE 'WHERE  InvoiceDoc.idDocument= @documentId ' -- FACTURA
    END

    -- SE CONFIGURA LA PROPIEDAD JSON PATH PARA RETORNAR UN JSON
    SET @JSON_PATH='FOR JSON PATH,ROOT(''DocumentPopUp'') ';

--? ----------------- ↑↑↑ Prepare WHERE AND JSON PATH ↑↑↑ -----------------------
    -- SE CONFIGURA EL SELECT
SET @SELECT_CLAUSE='SELECT DISTINCT

    ''Cliente'' AS [client.customerType],

 
    ISNULL(FORMAT(QuoteDoc.documentNumber,''0000000''),''ND'') AS [client.documents.quote.number],
    ISNULL(QuoteDoc.idDocument,-1) AS [client.documents.quote.id],
    ISNULL(QuoteCurrency.code,''ND'') AS [client.documents.quote.currency],
    ISNULL(QuoteType.[description],''ND'') AS [client.documents.quote.documentType],
    ISNULL(QuoteDoc.idTypeDocument,-1) AS [client.documents.quote.documentTypeID],
    ISNULL(dbo.fn_FormatCurrency(QuoteDoc.subTotalAmount),''ND'') AS [client.documents.quote.import],
    ISNULL(dbo.fn_FormatCurrency(QuoteDoc.ivaAmount),''ND'') AS [client.documents.quote.iva],
    ISNULL(dbo.fn_FormatCurrency(QuoteDoc.totalAmount),''ND'') AS [client.documents.quote.total],
    ISNULL(dbo.FormatDate(QuoteDoc.createdDate),''ND'') AS [client.documents.quote.beginDate],
    ISNULL(dbo.FormatDate(QuoteDoc.expirationDate),''ND'') AS [client.documents.quote.endDate],
    QuoteCustomer.socialReason AS [client.documents.quote.customer.socialReson],
    QuoteCustomer.rfc AS [client.documents.quote.customer.rfc],
    QuoteCustomer.commercialName AS [client.documents.quote.customer.commercialName],
    QuoteCustomer.shortName AS [client.documents.quote.customer.shortName],
    CASE
        WHEN QuoteContact.firstName IS NULL THEN QuoteCustomer.commercialName
        ELSE CONCAT(QuoteContact.firstName,'' '',QuoteContact.middleName,'' '',QuoteContact.lastName1,'' '',QuoteContact.lastName2)
    END AS [client.documents.quote.contact.name],
    CASE
        WHEN (QuoteContact.phoneNumber IS NULL OR QuoteContact.phoneNumber='' '') THEN CONCAT (''+'',QuoteCustomer.ladaPhone,'' '',QuoteCustomer.phone)
        WHEN (QuoteCustomer.phone IS NULL OR QuoteCustomer.phone ='' '') THEN ''ND''
        ELSE CONCAT(''+'',QuoteContact.phoneNumberAreaCode,'' '',QuoteContact.phoneNumber)
    END AS [client.documents.quote.contact.phone],
    CASE
        WHEN QuoteContact.cellNumber IS NULL THEN CONCAT (''+'',QuoteCustomer.ladaMovil,'' '',QuoteCustomer.movil)
        WHEN (QuoteCustomer.movil IS NULL OR QuoteCustomer.movil ='' '') THEN ''ND''
        ELSE CONCAT(''+'',QuoteContact.cellNumberAreaCode,'' '',QuoteContact.cellNumber)
    END AS [client.documents.quote.contact.cellphone],
    ISNULL(QuoteContact.email,QuoteCustomer.email) AS [client.documents.quote.contact.mail],
    ''Registro'' AS [client.documents.quote.beginDateLabel],
    ''Expiración'' AS [client.documents.quote.endDateLabel],


    ISNULL(FORMAT (PreInvoiceDoc.documentNumber,''0000000''),''ND'') AS [client.documents.preInvoice.number],
    ISNULL(PreInvoiceDoc.idDocument,-1) AS [client.documents.preInvoice.id],
    ISNULL(PreInvoiceCurrency.code,''ND'') AS [client.documents.preInvoice.currency],
    ISNULL(PreInvoiceType.[description],''ND'') AS [client.documents.preInvoice.documentType],
    ISNULL(PreInvoiceDoc.idTypeDocument,-1) AS [client.documents.preInvoice.documentTypeID],
    ISNULL(dbo.fn_FormatCurrency(PreInvoiceDoc.subTotalAmount),''ND'') AS [client.documents.preInvoice.import],
    ISNULL(dbo.fn_FormatCurrency(PreInvoiceDoc.ivaAmount),''ND'') AS [client.documents.preInvoice.iva],
    ISNULL(dbo.fn_FormatCurrency(PreInvoiceDoc.totalAmount),''ND'') AS [client.documents.preInvoice.total],
    ISNULL(dbo.FormatDate(PreInvoiceDoc.createdDate),''ND'') AS [client.documents.preInvoice.beginDate],
    ISNULL(dbo.FormatDate(PreInvoiceDoc.expirationDate),''ND'') AS [client.documents.preInvoice.endDate],
    PreInvoiceCustomer.socialReason AS [client.documents.preInvoice.customer.socialReson],
    PreInvoiceCustomer.rfc AS [client.documents.preInvoice.customer.rfc],
    PreInvoiceCustomer.commercialName AS [client.documents.preInvoice.customer.commercialName],
    PreInvoiceCustomer.shortName AS [client.documents.preInvoice.customer.shortName],
    -- ISNULL(PreInvoiceCustomer.movil,''ND'') AS [client.documents.preInvoice.contact.statusPhone],
    CASE
        WHEN PreInvoiceContact.firstName IS NULL THEN PreInvoiceCustomer.commercialName
        ELSE CONCAT(PreInvoiceContact.firstName,'' '',PreInvoiceContact.middleName,'' '',PreInvoiceContact.lastName1,'' '',PreInvoiceContact.lastName2)
    END AS [client.documents.preInvoice.contact.name],
    CASE
        WHEN PreInvoiceContact.phoneNumber IS NULL THEN CONCAT (''+'',PreInvoiceCustomer.ladaPhone,'' '',PreInvoiceCustomer.phone)
        WHEN (PreInvoiceCustomer.phone IS NULL OR PreInvoiceCustomer.phone ='' '') THEN ''ND''
        ELSE CONCAT(''+'',PreInvoiceContact.phoneNumberAreaCode,'' '',PreInvoiceContact.phoneNumber)
    END AS [client.documents.preInvoice.contact.phone],
    CASE
        WHEN PreInvoiceContact.cellNumber IS NULL THEN CONCAT (''+'',PreInvoiceCustomer.ladaMovil,'' '',PreInvoiceCustomer.movil)
        WHEN (PreInvoiceCustomer.movil IS NULL OR PreInvoiceCustomer.movil ='' '') THEN ''ND''
        ELSE CONCAT(''+'',PreInvoiceContact.cellNumberAreaCode,'' '',PreInvoiceContact.cellNumber)
    END AS [client.documents.preInvoice.contact.cellphone],
    ISNULL(PreInvoiceContact.email,PreInvoiceCustomer.email) AS [client.documents.preInvoice.contact.mail],
    ''Registro'' AS [client.documents.preInvoice.beginDateLabel],
    ''Expiración'' AS [client.documents.preInvoice.endDateLabel],

    ISNULL(InvoiceDoc.noDocument,''ND'') AS [client.documents.invoice.number],
    ISNULL(InvoiceDoc.id,-1) AS [client.documents.invoice.id],
    ISNULL(InvoiceDoc.currencyCode,''ND'') AS [client.documents.invoice.currency],
    ISNULL(InvoiceType.[description],''ND'') AS [client.documents.invoice.documentType],
    ISNULL(InvoiceDoc.idTypeLegalDocument,-1) AS [client.documents.invoice.documentTypeID],
    ISNULL(dbo.fn_FormatCurrency(InvoiceDoc.import),''ND'') AS [client.documents.invoice.import],
    ISNULL(dbo.fn_FormatCurrency(InvoiceDoc.iva),''ND'') AS [client.documents.invoice.iva],
    ISNULL(dbo.fn_FormatCurrency(InvoiceDoc.total),''ND'') AS [client.documents.invoice.total],
    ISNULL(dbo.FormatDate(InvoiceDoc.createdDate),''ND'') AS [client.documents.invoice.beginDate],
    ISNULL(dbo.FormatDate(InvoiceDoc.expirationDate),''ND'') AS [client.documents.invoice.endDate],
    InvoiceCustomer.socialReason AS [client.documents.invoice.customer.socialReson],
    InvoiceCustomer.rfc AS [client.documents.invoice.customer.rfc],
    InvoiceCustomer.commercialName AS [client.documents.invoice.customer.commercialName],
    InvoiceCustomer.shortName AS [client.documents.invoice.customer.shortName],
    CASE
        WHEN InvoiceContact.firstName IS NULL THEN InvoiceCustomer.commercialName
        ELSE CONCAT(InvoiceContact.firstName,'' '',InvoiceContact.middleName,'' '',InvoiceContact.lastName1,'' '',InvoiceContact.lastName2)
    END AS [client.documents.invoice.contact.name],
    CASE
        WHEN InvoiceContact.phoneNumber IS NULL THEN CONCAT (''+'',InvoiceCustomer.ladaPhone,'' '',InvoiceCustomer.phone)
        WHEN (InvoiceCustomer.phone IS NULL OR InvoiceCustomer.phone= '' '') THEN ''ND''
        ELSE CONCAT(''+'',InvoiceContact.phoneNumberAreaCode,'' '',InvoiceContact.phoneNumber)
    END AS [client.documents.invoice.contact.phone],
    CASE
        WHEN InvoiceContact.cellNumber IS NULL THEN CONCAT (''+'',InvoiceCustomer.ladaMovil,'' '',InvoiceCustomer.movil)
        WHEN (InvoiceCustomer.movil IS NULL OR InvoiceCustomer.movil= '' '') THEN ''ND''
        ELSE CONCAT(''+'',InvoiceContact.cellNumberAreaCode,'' '',InvoiceContact.cellNumber)
    END AS [client.documents.invoice.contact.cellphone],
    ISNULL(InvoiceContact.email,InvoiceCustomer.email) AS [client.documents.invoice.contact.mail],
    ''Registro'' AS [client.documents.invoice.beginDateLabel],
    ''Expiración'' AS [client.documents.invoice.endDateLabel],


    ISNULL(FORMAT (ContractDoc.documentNumber,''0000000''),''ND'') AS [client.documents.contract.number],
    ISNULL(ContractDoc.idDocument,-1)AS [client.documents.contract.id],
    ISNULL(ContractCurrency.code,''ND'') AS [client.documents.contract.currency],
    ISNULL(ContractType.[description],''ND'') AS [client.documents.contract.documentType],
    ISNULL(ContractDoc.idTypeDocument,-1) AS [client.documents.contract.documentTypeID],
    ISNULL(dbo.fn_FormatCurrency(ContractDoc.subTotalAmount),''ND'') AS [client.documents.contract.import],
    ISNULL(dbo.fn_FormatCurrency(ContractDoc.ivaAmount),''ND'') AS [client.documents.contract.iva],
    ISNULL(dbo.fn_FormatCurrency(ContractDoc.totalAmount),''ND'') AS [client.documents.contract.total],
    ISNULL(dbo.FormatDate(ContractDoc.reminderDate),''ND'') AS [client.documents.contract.reminder],
    ISNULL(dbo.FormatDate(ContractDoc.createdDate),''ND'') AS [client.documents.contract.beginDate],
    ISNULL(dbo.FormatDate(ContractDoc.expirationDate),''ND'') AS [client.documents.contract.endDate],
    ContractCustomer.socialReason AS [client.documents.contract.customer.socialReson],
    ContractCustomer.rfc AS [client.documents.contract.customer.rfc],
    ContractCustomer.commercialName AS [client.documents.contract.customer.commercialName],
    ContractCustomer.shortName AS [client.documents.contract.customer.shortName],
    CASE
        WHEN ContractContact.firstName IS NULL THEN ContractCustomer.commercialName
        ELSE CONCAT(ContractContact.firstName,'' '',ContractContact.middleName,'' '',ContractContact.lastName1,'' '',ContractContact.lastName2)
    END AS [client.documents.contract.contact.name],
    CASE
        WHEN ContractContact.phoneNumber IS NULL THEN CONCAT (''+'',ContractCustomer.ladaPhone,'' '',ContractCustomer.phone)
        WHEN ContractCustomer.phone IS NULL THEN ''ND''
        ELSE CONCAT(''+'',ContractContact.phoneNumberAreaCode,'' '',ContractContact.phoneNumber)
    END AS [client.documents.contract.contact.phone],
    CASE
        WHEN ContractContact.cellNumber IS NULL THEN CONCAT (''+'',ContractCustomer.ladaMovil,'' '',ContractCustomer.movil)
        WHEN ContractCustomer.movil IS NULL THEN ''ND''
        ELSE CONCAT(''+'',ContractContact.cellNumberAreaCode,'' '',ContractContact.cellNumber)
    END AS [client.documents.contract.contact.cellphone],
    ISNULL(ContractContact.email,ContractCustomer.email) AS [client.documents.contract.contact.mail],
    ''Registro'' AS [client.documents.contract.beginDateLabel],
    ''Expiración'' AS [client.documents.contract.endDateLabel],


    ISNULL(FORMAT (OdcDoc.documentNumber,''0000000''),''ND'') AS [provider.documents.odc.number],
    ISNULL(OdcDoc.idDocument,-1) AS [provider.documents.odc.id],
    ISNULL(OdcCurrency.code,''ND'') AS [provider.documents.odc.currency],
    ISNULL(OdcType.[description],''ND'') AS [provider.documents.odc.documentType],
    ISNULL(OdcDoc.idTypeDocument,-1) AS [provider.documents.odc.documentTypeID],
    ISNULL(dbo.fn_FormatCurrency(OdcDoc.subTotalAmount),''ND'') AS [provider.documents.odc.import],
    ISNULL(dbo.fn_FormatCurrency(OdcDoc.ivaAmount),''ND'') AS [provider.documents.odc.iva],
    ISNULL(dbo.fn_FormatCurrency(OdcDoc.totalAmount),''ND'') AS [provider.documents.odc.total],
    ISNULL(dbo.FormatDate(OdcDoc.createdDate),''ND'') AS [provider.documents.odc.beginDate],
    ISNULL(dbo.FormatDate(OdcDoc.sentDate),''ND'') AS [provider.documents.odc.endDate],
    ProviderCustomer.socialReason AS [provider.documents.odc.customer.socialReson],
    ProviderCustomer.rfc AS [provider.documents.odc.customer.rfc],
    ProviderCustomer.commercialName AS [provider.documents.odc.customer.commercialName],
    ProviderCustomer.shortName AS [provider.documents.odc.customer.shortName],
    CASE
        WHEN ProviderContact.firstName IS NULL THEN ProviderCustomer.commercialName
        ELSE CONCAT(ProviderContact.firstName,'' '',ProviderContact.middleName,'' '',ProviderContact.lastName1,'' '',ProviderContact.lastName2)
    END AS [provider.documents.odc.contact.name],
    CASE
        WHEN ProviderContact.phoneNumber IS NULL THEN CONCAT (''+'',ProviderCustomer.ladaPhone,'' '',ProviderCustomer.phone)
        WHEN ProviderCustomer.phone IS NULL THEN ''ND''
        ELSE CONCAT(''+'',ProviderContact.phoneNumberAreaCode,'' '',ProviderContact.phoneNumber)
    END AS [provider.documents.odc.contact.phone],
    CASE
        WHEN ProviderContact.cellNumber IS NULL THEN CONCAT (''+'',ProviderCustomer.ladaMovil,'' '',ProviderCustomer.movil)
        WHEN ProviderCustomer.movil IS NULL THEN ''ND''
        ELSE CONCAT(''+'',ProviderContact.cellNumberAreaCode,'' '',ProviderContact.cellNumber)
    END AS [provider.documents.odc.contact.cellphone],
    ISNULL(ProviderContact.email,ProviderCustomer.email) AS [provider.documents.odc.contact.mail],
    ''Registro'' AS [provider.documents.odc.beginDateLabel],
    ''Envio'' AS [provider.documents.odc.endDateLabel],
    

    ISNULL(@invoiceReceptionNumber,''ND'') AS [provider.documents.invoiceReception.number],
    ISNULL(@invoiceReceptionDocTypeID,-1) AS [provider.documents.invoiceReception.documentTypeID],
    ISNULL(@invoiceReceptionCurrency,''ND'') AS [provider.documents.invoiceReception.currency],
    ISNULL(@invoiceReceptionDocType,''Factura Recibida'') AS [provider.documents.invoiceReception.documentType],
    ISNULL(@invoiceReceptionImport,''ND'') AS [provider.documents.invoiceReception.import],
    ISNULL(@invoiceReceptionIva,''ND'') AS [provider.documents.invoiceReception.iva],
    ISNULL(@invoiceReceptionTotal,''ND'') AS [provider.documents.invoiceReception.total],
    ISNULL(@invoiceReceptionBeginDate,''ND'') AS [provider.documents.invoiceReception.beginDate],
    ISNULL(@invoiceReceptionEndDate,''ND'') AS [provider.documents.invoiceReception.endDate],
    ProviderCustomer.socialReason AS [provider.documents.invoiceReception.customer.socialReson],
    ProviderCustomer.rfc AS [provider.documents.invoiceReception.customer.rfc],
    ProviderCustomer.commercialName AS [provider.documents.invoiceReception.customer.commercialName],
    ProviderCustomer.shortName AS [provider.documents.invoiceReception.customer.shortName],
    CASE
        WHEN ProviderContact.firstName IS NULL THEN ProviderCustomer.commercialName
        ELSE CONCAT(ProviderContact.firstName,'' '',ProviderContact.middleName,'' '',ProviderContact.lastName1,'' '',ProviderContact.lastName2)
    END AS [provider.documents.invoiceReception.contact.name],
    CASE
        WHEN ProviderContact.phoneNumber IS NULL THEN CONCAT (''+'',ProviderCustomer.ladaPhone,'' '',ProviderCustomer.phone)
        WHEN ProviderCustomer.phone IS NULL THEN ''ND''
        ELSE CONCAT(''+'',ProviderContact.phoneNumberAreaCode,'' '',ProviderContact.phoneNumber)
    END AS [provider.documents.invoiceReception.contact.phone],
    CASE
        WHEN ProviderContact.cellNumber IS NULL THEN CONCAT (''+'',ProviderCustomer.ladaMovil,'' '',ProviderCustomer.movil)
        WHEN ProviderCustomer.movil IS NULL THEN ''ND''
        ELSE CONCAT(''+'',ProviderContact.cellNumberAreaCode,'' '',ProviderContact.cellNumber)
    END AS [provider.documents.invoiceReception.contact.cellphone],
    ISNULL(ProviderContact.email,ProviderCustomer.email) AS [provider.documents.invoiceReception.contact.mail],
    ''Expedición'' AS [provider.documents.invoiceReception.beginDateLabel],
    ''Recepción'' AS [provider.documents.invoiceReception.endDateLabel],

    ''Proveedor'' AS [provider.customerType] '


--? ----------------- ↓↓↓ Prepare SP and execute ↓↓↓ -----------------------

    SET @SP_GET_POPUP_DOCUMENT= @SELECT_CLAUSE + @FROM_CLAUSE + @JOIN_CLAUSE + @WHERE_CLAUSE + @JSON_PATH;
    EXEC SP_EXECUTESQL @SP_GET_POPUP_DOCUMENT,@PARAMS, @documentId,@invoiceReceptionNumber,@invoiceReceptionDocType,@invoiceReceptionDocTypeID,@invoiceReceptionCurrency,@invoiceReceptionImport,@invoiceReceptionIva,@invoiceReceptionTotal,@invoiceReceptionBeginDate,@invoiceReceptionEndDate,@quoteID,@preinvoiceId,@odcId,@contractID,@invoiceId,@customerProviderId


--? ----------------- ↑↑↑ Prepare SP and execute ↑↑↑ -----------------------


END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------