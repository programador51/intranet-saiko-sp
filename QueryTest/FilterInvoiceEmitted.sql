

--* ----------------- ↓↓↓ Global variables ↓↓↓ -----------------------

DECLARE @executiveId INT;-- ID DEL EJECUTIVO
DECLARE @documentNumber INT;-- ID DEL EJECUTIVO
DECLARE @statusId INT;-- ID DEL ESTATUS 
DECLARE @BeginDate DATETIME;-- FECHA DE INICIO
DECLARE @EndDate DATETIME;-- FECHA DE FIN
DECLARE @pageRequested INT;-- CANTIDAD DE PAGINAS SOLICITADAS

--* ----------------- ↑↑↑ Global variables ↑↑↑ -----------------------

--? ----------------- ↓↓↓ Set Global variables ↓↓↓ -----------------------

SET @executiveId = 14 ;-- ID DEL EJECUTIVO
SET @documentNumber= 3 ;-- ID DEL EJECUTIVO
SET @statusId= 10 ;-- ID DEL ESTATUS 
SET @BeginDate = '2022-01-01';-- FECHA DE INICIO
SET @EndDate = '2022-12-31';-- FECHA DE FIN
SET @pageRequested = 1;-- CANTIDAD DE PAGINAS SOLICITADAS

--? ----------------- ↑↑↑ Set Global variables ↑↑↑ -----------------------



--* ----------------- ↓↓↓ DYNIMIC QUERY VARIABLES ↓↓↓ -----------------------

    DECLARE @PARAMS NVARCHAR (MAX);-- LOS 'PARAMETROS' PARA OBTENER LOS REGISTROS DE LA TABLA
    DECLARE @PARAMS_PAGINATION NVARCHAR (MAX);-- LOS 'PARAMETROS' PARA LA PAGINACION
    DECLARE @JOIN_CLAUSE NVARCHAR(MAX);-- 'JOINS' NECESARIOS 
    DECLARE @FROM_CLAUSE NVARCHAR (MAX);-- 'FROM'
    DECLARE @WHERE_CLAUSE NVARCHAR (MAX);-- CONDICION 'WHERE' QUE SE REPITE PARA TODOS LOS ESCENARIOS DEL FILTRO
    DECLARE @FILTER_CLAUSE NVARCHAR (MAX)='';-- FILTRO DIDAMICO. CAMBIA SEGUN EL ESTATUS,EJECUTIVO,FECHA, Y/O NO.DOCUMENTO
    DECLARE @SELECT_CLAUSE NVARCHAR (MAX);-- LA SENTENCIA 'SELECT'. SE REPITE EN TODAS LAS CONSULTAS
    DECLARE @SELECT_PAGINATION NVARCHAR (MAX);-- LA SENTENCIA 'SELECT' PARA LA PAGINACIÓN
    DECLARE @OFFSET NVARCHAR(MAX);-- SENTENCIA OFFSET.


--* ----------------- ↑↑↑ DYNIMIC QUERY VARIABLES ↑↑↑ -----------------------


--* ----------------- ↓↓↓ DYNIMIC STOREPROCEDURES↓↓↓ -----------------------

    DECLARE @SP_CALCULATE_PAGINATION NVARCHAR (MAX);-- VARIABLE DONDE SE GUARDA EL STOREPROCEDURE FINAL PARA OBTENER LA PAGINACION
    DECLARE @SP_GET_INVOICE_EMITTED NVARCHAR (MAX);-- VARIABLE DONDE SE GUARDA EL STOREPROCEDURE FINAL PARA OBTENER LAS FACTURAS

--* ----------------- ↑↑↑ DYNIMIC STOREPROCEDURES ↑↑↑ -----------------------



--* ----------------- ↓↓↓ Local varibles ↓↓↓ -----------------------
    
    DECLARE @noRegisters INT; -- Number of registers founded
    DECLARE @offsetValue INT;-- Since which register start searching the information
    DECLARE @totalPages DECIMAL;-- Total pages founded on the query
    DECLARE @rowsPerPage INT = 10;-- LIMIT of registers that can be returned per query

