    DECLARE @beginDate_Date DATE = '2022-01-01';
DECLARE @endDate_Date DATE = '2022-12-10';

DECLARE @beginDate DATETIME = @beginDate_Date;
DECLARE @endDate DATETIME = @endDate_Date;
    
    --* ----------------- ↓↓↓ GLOBAL VARIABLES ↓↓↓ -----------------------

    DECLARE @customerId INT;
    DECLARE @statusId INT=9;
    -- DECLARE @beginDate DATETIME;
    -- DECLARE @endDate DATETIME;
    DECLARE @search NVARCHAR(15)= NULL;
    DECLARE @pageRequested INT=1


    --* ----------------- ↑↑↑ GLOBAL VARIABLES ↑↑↑ -----------------------

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

    SET @PARAMS ='@customerId INT, @statusId INT, @beginDate DATETIME, @endDate DATETIME, @search NVARCHAR(15), @pageRequested INT  ';
    SET @PARAMS_PAGINATION = '@customerId INT, @statusId INT, @beginDate DATETIME, @endDate DATETIME, @search NVARCHAR(15), @noRegistersOut INT OUTPUT ';


--? ----------------- ↑↑↑ Prepare PARAMS ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare FROM ↓↓↓ -----------------------

    SET @FROM_CLAUSE='FROM Documents AS documents ';

--? ----------------- ↑↑↑ Prepare FROM ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare FILTER ↓↓↓ -----------------------
SET @FILTER_CLAUSE= + 'AND (documents.createdDate >= @beginDate AND documents.createdDate<=@endDate) ';

    IF @statusId IS NOT NULL
        BEGIN
            SET @FILTER_CLAUSE= @FILTER_CLAUSE + 'AND documents.idStatus = @statusId ';
        END
    IF(@customerId IS NOT NULL)
        BEGIN
            SET @FILTER_CLAUSE= @FILTER_CLAUSE + 'AND documents.idCustomer = @customerId ';
        END

    IF (@search IS NOT NULL OR @search != '-1')
        BEGIN
            PRINT 'Search no es nulo'
            SET @FILTER_CLAUSE=' ';
            -- SET @search= @search + '%';
            SET @FILTER_CLAUSE=' AND documents.documentNumber = @search ';

        END
    PRINT 'Search  es nulo'

--? ----------------- ↑↑↑ Prepare FILTER ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare WHERE ↓↓↓ -----------------------

    SET @WHERE_CLAUSE='WHERE documents.idTypeDocument=2 AND documents.documentNumber IS NOT NULL  ' + @FILTER_CLAUSE

--? ----------------- ↑↑↑ Prepare WHERE ↑↑↑ -----------------------

--? ----------------- ↓↓↓ Prepare Pagination ↓↓↓ -----------------------
    SET @SELECT_PAGINATION = 'SELECT @noRegistersOut = COUNT(*) ';-- SENTENCIA 'SELECT' QUE GUARDA LOS NO. DE REGISTROS
    SET @SP_CALCULATE_PAGINATION = @SELECT_PAGINATION + @FROM_CLAUSE + @WHERE_CLAUSE; -- SP DE LAS PAGINAS
    EXEC SP_EXECUTESQL @SP_CALCULATE_PAGINATION,@PARAMS_PAGINATION, @customerId, @statusId, @beginDate, @endDate, @search,  @noRegistersOut=@noRegisters OUTPUT;--RETORNO DE LOS NO. REGISTROS ENCONTRADOS


    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;

    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    SET @OFFSET = 'ORDER BY documents.documentNumber ASC OFFSET ' + CONVERT(NVARCHAR,@offsetValue) + ' ROWS FETCH NEXT ' + CONVERT(NVARCHAR,@rowsPerPage) + ' ROWS ONLY FOR JSON PATH, ROOT(''documents'');'
    

--? ----------------- ↑↑↑ Prepare Pagination ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare JOINS AND SELECT facturas emitidas ↓↓↓ -----------------------

    SET @JOIN_CLAUSE=' LEFT JOIN Currencies AS currency ON currency.currencyID= documents.idCurrency 
