--* ----------------- ↓↓↓ Global variables ↓↓↓ -----------------------

DECLARE @documentId INT;-- ID DEL DOCUMENTO

--* ----------------- ↑↑↑ Global variables ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Set Global variables ↓↓↓ -----------------------

SET @documentId = 2777 ;-- ID DEL DOCUMENTO

--? ----------------- ↑↑↑ Set Global variables ↑↑↑ ----------------------


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
    

--* ----------------- ↑↑↑ Local varibles ↑↑↑ -----------------------



--? ----------------- ↓↓↓ Prepare PARAMS ↓↓↓ -----------------------

    SET @PARAMS ='@documentId INT, @invoiceReceptionNumber NVARCHAR(256), @quoteID INT, @preinvoiceId INT, @odcId INT, @contractID INT, @invoiceId INT, @customerProviderId INT '; 

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
       @invoiceReceptionNumber= noDocument
    FROM LegalDocuments WHERE uuid=@odcUUID

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
                  LEFT JOIN Currencies AS ContractCurrency ON ContractCurrency.currencyID=ContractDoc.idCurrency '

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
    ISNULL(CustomerClient.socialReason,''ND'') AS [client.socialReason],
    ISNULL(CustomerClient.rfc,''ND'') AS [client.rfc],
    ISNULL(CustomerClient.commercialName,''ND'') AS [client.comertialName],
    ISNULL(CustomerClient.shortName,''ND'') AS [client.shortName],


    ISNULL(FORMAT(QuoteDoc.documentNumber,''0000000''),''ND'') AS [documents.quote.number],
    ISNULL(QuoteDoc.idDocument,-1) AS [documents.quote.id],
    ISNULL(QuoteCurrency.code,''ND'') AS [documents.quote.currency],
    ISNULL(dbo.fn_FormatCurrency(QuoteDoc.subTotalAmount),''ND'') AS [documents.quote.import],
    ISNULL(dbo.fn_FormatCurrency(QuoteDoc.ivaAmount),''ND'') AS [documents.quote.iva],
    ISNULL(dbo.fn_FormatCurrency(QuoteDoc.totalAmount),''ND'') AS [documents.quote.total],


    ISNULL(FORMAT (PreInvoiceDoc.documentNumber,''0000000''),''ND'') AS [documents.preInvoice.number],
    ISNULL(FORMAT (PreInvoiceDoc.invoiceNumberSupplier,''0000000''),''Pendiente de facturar'') AS [documents.preInvoice.invoiceNumber],
    ISNULL(PreInvoiceDoc.idDocument,-1) AS [documents.preInvoice.id],
    ISNULL(PreInvoiceCurrency.code,''ND'') AS [documents.preInvoice.currency],
    ISNULL(dbo.fn_FormatCurrency(PreInvoiceDoc.subTotalAmount),''ND'') AS [documents.preInvoice.import],
    ISNULL(dbo.fn_FormatCurrency(PreInvoiceDoc.ivaAmount),''ND'') AS [documents.preInvoice.iva],
    ISNULL(dbo.fn_FormatCurrency(PreInvoiceDoc.totalAmount),''ND'') AS [documents.preInvoice.total],


    ISNULL(FORMAT (ContractDoc.documentNumber,''0000000''),''ND'') AS [documents.contract.number],
    ISNULL(ContractDoc.idDocument,-1)AS [documents.contract.id],
    ISNULL(ContractCurrency.code,''ND'') AS [documents.contract.currency],
    ISNULL(dbo.fn_FormatCurrency(ContractDoc.subTotalAmount),''ND'') AS [documents.contract.import],
    ISNULL(dbo.fn_FormatCurrency(ContractDoc.ivaAmount),''ND'') AS [documents.contract.iva],
    ISNULL(dbo.fn_FormatCurrency(ContractDoc.totalAmount),''ND'') AS [documents.contract.total],
    ISNULL(dbo.FormatDate(ContractDoc.reminderDate),''ND'') AS [documents.contract.reminder],


    ISNULL(FORMAT (OdcDoc.documentNumber,''0000000''),''ND'') AS [documents.odc.number],
    ISNULL(OdcDoc.idDocument,-1) AS [documents.odc.id],
    ISNULL(@invoiceReceptionNumber,''Factura no recibida'') AS [documents.odc.invoiceReceptionNumber],
    ISNULL(OdcCurrency.code,''ND'') AS [documents.odc.currency],
    ISNULL(dbo.fn_FormatCurrency(OdcDoc.subTotalAmount),''ND'') AS [documents.odc.import],
    ISNULL(dbo.fn_FormatCurrency(OdcDoc.ivaAmount),''ND'') AS [documents.odc.iva],
    ISNULL(dbo.fn_FormatCurrency(OdcDoc.totalAmount),''ND'') AS [documents.odc.total],
    

    ISNULL(CustomerProvider.socialReason,''ND'') AS [provider.socialReason],
    ISNULL(CustomerProvider.rfc,''ND'') AS [provider.rfc],
    ISNULL(CustomerProvider.commercialName,''ND'') AS [provider.comertialName],
    ISNULL(CustomerProvider.shortName,''ND'') AS [provider.shortName] '