--* ----------------- ↑↑↑ Local varibles ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare PARAMS ↓↓↓ -----------------------

    SET @PARAMS ='@executiveId INT, @documentNumber INT, @statusId INT, @BeginDate DATETIME, @EndDate DATETIME, @pageRequested INT ';
    SET @PARAMS_PAGINATION = '@executiveId INT, @documentNumber INT, @statusId INT, @BeginDate DATETIME, @EndDate DATETIME, @noRegistersOut INT OUTPUT ';

--? ----------------- ↑↑↑ Prepare PARAMS ↑↑↑ -----------------------




--? ----------------- ↓↓↓ Prepare FROM, WHERE and FILTER ↓↓↓ -----------------------

    SET @FROM_CLAUSE='FROM Documents ';
    SET @WHERE_CLAUSE='WHERE Documents.idTypeDocument=2 ';

    -- ----------------- ↓↓↓ Estatus ↓↓↓ -----------------------
    IF @statusId != -1
        BEGIN
            --SIGNIFICA QUE SE BUSCA POR UN ESTATUS QUE NO ES 'TODOS'
            SET @FILTER_CLAUSE= @FILTER_CLAUSE + 'AND Documents.idStatus=@statusId ';
        END
    ELSE
        BEGIN
            --SIGNIFICA QUE SE BUSCA POR EL ESTATUS 'TODOS'
            SET @FILTER_CLAUSE= @FILTER_CLAUSE + ' ';
        END

    -- ----------------- ↑↑↑ Estatus ↑↑↑ -----------------------

    -- ----------------- ↓↓↓ Ejecutivo ↓↓↓ -----------------------
    IF @executiveId != -1
        BEGIN
            --SIGNIFICA QUE SE BUSCA POR UN EJECUTIVO QUE NO ES 'TODOS'
            SET @FILTER_CLAUSE= @FILTER_CLAUSE + 'AND Documents.idExecutive=@executiveId ';
        END
    ELSE
        BEGIN
            --SIGNIFICA QUE SE BUSCA POR EL EJECUTIVO 'TODOS'
            SET @FILTER_CLAUSE= @FILTER_CLAUSE + ' ';
        END
    -- ----------------- ↑↑↑ Ejecutivo ↑↑↑ -----------------------

    -- ----------------- ↓↓↓ No documento ↓↓↓ -----------------------
    IF @documentNumber != -1
        BEGIN
            --SIGNIFICA QUE SE BUSCA POR UN NUMERO DE DOCUMENTO'
            SET @FILTER_CLAUSE= @FILTER_CLAUSE + 'AND Documents.documentNumber=@documentNumber ';
        END
    ELSE
        BEGIN
            --SIGNIFICA QUE NO SE BUSCA POR NUMERO DE DOCUMENTO'
            SET @FILTER_CLAUSE= @FILTER_CLAUSE + ' ';
        END
    -- ----------------- ↑↑↑ No documento ↑↑↑ -----------------------

    SET @FILTER_CLAUSE= @FILTER_CLAUSE + 'AND (Documents.createdDate BETWEEN @BeginDate AND @EndDate) ';-- FILTRO FINAL
    SET @WHERE_CLAUSE= @WHERE_CLAUSE + @FILTER_CLAUSE;-- WHERE FINAL

--? ----------------- ↑↑↑ Prepare FROM, WHERE and FILTER ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare Pagination ↓↓↓ -----------------------
    SET @SELECT_PAGINATION = 'SELECT @noRegistersOut = COUNT(*) ';-- SENTENCIA 'SELECT' QUE GUARDA LOS NO. DE REGISTROS
    SET @SP_CALCULATE_PAGINATION = @SELECT_PAGINATION + @FROM_CLAUSE + @WHERE_CLAUSE; -- SP DE LAS PAGINAS
    EXEC SP_EXECUTESQL @SP_CALCULATE_PAGINATION,@PARAMS_PAGINATION,@executiveId,@documentNumber,@statusId,@BeginDate,@EndDate,@noRegistersOut=@noRegisters OUTPUT;--RETORNO DE LOS NO. REGISTROS ENCONTRADOS

    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;

    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    SET @OFFSET = 'ORDER BY Documents.idDocument DESC OFFSET ' + CONVERT(NVARCHAR,@offsetValue) + ' ROWS FETCH NEXT ' + CONVERT(NVARCHAR,@rowsPerPage) + ' ROWS ONLY;'
    