LEFT JOIN Users AS users ON users.userID= documents.idExecutive 
LEFT JOIN DocumentStatus AS docStatus ON docStatus.documentStatusID=documents.idStatus ';

    SET @SELECT_CLAUSE= ' SELECT 
    documents.idDocument AS [id],
    FORMAT(documents.documentNumber,''0000000'') AS [numeroDocumento],
    currency.code AS [moneda],
    documents.totalAmount AS [total.numero],
    dbo.fn_FormatCurrency(documents.totalAmount) AS [total.texto],
    dbo.FormatDate(documents.createdDate) AS [registro.formated],
    dbo.FormatDateYYYMMDD(documents.createdDate) AS [registro.yyyymmdd],
    dbo.FormatDate(documents.expirationDate) AS [facturar.formated],
    dbo.FormatDateYYYMMDD(documents.expirationDate) AS [facturar.yyyymmdd],
    users.initials AS [iniciales],
    docStatus.[description] AS [estatus],
    customers.socialReason AS razonSocial '

    SET @SP_GET_INVOICE_EMITTED= @SELECT_CLAUSE + @FROM_CLAUSE + @JOIN_CLAUSE + @WHERE_CLAUSE + @OFFSET;
--? ----------------- ↑↑↑ Prepare JOINS AND SELECT facturas emitidas ↑↑↑ -----------------------

--? ----------------- ↓↓↓ Retrive data needed ↓↓↓ -----------------------

    EXEC SP_EXECUTESQL @SP_GET_INVOICE_EMITTED,@PARAMS,@customerId, @statusId, @beginDate, @endDate, @search, @pageRequested
    SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters;
    SELECT @SP_GET_INVOICE_EMITTED
    SELECT @SP_CALCULATE_PAGINATION

--? ----------------- ↑↑↑ Retrive data needed  ↑↑↑ -----------------------

-- ! -----------------------------------------------------------------------------------

DECLARE @beginDate_Date DATE = '2022-01-01';
DECLARE @endDate_Date DATE = '2022-12-10';

DECLARE @beginDate DATETIME = @beginDate_Date;
DECLARE @endDate DATETIME = @endDate_Date;

SET LANGUAGE Spanish;
SELECT 
    documents.idDocument AS id,
    FORMAT(documents.documentNumber,'0000000') AS [numeroDocumento],
    currency.code AS moneda,
    documents.totalAmount AS [total.numero],
    dbo.fn_FormatCurrency(documents.totalAmount) AS [total.texto],
    dbo.FormatDate(documents.createdDate) AS [registro],
    dbo.FormatDate(documents.expirationDate) AS [facturar],
    users.initials AS [iniciales],
    docStatus.[description] AS [estatus],
    dbo.FormatDate(@beginDate) AS beginDate,
    dbo.FormatDate(@endDate) AS endDAte,
    
    CASE
        WHEN documents.createdDate >= @beginDate THEN 1 
        ELSE 0
    END AS mayor,
    CASE
        WHEN documents.createdDate <= @endDate THEN 1 
        ELSE 0
    END AS menor,
    customers.socialReason AS razonSocial




FROM Documents AS documents
LEFT JOIN Currencies AS currency ON currency.currencyID= documents.idCurrency
LEFT JOIN Users AS users ON users.userID= documents.idExecutive
LEFT JOIN DocumentStatus AS docStatus ON docStatus.documentStatusID=documents.idStatus
LEFT JOIN Customers AS customers ON customers.customerID= documents.idCustomer
WHERE 
    documents.idTypeDocument=2 AND 
    documents.documentNumber IS NOT NULL 
    -- (documents.createdDate >= @beginDate AND documents.createdDate<=@endDate)
     ORDER BY documents.documentNumber ASC

-- FOR JSON PATH, ROOT('documents')
-- SELECT * FROM DocumentStatus

-- 9: No Facturada
-- 10: Timbrada
-- 11: Fusionada
-- 12: Cancelada
--     DECLARE @beginDate_Date DATE = '2022-01-01';
-- DECLARE @endDate_Date DATE = '2022-12-10';
-- DECLARE @statusId INT=9;

-- DECLARE @beginDate DATETIME = @beginDate_Date;
-- DECLARE @endDate DATETIME = @endDate_Date;
--  SELECT     documents.idDocument AS id,    FORMAT(documents.documentNumber,'0000000') AS [numeroDocumento],    currency.code AS moneda,    documents.totalAmount AS [totalNumero],    dbo.fn_FormatCurrency(documents.totalAmount) AS [totalTexto],    dbo.FormatDate(documents.createdDate) AS [registro],    dbo.FormatDate(documents.expirationDate) AS [facturar],    users.initials AS [iniciales],    docStatus.[description] AS [estatus] FROM Documents AS documents  LEFT JOIN Currencies AS currency ON currency.currencyID= documents.idCurrency LEFT JOIN Users AS users ON users.userID= documents.idExecutive LEFT JOIN DocumentStatus AS docStatus ON docStatus.documentStatusID=documents.idStatus WHERE documents.idTypeDocument=2 AND documents.documentNumber IS NOT NULL  AND (documents.createdDate >= @beginDate AND documents.createdDate<=@endDate) AND documents.idStatus = @statusId ORDER BY documents.documentNumber ASC OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;