--? ----------------- ↓↓↓ Prepare SP and execute ↓↓↓ -----------------------

    SET @SP_GET_POPUP_DOCUMENT= @SELECT_CLAUSE + @FROM_CLAUSE + @JOIN_CLAUSE + @WHERE_CLAUSE + @JSON_PATH;
    EXEC SP_EXECUTESQL @SP_GET_POPUP_DOCUMENT,@PARAMS, @documentId,@invoiceReceptionNumber,@quoteID,@preinvoiceId,@odcId,@contractID,@invoiceId,@customerProviderId


--? ----------------- ↑↑↑ Prepare SP and execute ↑↑↑ -----------------------



-- ! ********************************************************************************************************
-- SELECT DISTINCT
--     ISNULL(CustomerClient.socialReason,'ND') AS [client.socialReason],
--     ISNULL(CustomerClient.rfc,'ND') AS [client.rfc],
--     ISNULL(CustomerClient.commercialName,'ND') AS [client.comertialName],
--     ISNULL(CustomerClient.shortName,'ND') AS [client.shortName],

-- -- ? COTIZACION
--     ISNULL(FORMAT(QuoteDoc.documentNumber,'0000000'),'ND') AS [documents.quote.number],
--     ISNULL(QuoteDoc.idDocument,-1) AS [documents.quote.id],
--     ISNULL(QuoteCurrency.code,'ND') AS [documents.quote.currency],
--     ISNULL(dbo.fn_FormatCurrency(QuoteDoc.subTotalAmount),'ND') AS [documents.quote.import],
--     ISNULL(dbo.fn_FormatCurrency(QuoteDoc.ivaAmount),'ND') AS [documents.quote.iva],
--     ISNULL(dbo.fn_FormatCurrency(QuoteDoc.totalAmount),'ND') AS [documents.quote.total],

-- -- ? PREFACTURA
--     ISNULL(FORMAT (PreInvoiceDoc.documentNumber,'0000000'),'ND') AS [documents.preInvoice.number],
--     ISNULL(FORMAT(PreInvoiceDoc.invoiceNumberSupplier,'0000000'),'Pendiente de facturar') AS [documents.preInvoice.invoiceNumber],
--     ISNULL(PreInvoiceDoc.idDocument,-1) AS [documents.preInvoice.id],
--     ISNULL(PreInvoiceCurrency.code,'ND') AS [documents.preInvoice.currency],

--     ISNULL(dbo.fn_FormatCurrency(PreInvoiceDoc.subTotalAmount),'ND') AS [documents.preInvoice.import],
--     ISNULL(dbo.fn_FormatCurrency(PreInvoiceDoc.ivaAmount),'ND') AS [documents.preInvoice.iva],
--     ISNULL(dbo.fn_FormatCurrency(PreInvoiceDoc.totalAmount),'ND') AS [documents.preInvoice.total],