--? ----------------- ↑↑↑ Prepare Pagination ↑↑↑ -----------------------

--? ----------------- ↓↓↓ Prepare JOINS AND SELECT facturas emitidas ↓↓↓ -----------------------

    SET @JOIN_CLAUSE='LEFT JOIN Users ON Documents.idExecutive=Users.userID
    LEFT JOIN Customers AS Customer ON Documents.idCustomer=Customer.customerID
    LEFT JOIN Contacts AS Contact ON Documents.idContact=Contact.contactID
    LEFT JOIN Currencies AS Currencie ON Documents.idCurrency=Currencie.currencyID
    LEFT JOIN Documents AS subDoc1 ON Documents.idContract=subDoc1.idDocument
    LEFT JOIN Documents AS subDoc2 ON Documents.idQuotation=subDoc2.idDocument
    LEFT JOIN Documents AS subDoc3 ON Documents.idInvoice=subDoc3.idDocument
    LEFT JOIN Documents AS subDoc4 ON Documents.idOC=subDoc4.idDocument
    LEFT JOIN DocumentStatus AS DocStatus ON Documents.idStatus=DocStatus.documentStatusID ';

    SET @SELECT_CLAUSE='SELECT 
    Documents.idDocument,
    ISNULL(FORMAT(Documents.documentNumber,''0000000''),''0000001'') AS documentNumber,
    dbo.fn_FormatCurrency(Documents.subTotalAmount) AS import,
    dbo.fn_FormatCurrency(Documents.ivaAmount) AS iva,
    dbo.fn_FormatCurrency(Documents.totalAmount) AS total,
    dbo.fn_FormatCurrency(Documents.totalAcreditedAmount) AS acreditado,
    CASE 
        WHEN Documents.amountToPay IS NULL THEN dbo.fn_FormatCurrency(Documents.totalAmount)
        ELSE dbo.fn_FormatCurrency(Documents.amountToPay)
    END AS residue,
    Documents.invoiceMizarNumber,
    Documents.idContract,
    ISNULL(FORMAT(subDoc1.documentNumber,''0000000''),''0000001'') AS contractNumber,
    Documents.idQuotation,
    ISNULL(FORMAT(subDoc2.documentNumber,''0000000''),''0000001'') AS quotationNumber,
    Documents.idInvoice,
    ISNULL(FORMAT(subDoc3.documentNumber,''0000000''),''0000001'') AS invoiceNumber,
    ISNULL(FORMAT(subDoc4.documentNumber,''0000000''),''0000001'') AS odcNumber,
    Documents.idExecutive,
    CONCAT(Users.firstName,'' '',Users.middleName,'' '',Users.lastName1,'' '',Users.lastName2) AS executiveName,
    dbo.fn_initialsName(CONCAT(Users.firstName,'' '',Users.middleName,'' '',Users.lastName1,'' '',Users.lastName2)) AS initials,
    Documents.idCustomer,
    Customer.socialReason,
    Documents.idContact,
    dbo.fn_ConcatPhones(Contact.cellNumberAreaCode,Contact.cellNumber,Customer.ladaMovil,Customer.movil) AS cellPhone,
    dbo.fn_ConcatPhones(Contact.phoneNumber,Contact.phoneNumberAreaCode,Customer.ladaPhone,Customer.phone)AS phoneNumber,
    Documents.idCurrency,
    Currencie.code,
    dbo.fn_FormatCurrency(Documents.protected) AS TC,
    DocStatus.[description] AS estatus,
    Documents.idStatus AS idStatus,
    dbo.FormatDate(Documents.createdDate) AS createdDate,
    dbo.FormatDate(Documents.expirationDate) AS expirationDate ';

    SET @SP_GET_INVOICE_EMITTED= @SELECT_CLAUSE + @FROM_CLAUSE + @JOIN_CLAUSE + @WHERE_CLAUSE + @OFFSET;

--? ----------------- ↑↑↑ Prepare JOINS AND SELECT facturas emitidas ↑↑↑ -----------------------



