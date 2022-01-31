-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-02-2021
-- Description: gets all the users on the sistem
-- STORED PROCEDURE NAME:	sp_GetInvoiceReceptionV2
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
--	2022-01-20		Adrian Alardin   			1.0.0.2			Optimizado	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/02/2021
-- Description: sp_getAllUsers permite obtener todos los usuarios del sistema
-- =============================================
CREATE PROCEDURE sp_GetInvoiceReceptionV2 (
    @page INT ,
    @querySearch NVARCHAR(30)
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    DECLARE  @WHERE_CLAUSE_PAGINATION NVARCHAR (MAX);
    DECLARE  @SELECT_CLAUSE_PAGINATION NVARCHAR (MAX);
    DECLARE  @FROM_CLAUSE NVARCHAR (MAX);
    DECLARE  @JOIN_CLAUSE NVARCHAR (MAX);
    DECLARE  @SP_STATEMENT NVARCHAR (MAX);
    DECLARE @PARAMS NVARCHAR (MAX);

    SET @SELECT_CLAUSE_PAGINATION = `SELECT @noRegisters = COUNT(*) `
    SET @search= @search +'%'
    SET @FROM_CLAUSE=`LegalDocuments `

    DECLARE @noRegisters INT;
    DECLARE @offsetValue INT;        -- Since which register start searching the information
    DECLARE @totalPages DECIMAL;        -- Total pages founded on the query
    DECLARE @rowsPerPage INT = 10;

    SET @PARAMS ='@page INT, @querySearch NVARCHAR(256), @noRegisters INT ';
    IF @querySearch IS NULL OR @querySearch= '%'
        BEGIN
            SET @WHERE_CLAUSE_PAGINATION= ` ` 
        END
    ELSE
        BEGIN
            SET @WHERE_CLAUSE_PAGINATION= `WHERE idTypeLegalDocument = 1  AND (noDocument LIKE @querySearch OR socialReason LIKE @querySearch) `
        END

    SET @SP_STATEMENT= @SELECT_CLAUSE_PAGINATION +@FROM_CLAUSE+ @WHERE_CLAUSE;
    EXEC SP_EXECUTESQL @SP_STATEMENT,@PARAMS, @page,@querySearch,@noRegisters
END
GO
-------------------------------------------------------------------------------------------------------------------------------
-- Number of registers founded
        DECLARE @noRegisters INT;
        DECLARE @offsetValue INT;        -- Since which register start searching the information
        DECLARE @totalPages DECIMAL;        -- Total pages founded on the query
        DECLARE @rowsPerPage INT = 10;        -- LIMIT of registers that can be returned per query
        SELECT @noRegisters = COUNT(*)
        FROM LegalDocuments
        WHERE
        idTypeLegalDocument = 1
        SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;
        SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);
        SELECT
            @totalPages AS pages,
            @pageRequested AS actualPage,
            @noRegisters AS noRegisters;
        SELECT * FROM LegalDocuments WHERE idTypeLegalDocument = 1 ORDER BY id DESC
        OFFSET @offsetValue ROWS
        FETCH NEXT @rowsPerPage ROWS ONLY;