-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-19-2023
-- Description: Get the  credit notes emitted.
-- STORED PROCEDURE NAME:	sp_GetNce
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
--	2023-06-19		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/19/2023
-- Description: sp_GetNce - Get the  credit notes emitted.
CREATE PROCEDURE sp_GetNce(
    @customerId INT,
    @statusId INT,
    @beginDate DATETIME,
    @endDate DATETIME,
    @search NVARCHAR(15),
    @pageRequested INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
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
    DECLARE @SP_GET_NC_EMITTED NVARCHAR (MAX);-- VARIABLE DONDE SE GUARDA EL STOREPROCEDURE FINAL PARA OBTENER LAS FACTURAS

--* ----------------- ↑↑↑ DYNIMIC STOREPROCEDURES ↑↑↑ -----------------------


--* ----------------- ↓↓↓ Local varibles ↓↓↓ -----------------------
    
    DECLARE @noRegisters INT; -- Number of registers founded
    DECLARE @offsetValue INT;-- Since which register start searching the information
    DECLARE @totalPages DECIMAL;-- Total pages founded on the query
    DECLARE @rowsPerPage INT = 10;-- LIMIT of registers that can be returned per query

--* ----------------- ↑↑↑ Local varibles ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare PARAMS ↓↓↓ -----------------------

    SET @PARAMS ='@customerId INT, @statusId INT, @beginDate DATETIME, @endDate DATETIME, @search NVARCHAR, @pageRequested INT  ';
    SET @PARAMS_PAGINATION = '@customerId INT, @statusId INT, @beginDate DATETIME, @endDate DATETIME, @search NVARCHAR, @pageRequested INT, @noRegistersOut INT OUTPUT ';


--? ----------------- ↑↑↑ Prepare PARAMS ↑↑↑ -----------------------

--? ----------------- ↓↓↓ Prepare FROM ↓↓↓ -----------------------

    SET @FROM_CLAUSE='FROM LegalDocuments AS nce ';

--? ----------------- ↑↑↑ Prepare FROM ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare FILTER ↓↓↓ -----------------------
SET @FILTER_CLAUSE= + 'AND (nce.createdDate >= @beginDate AND nce.createdDate <=@endDate) ';

    IF @statusId IS NOT NULL
        BEGIN
            SET @FILTER_CLAUSE= @FILTER_CLAUSE + 'AND nce.idLegalDocumentStatus = @statusId ';
        END
    IF(@customerId IS NOT NULL)
        BEGIN
            SET @FILTER_CLAUSE= @FILTER_CLAUSE + 'AND nce.idCustomer = @customerId ';
        END

    IF (@search IS NOT NULL OR @search != '-1')
        BEGIN
            PRINT 'Search no es nulo'
            SET @FILTER_CLAUSE=' ';
            -- SET @search= @search + '%';
            SET @FILTER_CLAUSE=' AND (nce.noDocument LIKE @search OR customer.socialReason LIKE @search OR invoice.noDocument LIKE @search) ';

        END
    PRINT 'Search  es nulo'

--? ----------------- ↑↑↑ Prepare FILTER ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare WHERE ↓↓↓ -----------------------

    SET @WHERE_CLAUSE='WHERE idTypeLegalDocumentType=4  ' + @FILTER_CLAUSE

--? ----------------- ↑↑↑ Prepare WHERE ↑↑↑ -----------------------

--? ----------------- ↓↓↓ Prepare Pagination ↓↓↓ -----------------------
    SET @SELECT_PAGINATION = 'SELECT @noRegistersOut = COUNT(*) ';-- SENTENCIA 'SELECT' QUE GUARDA LOS NO. DE REGISTROS
    SET @SP_CALCULATE_PAGINATION = @SELECT_PAGINATION + @FROM_CLAUSE + @WHERE_CLAUSE; -- SP DE LAS PAGINAS
    EXEC SP_EXECUTESQL @SP_CALCULATE_PAGINATION,@PARAMS_PAGINATION, @customerId, @statusId, @beginDate, @endDate, @search,  @noRegistersOut=@noRegisters OUTPUT;--RETORNO DE LOS NO. REGISTROS ENCONTRADOS


    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;

    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    SET @OFFSET = 'ORDER BY nce.noDocument ASC OFFSET ' + CONVERT(NVARCHAR,@offsetValue) + ' ROWS FETCH NEXT ' + CONVERT(NVARCHAR,@rowsPerPage) + ' ROWS ONLY FOR JSON PATH, ROOT(''documents'');'
    

--? ----------------- ↑↑↑ Prepare Pagination ↑↑↑ -----------------------

--? ----------------- ↓↓↓ Prepare JOINS AND SELECT facturas emitidas ↓↓↓ -----------------------

    SET @JOIN_CLAUSE=' LEFT JOIN LegalDocumentStatus AS invoiceStatus ON invoiceStatus.id=nce.idLegalDocumentStatus
    LEFT JOIN LegalDocuments AS invoice ON invoice.uuid= nce.uuidReference
    LEFT JOIN Customers AS customer ON customer.customerID= nce.idCustomer ';

    SET @SELECT_CLAUSE= ' SELECT  
    nce.createdDate AS emited,
    nce.[xml] AS [xml],
    nce.pdf AS [pdf],
    nce.id AS id,
    nce.uuid AS uuid,
    nce.noDocument AS [documentNumber],
    nce.currencyCode AS [currency],
    invoiceStatus.[description] AS [status.description],
    invoiceStatus.id AS [status.id],
    nce.total AS [total.number],
    dbo.fn_FormatCurrency(nce.total ) AS [total.text],
    dbo.FormatDate(nce.createdDate) AS [registro.formated],
    dbo.FormatDateYYYMMDD(nce.createdDate) AS [registro.yyyymmdd],

    
    customer.socialReason AS [customer.socialReason],
    customer.customerID AS [customer.id],
    invoice.noDocument AS [invoice.noDocument],
    invoice.id AS [invoice.id] '

    SET @SP_GET_NC_EMITTED= @SELECT_CLAUSE + @FROM_CLAUSE + @JOIN_CLAUSE + @WHERE_CLAUSE + @OFFSET;
--? ----------------- ↑↑↑ Prepare JOINS AND SELECT facturas emitidas ↑↑↑ -----------------------



--? ----------------- ↓↓↓ Retrive data needed ↓↓↓ -----------------------

    EXEC SP_EXECUTESQL @SP_GET_NC_EMITTED,@PARAMS,@customerId, @statusId, @beginDate, @endDate, @search, @pageRequested
    SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters

--? ----------------- ↑↑↑ Retrive data needed  ↑↑↑ -----------------------












--     DECLARE @rowsPerPage INT = 20;
--     DECLARE @offset INT;
--     DECLARE @pages INT;


    

--     ------------------------------------------------------------------------------------------------------------------------------------------------------------

--     DECLARE @FILTER_DATE NVARCHAR(MAX)
--         = ' WHERE nce.createdDate >= ''' + CONVERT(NVARCHAR(256), @beginDate) + ''' AND 
--     nce.createdDate <= '''           + CONVERT(NVARCHAR(256), @endDate) + '''';

--     ------------------------------------------------------------------------------------------------------------------------------------------------------------

--     DECLARE @FILTER_USER NVARCHAR(MAX) = ''
--     IF (@customerId IS NOT NULL)
--         SET @FILTER_USER = ' AND nce.idCustomer= ' + CONVERT(NVARCHAR, @customerId);

--     ------------------------------------------------------------------------------------------------------------------------------------------------------------

--     DECLARE @FILTER_STATUS NVARCHAR(MAX) = ' AND nce.idLegalDocumentStatus IN (SELECT 
--                                                                 CASE 
--                                                                     WHEN ' + ISNULL(CONVERT(nvarchar,@statusId),' NULL ') + ' IS NULL THEN id
--                                                                     ELSE '+ ISNULL(CONVERT(nvarchar,@statusId),' NULL ') +'
--                                                                  END
--                                                             FROM LegalDocumentStatus WHERE [status]=1 AND idTypeLegalDocumentType=4) ';
--     IF(@statusId IS NOT NULL) SET @FILTER_STATUS = ' AND nce.idLegalDocumentStatus =  '+CONVERT(nvarchar,@statusId);



--     ------------------------------------------------------------------------------------------------------------------------------------------------------------

--     DECLARE @FILTER_SEARCH NVARCHAR(MAX) = '';
--     IF (@search IS NOT NULL)
--         SET @FILTER_SEARCH = ' AND nce.noDocument=' + CONVERT(NVARCHAR, @search);

--     ------------------------------------------------------------------------------------------------------------------------------------------------------------

--     DECLARE @FILTER NVARCHAR(MAX) = @FILTER_DATE + @FILTER_USER + @FILTER_STATUS + @FILTER_SEARCH;

--     DECLARE @QUERY_PAGINATION NVARCHAR(MAX) = 'SELECT @count = COUNT(*) FROM LegalDocuments AS nce ' + @FILTER;

--     EXEC sp_GetPagination @pageRequested,
--                           @QUERY_PAGINATION,
--                           @rowsPerPage,
--                           @spOffset = @offset OUTPUT,
--                           @spTotalPages = @pages OUTPUT;

--     ------------------------------------------------------------------------------------------------------------------------------------------------------------

    
--     DECLARE @JSON_FORMAT NVARCHAR(MAX) = 'OFFSET '+ CONVERT(nvarchar,@offset) +' ROWS FETCH NEXT ' + CONVERT(nvarchar,@rowsPerPage) + ' ROWS ONLY FOR JSON PATH, INCLUDE_NULL_VALUES ,ROOT(''nce'');'
    

--     ------------------------------------------------------------------------------------------------------------------------------------------------------------

--     DECLARE @DYNAMIC_QUERY NVARCHAR(MAX)
--         = '
    
--     SELECT  
--     nce.createdDate AS emited,
--     nce.[xml] AS [xml],
--     nce.pdf AS [pdf],
--     nce.id AS id,
--     nce.uuid AS uuid,
--     nce.noDocument AS [documentNumber],
--     nce.currencyCode AS [currency],
--     invoiceStatus.[description] AS [status.description],
--     invoiceStatus.id AS [status.id],
--     nce.total AS [total.number],
--     dbo.fn_FormatCurrency(nce.total ) AS [total.text],
--     dbo.FormatDate(nce.createdDate) AS [registro.formated],
--     dbo.FormatDateYYYMMDD(nce.createdDate) AS [registro.yyyymmdd],

    
--     customer.socialReason AS [customer.socialReason],
--     customer.customerID AS [customer.id]




--     FROM LegalDocuments AS nce
--     LEFT JOIN LegalDocumentStatus AS invoiceStatus ON invoiceStatus.id=nce.idLegalDocumentStatus
--     LEFT JOIN LegalDocuments AS invoice ON invoice.uuid= nce.uuidReference
--     LEFT JOIN Customers AS customer ON customer.customerID= nce.idCustomer
    
--     ' + @FILTER + ' ORDER BY nce.noDocument ASC ' + @JSON_FORMAT;

--     PRINT (@DYNAMIC_QUERY);

--     EXECUTE sp_executesql @DYNAMIC_QUERY;

--     SELECT @pages AS pages,
--            @pageRequested AS actualPage,
--            1 AS noRegisters


-- END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------