--? ----------------- ↓↓↓ Retrive data needed ↓↓↓ -----------------------

    EXEC SP_EXECUTESQL @SP_GET_INVOICE_EMITTED,@PARAMS,@executiveId,@documentNumber,@statusId,@BeginDate,@EndDate,@pageRequested
    SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters;

--? ----------------- ↑↑↑ Retrive data needed  ↑↑↑ -----------------------

PRINT 'FACTURAS...'
PRINT @SP_GET_INVOICE_EMITTED
PRINT '----------------------------------'
PRINT 'PAGINAS'
PRINT @SP_CALCULATE_PAGINATION



-- ! ********************************************************************************************************
SELECT 
    Documents.idDocument,
    ISNULL(FORMAT(Documents.documentNumber,'0000000'),'0000001') AS documentNumber,
    dbo.fn_FormatCurrency(Documents.subTotalAmount) AS import,
    dbo.fn_FormatCurrency(Documents.ivaAmount) AS iva,
    dbo.fn_FormatCurrency(Documents.totalAmount) AS total,
    dbo.fn_FormatCurrency(Documents.totalAcreditedAmount) AS acreditado,
    CASE 
        WHEN Documents.amountToPay IS NULL THEN dbo.fn_FormatCurrency(Documents.totalAmount)
        ELSE dbo.fn_FormatCurrency(Documents.amountToPay)
    END AS residue,
    Documents.invoiceMizarNumber,
    Documents.idContract,
    ISNULL(FORMAT(subDoc1.documentNumber,'0000000'),'0000001') AS contractNumber,
    Documents.idQuotation,
    ISNULL(FORMAT(subDoc2.documentNumber,'0000000'),'0000001') AS quotationNumber,
    Documents.idInvoice,
    ISNULL(FORMAT(subDoc3.documentNumber,'0000000'),'0000001') AS invoiceNumber,
    ISNULL(FORMAT(subDoc4.documentNumber,'0000000'),'0000001') AS odcNumber,
    Documents.idExecutive,
    CONCAT(Users.firstName,' ',Users.middleName,' ',Users.lastName1,' ',Users.lastName2) AS executiveName,
    dbo.fn_initialsName(CONCAT(Users.firstName,' ',Users.middleName,' ',Users.lastName1,' ',Users.lastName2)) AS initials,
    Documents.idCustomer,
    Customer.socialReason,
    Documents.idContact,
    dbo.fn_ConcatPhones(Contact.cellNumberAreaCode,Contact.cellNumber,Customer.ladaMovil,Customer.movil) AS cellPhone,
    dbo.fn_ConcatPhones(Contact.phoneNumber,Contact.phoneNumberAreaCode,Customer.ladaPhone,Customer.phone)AS phoneNumber,
    Documents.idCurrency,
    Currencie.code,
    dbo.fn_FormatCurrency(Documents.protected) AS TC,
    DocStatus.[description] AS estatus,
    Documents.idStatus AS idStatus,
    dbo.FormatDate(Documents.createdDate) AS createdDate,
    dbo.FormatDate(Documents.expirationDate) AS expirationDate

FROM Documents 
-- 
LEFT JOIN Users ON Documents.idExecutive=Users.userID
LEFT JOIN Customers AS Customer ON Documents.idCustomer=Customer.customerID
LEFT JOIN Contacts AS Contact ON Documents.idContact=Contact.contactID
LEFT JOIN Currencies AS Currencie ON Documents.idCurrency=Currencie.currencyID
LEFT JOIN Documents AS subDoc1 ON Documents.idContract=subDoc1.idDocument
LEFT JOIN Documents AS subDoc2 ON Documents.idQuotation=subDoc2.idDocument
LEFT JOIN Documents AS subDoc3 ON Documents.idInvoice=subDoc3.idDocument
LEFT JOIN Documents AS subDoc4 ON Documents.idOC=subDoc4.idDocument
LEFT JOIN DocumentStatus AS DocStatus ON Documents.idStatus=DocStatus.documentStatusID
-- 
WHERE Documents.idTypeDocument=2

-- ! **************************************************************


SELECT *