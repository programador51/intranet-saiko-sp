-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-18-2022
-- Description: Get the providers that have CXP
-- STORED PROCEDURE NAME:	sp_GetAllowedProviders
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerType: CUSTOMER TYPE ( 1:CLIENTE | 2:PROVEEDOR )
-- @documentType: DOCUMENT TYPE ( 4: CXP | 5:CXC )
-- @search: SEARCH
-- @pageRequested: CANTIDAD DE PAGINAS SOLICITADAS
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-18		Adrian Alardin   			1.0.0.0			Initial Revision		
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/18/2022
-- Description: sp_GetAllowedProviders Get the providers that have CXP
-- =============================================
CREATE PROCEDURE sp_GetAllowedProviders
    (
    @customerType INT,
    @documentType INT,
    @search NVARCHAR (256),
    @pageRequested INT
    )
AS
    BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    -- Insert statements for procedure here
    SET LANGUAGE Spanish;

    
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
    DECLARE @SP_GET_PROVIDER_ALLOWED NVARCHAR (MAX);-- VARIABLE DONDE SE GUARDA EL STOREPROCEDURE FINAL PARA OBTENER LOS PROVEEDORES

--* ----------------- ↑↑↑ DYNIMIC STOREPROCEDURES ↑↑↑ -----------------------

--* ----------------- ↓↓↓ Local varibles ↓↓↓ -----------------------
    
    DECLARE @noRegisters INT; -- Number of registers founded
    DECLARE @offsetValue INT;-- Since which register start searching the information
    DECLARE @totalPages DECIMAL;-- Total pages founded on the query
    DECLARE @rowsPerPage INT = 10;-- LIMIT of registers that can be returned per query

--* ----------------- ↑↑↑ Local varibles ↑↑↑ -----------------------

--? ----------------- ↓↓↓ Prepare PARAMS ↓↓↓ -----------------------

    SET @PARAMS ='@customerType INT, @documentType INT, @search NVARCHAR(256), @pageRequested INT ';
    SET @PARAMS_PAGINATION = '@customerType INT, @documentType INT, @search NVARCHAR(256), @noRegistersOut INT OUTPUT ';

--? ----------------- ↑↑↑ Prepare PARAMS ↑↑↑ -----------------------

--? ----------------- ↓↓↓ Prepare FROM, WHERE and FILTER ↓↓↓ -----------------------
    SET @FROM_CLAUSE='FROM Customers ';
    IF @search IS NULL 
        BEGIN
            SET @WHERE_CLAUSE='WHERE (customerType=@customerType OR customerType=5) AND (customerID IN (SELECT idCustomer FROM Documents WHERE idTypeDocument=@documentType)) AND status = 1 ';
        END
    ELSE
        BEGIN 
            SET @search= @search + '%'
            SET @WHERE_CLAUSE='WHERE (customerType=@customerType OR customerType=5) AND (customerID IN (SELECT idCustomer FROM Documents WHERE idTypeDocument=@documentType)) AND (socialReason LIKE @search OR commercialName LIKE @search OR shortName LIKE @search ) AND status = 1 ';
        END 
--? ----------------- ↑↑↑ Prepare FROM, WHERE and FILTER ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Prepare Pagination ↓↓↓ -----------------------
    SET @SELECT_PAGINATION = 'SELECT @noRegistersOut = COUNT(*) ';-- SENTENCIA 'SELECT' QUE GUARDA LOS NO. DE REGISTROS
    SET @SP_CALCULATE_PAGINATION = @SELECT_PAGINATION + @FROM_CLAUSE + @WHERE_CLAUSE; -- SP DE LAS PAGINAS
    EXEC SP_EXECUTESQL @SP_CALCULATE_PAGINATION,@PARAMS_PAGINATION,@customerType,@documentType,@search,@noRegistersOut=@noRegisters OUTPUT;--RETORNO DE LOS NO. REGISTROS ENCONTRADOS

    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;

    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    SET @OFFSET = 'ORDER BY customerID DESC OFFSET ' + CONVERT(NVARCHAR,@offsetValue) + ' ROWS FETCH NEXT ' + CONVERT(NVARCHAR,@rowsPerPage) + ' ROWS ONLY;';

--? ----------------- ↑↑↑ Prepare Pagination ↑↑↑ -----------------------

--? ----------------- ↓↓↓ Prepare SELECT facturas emitidas ↓↓↓ -----------------------.
    SET @SELECT_CLAUSE='SELECT    
    Customers.customerID AS ID,
    Customers.socialReason AS Razon_social,
    Customers.commercialName AS Nombre_comercial,
    Customers.shortName AS Nombre_corto,
    Customers.ladaPhone,
    Customers.phone,
    Customers.ladaMovil,
    Customers.movil,
    CASE 
        WHEN  phone  IS NULL THEN CONCAT(''+'',ladaPhone,phone)
        ELSE ''ND''
    END AS Telefono,
    CASE 
        WHEN  movil  IS NULL THEN CONCAT(''+'',ladaMovil,movil)
        ELSE ''ND''
    END AS Movil ';

    SET @SP_GET_PROVIDER_ALLOWED= @SELECT_CLAUSE + @FROM_CLAUSE  + @WHERE_CLAUSE + @OFFSET;

--? ----------------- ↑↑↑ Prepare SELECT facturas emitidas ↑↑↑ -----------------------


--? ----------------- ↓↓↓ Retrive data needed ↓↓↓ -----------------------

    EXEC SP_EXECUTESQL @SP_GET_PROVIDER_ALLOWED,@PARAMS,@customerType,@documentType,@search,@pageRequested
    SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters;

--? ----------------- ↑↑↑ Retrive data needed  ↑↑↑ -----------------------

    END
GO
-------------------------------------------------------------------------------------------------------------------------------
