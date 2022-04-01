--* ----------------- ↓↓↓ Global variables ↓↓↓ -----------------------

DECLARE @statusId INT;-- ID DEL ESTATUS 
DECLARE @search NVARCHAR(256);-- EL INPUT PARA BUSCAR
DECLARE @startDate DATETIME;
DECLARE @endDate DATETIME;
DECLARE @pageRequested INT;-- CANTIDAD DE PAGINAS SOLICITADAS

--* ----------------- ↑↑↑ Global variables ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Set Global variables ↓↓↓ -----------------------


SET @statusId= 7 ;-- ID DEL ESTATUS 
SET @search= '-1' ;-- EL VALOR DE LA BUSQUEDA 
SET @startDate='2022-02-01'-- FECHA DE INICIO
SET @endDate='2022-03-31'-- FECHA FIN
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

    SET @PARAMS ='@statusId INT, @search NVARCHAR(256),@startDate DATETIME, @endDate DATETIME, @pageRequested INT ';
    SET @PARAMS_PAGINATION = '@statusId INT, @search NVARCHAR(256), @startDate DATETIME, @endDate DATETIME, @noRegistersOut INT OUTPUT ';

--? ----------------- ↑↑↑ Prepare PARAMS ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare FROM ↓↓↓ -----------------------

    SET @FROM_CLAUSE='FROM LegalDocuments AS Invoice ';

--? ----------------- ↑↑↑ Prepare FROM ↑↑↑ -----------------------



--? ----------------- ↓↓↓ Prepare FILTER ↓↓↓ -----------------------

    IF (@search IS NULL OR @search= '-1')
        BEGIN
            SET @FILTER_CLAUSE='AND Invoice.idLegalDocumentStatus=@statusId ';

        END
    ELSE 
        BEGIN
            SET @search= @search + '%';
            SET @FILTER_CLAUSE='AND Invoice.idLegalDocumentStatus=@statusId AND Invoice.socialReason LIKE @search ';
        END

        SET @FILTER_CLAUSE=@FILTER_CLAUSE + 'AND (Invoice.createdDate BETWEEN @startDate AND @endDate) ';

--? ----------------- ↑↑↑ Prepare FILTER ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare WHERE ↓↓↓ -----------------------

    SET @WHERE_CLAUSE='WHERE Invoice.idTypeLegalDocument=2 ' + @FILTER_CLAUSE

--? ----------------- ↑↑↑ Prepare WHERE ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare Pagination ↓↓↓ -----------------------
    SET @SELECT_PAGINATION = 'SELECT @noRegistersOut = COUNT(*) ';-- SENTENCIA 'SELECT' QUE GUARDA LOS NO. DE REGISTROS
    SET @SP_CALCULATE_PAGINATION = @SELECT_PAGINATION + @FROM_CLAUSE + @WHERE_CLAUSE; -- SP DE LAS PAGINAS
    EXEC SP_EXECUTESQL @SP_CALCULATE_PAGINATION,@PARAMS_PAGINATION, @statusId, @search,@startDate, @endDate,  @noRegistersOut=@noRegisters OUTPUT;--RETORNO DE LOS NO. REGISTROS ENCONTRADOS

    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;

    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    SET @OFFSET = 'ORDER BY Invoice.id DESC OFFSET ' + CONVERT(NVARCHAR,@offsetValue) + ' ROWS FETCH NEXT ' + CONVERT(NVARCHAR,@rowsPerPage) + ' ROWS ONLY;'
    

--? ----------------- ↑↑↑ Prepare Pagination ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare JOINS AND SELECT facturas emitidas ↓↓↓ -----------------------

    SET @JOIN_CLAUSE='LEFT JOIN LegalDocumentStatus AS InvoiceStatus ON InvoiceStatus.id=Invoice.idLegalDocumentStatus ';

    SET @SELECT_CLAUSE= 'SELECT
    Invoice.noDocument,
    Invoice.id,
    dbo.FormatDate(Invoice.createdDate) AS createdDate,
    Invoice.socialReason,
    Invoice.currencyCode,
    dbo.fn_FormatCurrency(Invoice.import) AS import,
    dbo.fn_FormatCurrency(Invoice.iva) AS iva,
    dbo.fn_FormatCurrency(Invoice.total) AS total,
    dbo.fn_FormatCurrency(Invoice.acumulated) AS acumulated,
    dbo.fn_FormatCurrency(Invoice.residue) AS residue,
    Invoice.idLegalDocumentStatus,
    InvoiceStatus.[description] AS invoiceStatus '

    SET @SP_GET_INVOICE_EMITTED= @SELECT_CLAUSE + @FROM_CLAUSE + @JOIN_CLAUSE + @WHERE_CLAUSE + @OFFSET;
--? ----------------- ↑↑↑ Prepare JOINS AND SELECT facturas emitidas ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Retrive data needed ↓↓↓ -----------------------

    EXEC SP_EXECUTESQL @SP_GET_INVOICE_EMITTED,@PARAMS,@statusId, @search,@startDate, @endDate, @pageRequested
    SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters;

--? ----------------- ↑↑↑ Retrive data needed  ↑↑↑ -----------------------


-- SELECT
--     Invoice.noDocument,
--     Invoice.id,
--     dbo.FormatDate(Invoice.createdDate) AS createdDate,
--     Invoice.socialReason,
--     Invoice.currencyCode,
--     dbo.fn_FormatCurrency(Invoice.import) AS import,
--     dbo.fn_FormatCurrency(Invoice.iva) AS iva,
--     dbo.fn_FormatCurrency(Invoice.total) AS total,
--     dbo.fn_FormatCurrency(Invoice.acumulated) AS acumulated,
--     dbo.fn_FormatCurrency(Invoice.residue) AS residue,
--     Invoice.idLegalDocumentStatus,
--     InvoiceStatus.[description] AS invoiceStatus

-- FROM LegalDocuments AS Invoice
--     LEFT JOIN LegalDocumentStatus AS InvoiceStatus ON InvoiceStatus.id=Invoice.idLegalDocumentStatus
-- WHERE (Invoice.createdDate BETWEEN '20220201' AND '20220331') AND Invoice.idTypeLegalDocument=2 AND Invoice.idLegalDocumentStatus=7

-- SELECT * FROM LegalDocuments
-- SELECT * FROM LegalDocumentStatus