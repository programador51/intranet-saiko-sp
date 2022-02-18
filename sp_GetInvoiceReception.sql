-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-02-2021
-- Description: Gets the invoice receptions
-- STORED PROCEDURE NAME:	sp_GetInvoiceReception
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @sinceRegister 
-- @limitRegisters
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-01-19		Adrian Alardin   			1.0.0.0			Initial Revision	
--	2022-02-08		Adrian Alardin   			1.0.0.2			more filters	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/02/2021
-- Description: sp_GetInvoiceReception Gets the invoice receptions
-- =============================================
CREATE PROCEDURE sp_GetInvoiceReception (
    @page INT ,
    @querySearch NVARCHAR(30),
    @idLegalDocumentStatus INT -- Esto es nuevo
)

AS
BEGIN
    DECLARE  @SP_CALCULATE_PAGINATION NVARCHAR (MAX);

    ------------------------------ INPUTS SP ---------------------------------
    DECLARE @PARAMS NVARCHAR (MAX);
    DECLARE @PARAMS_PAGINATION NVARCHAR (MAX);
    DECLARE @JOIN_CLAUSE NVARCHAR(MAX);
    SET @PARAMS ='@querySearch NVARCHAR(256) , @pageRequested INT,@idLegalDocumentStatus INT ';
    SET @PARAMS_PAGINATION = '@querySearch NVARCHAR(256) , @noRegistersOut INT OUTPUT ';

    -- ----------------- ↓↓↓ FROM AND JOIN ↓↓↓ -----------------------
    DECLARE  @FROM_CLAUSE NVARCHAR (MAX);
    SET @FROM_CLAUSE = 'FROM LegalDocuments ';
    SET @JOIN_CLAUSE='INNER JOIN LegalDocumentStatus on LegalDocuments.idLegalDocumentStatus = LegalDocumentStatus.id ';
    -- ----------------- ↑↑↑ FROM AND JOIN  ↑↑↑ -----------------------

    -- ----------------- ↓↓↓ WHERE CLAUSE ↓↓↓ -----------------------
    DECLARE  @WHERE_CLAUSE NVARCHAR (MAX);
    DECLARE  @STATUS_CLAUSE NVARCHAR (MAX);

        -- ----------------- ↓↓↓ IF STATEMENT FOR THE DOCUMENT STATUS ↓↓↓ -----------------------
        IF (@idLegalDocumentStatus= -1)
            BEGIN
                SET @STATUS_CLAUSE=' ';
            END
        ELSE
            BEGIN
                SET @STATUS_CLAUSE='AND idLegalDocumentStatus=@idLegalDocumentStatus ';
            END
        -- ----------------- ↑↑↑ IF STATEMENT FOR THE DOCUMENT STATUS ↑↑↑ -----------------------


        -- ----------------- ↓↓↓ IF STATEMENT FOR THE SEARCH ↓↓↓ -----------------------
        IF @querySearch IS NULL OR @querySearch= '-1'
            BEGIN
            SET @WHERE_CLAUSE='WHERE idTypeLegalDocument = 1 '+@idLegalDocumentStatus
        END
        ELSE 
            BEGIN
            SET @WHERE_CLAUSE='WHERE idTypeLegalDocument = 1  AND (noDocument LIKE @querySearch OR socialReason LIKE @querySearch) '+@idLegalDocumentStatus
        END
        -- ----------------- ↑↑↑ IF STATEMENT FOR THE SEARCH ↑↑↑ -----------------------


    -- ----------------- ↑↑↑ WHERE CLAUSE ↑↑↑ -----------------------


    ------------------------------ SELECT PAGINATION ---------------------------------
    -- Number of registers founded
    DECLARE @noRegisters INT;

    -- Since which register start searching the information
    DECLARE @offsetValue INT;

    -- Total pages founded on the query
    DECLARE @totalPages DECIMAL;

    -- LIMIT of registers that can be returned per query
    DECLARE @rowsPerPage INT = 10;

    DECLARE @SELECT_INVOICE_QUERY NVARCHAR(MAX);

    DECLARE  @SELECT_PAGINATION NVARCHAR (MAX);
    SET @SELECT_PAGINATION = 'SELECT @noRegistersOut = COUNT(*) '

    SET @SP_CALCULATE_PAGINATION = @SELECT_PAGINATION + @FROM_CLAUSE + @WHERE_CLAUSE;
    EXEC SP_EXECUTESQL @SP_CALCULATE_PAGINATION,@PARAMS_PAGINATION,@querySearch,@noRegistersOut=@noRegisters OUTPUT;

    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;

    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters;

    ------------------------------ SELECT INVOICE RECEPTIONS ---------------------------------
    DECLARE  @SELECT_INVOICE_RECEPTION NVARCHAR (MAX);
    DECLARE @OFFSET NVARCHAR(MAX) = 'ORDER BY id DESC OFFSET ' + CONVERT(NVARCHAR,@offsetValue) + ' ROWS FETCH NEXT ' + CONVERT(NVARCHAR,@rowsPerPage) + ' ROWS ONLY;'


    SET @SELECT_INVOICE_RECEPTION = 'SELECT LegalDocuments.id , LegalDocuments.socialReason , LegalDocuments.noDocument ,dbo.fn_FormatCurrency(LegalDocuments.import) AS import, dbo.fn_FormatCurrency(LegalDocuments.iva) AS iva, dbo.fn_FormatCurrency(LegalDocuments.total) AS total ,LegalDocumentStatus.description,LegalDocuments.idLegalDocumentProvider AS customerId ';

    SET @SELECT_INVOICE_QUERY = @SELECT_INVOICE_RECEPTION + @FROM_CLAUSE + @JOIN_CLAUSE + @WHERE_CLAUSE + @OFFSET
    EXEC SP_EXECUTESQL @SELECT_INVOICE_QUERY,@PARAMS,@querySearch,@pageRequested,@idLegalDocumentStatus
END
GO
-------------------------------------------------------------------------------------------------------------------------------