-- -- ? CONTRATO
--     ISNULL(FORMAT (ContractDoc.documentNumber,'0000000'),'ND') AS [documents.contract.number],
--     ISNULL(ContractDoc.idDocument,-1)AS [documents.contract.id],
--     ISNULL(ContractCurrency.code,'ND') AS [documents.contract.currency],
--     ISNULL(dbo.fn_FormatCurrency(ContractDoc.subTotalAmount),'ND') AS [documents.contract.import],
--     ISNULL(dbo.fn_FormatCurrency(ContractDoc.ivaAmount),'ND') AS [documents.contract.iva],
--     ISNULL(dbo.fn_FormatCurrency(ContractDoc.totalAmount),'ND') AS [documents.contract.total],
--     ISNULL(dbo.FormatDate(ContractDoc.reminderDate),'ND') AS [documents.contract.reminder],

-- -- ? ODC
--     ISNULL(FORMAT (OdcDoc.documentNumber,'0000000'),'ND') AS [documents.odc.number],
--     ISNULL(OdcDoc.idDocument,-1) AS [documents.odc.id],
--     ISNULL(@invoiceReceptionNumber,'Factura no recibida') AS [documents.odc.invoiceReceptionNumber],
--     ISNULL(OdcCurrency.code,'ND') AS [documents.odc.currency],
--     ISNULL(dbo.fn_FormatCurrency(OdcDoc.subTotalAmount),'ND') AS [documents.odc.import],
--     ISNULL(dbo.fn_FormatCurrency(OdcDoc.ivaAmount),'ND') AS [documents.odc.iva],
--     ISNULL(dbo.fn_FormatCurrency(OdcDoc.totalAmount),'ND') AS [documents.odc.total],
    
--     ISNULL(CustomerProvider.socialReason,'ND') AS [provider.socialReason],
--     ISNULL(CustomerProvider.rfc,'ND') AS [provider.rfc],
--     ISNULL(CustomerProvider.commercialName,'ND') AS [provider.comertialName],
--     ISNULL(CustomerProvider.shortName,'ND') AS [provider.shortName]

-- FROM Documents AS QuoteDoc 
--     LEFT JOIN Documents AS PreInvoiceDoc ON PreInvoiceDoc.idDocument=@preinvoiceId
--     LEFT JOIN Documents AS OdcDoc ON  OdcDoc.idDocument=@odcId
--     LEFT JOIN Documents AS ContractDoc ON  ContractDoc.idDocument=@contractID
--     -- LEFT JOIN Documents AS InvoiceDoc ON  InvoiceDoc.idDocument=@invoiceId
--     --? Nuevos joins
--     LEFT JOIN Customers AS CustomerClient ON QuoteDoc.idCustomer=CustomerClient.customerID
--     LEFT JOIN Customers AS CustomerProvider ON CustomerProvider.customerID=@customerProviderId
--     LEFT JOIN Currencies AS QuoteCurrency ON QuoteCurrency.currencyID=QuoteDoc.idCurrency
--     LEFT JOIN Currencies AS PreInvoiceCurrency ON PreInvoiceCurrency.currencyID=PreInvoiceDoc.idCurrency
--     LEFT JOIN Currencies AS OdcCurrency ON OdcCurrency.currencyID=OdcDoc.idCurrency
--     LEFT JOIN Currencies AS ContractCurrency ON ContractCurrency.currencyID=ContractDoc.idCurrency
--     -- LEFT JOIN Currencies AS InvoiceCurrency ON InvoiceCurrency.currencyID=InvoiceDoc.idCurrency

-- WHERE QuoteDoc.idDocument=@documentId
-- FOR JSON PATH,ROOT('DocumentPopUp')

