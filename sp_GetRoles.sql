-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-10-2023
-- Description: Get the roles in a paginated table form
-- STORED PROCEDURE NAME:	sp_GetRoles
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @search: The search filter
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2023-05-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
DROP PROCEDURE dbo.sp_GetRoles;  
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/10/2023
-- Description: sp_GetRoles - Get the roles in a paginated table form

CREATE PROCEDURE sp_GetRoles(
    @pageRequested INT,
    @search NVARCHAR(50)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE  @SP_CALCULATE_PAGINATION NVARCHAR (MAX);

     ------------------------------ INPUTS SP ---------------------------------
    DECLARE @PARAMS NVARCHAR (MAX);
    DECLARE @PARAMS_PAGINATION NVARCHAR (MAX);
    SET @PARAMS ='@search NVARCHAR(50) , @pageRequested INT ';
    SET @PARAMS_PAGINATION = '@search NVARCHAR(50), @noRegistersOut INT OUTPUT ';

    -- ----------------- ↓↓↓ FROM AND JOIN ↓↓↓ -----------------------
    DECLARE  @FROM_CLAUSE NVARCHAR (MAX);
    SET @FROM_CLAUSE = 'FROM Roles ';
    -- ----------------- ↑↑↑ FROM AND JOIN  ↑↑↑ -----------------------

      -- ----------------- ↓↓↓ WHERE CLAUSE ↓↓↓ -----------------------
    DECLARE  @WHERE_CLAUSE NVARCHAR (MAX);

        -- ----------------- ↓↓↓ IF STATEMENT FOR THE SEARCH ↓↓↓ -----------------------
        IF @search IS NULL
            BEGIN
                SET @WHERE_CLAUSE=' '
            END
        ELSE
            BEGIN
                SET @search=@search+'%'
                SET @WHERE_CLAUSE=' WHERE [description] LIKE @search '
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
    DECLARE @rowsPerPage INT = 20;

    DECLARE @SELECT_ROLES_QUERY NVARCHAR(MAX);
    DECLARE @FOR_JSON_PATH NVARCHAR(MAX);

    DECLARE  @SELECT_PAGINATION NVARCHAR (MAX);
    SET @SELECT_PAGINATION = 'SELECT @noRegistersOut = COUNT(*) '

    SET @SP_CALCULATE_PAGINATION = @SELECT_PAGINATION + @FROM_CLAUSE + @WHERE_CLAUSE;
    EXEC SP_EXECUTESQL @SP_CALCULATE_PAGINATION,@PARAMS_PAGINATION,@search,@noRegistersOut=@noRegisters OUTPUT;

    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;

    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters;

    ------------------------------ SELECT INVOICE RECEPTIONS ---------------------------------
    DECLARE  @SELECT_ROLES NVARCHAR (MAX);
    DECLARE @OFFSET NVARCHAR(MAX) = 'ORDER BY rolID DESC OFFSET ' + CONVERT(NVARCHAR,@offsetValue) + ' ROWS FETCH NEXT ' + CONVERT(NVARCHAR,@rowsPerPage) + ' ROWS ONLY '

    -- ISNULL(customer.commercialName,''ND'') AS comertialName,

    SET @SELECT_ROLES = 'SELECT 
    rolID AS rolID,
    [description] AS [description],
    [status] AS [status],
    createdBy AS createdBy,
    createdDate AS createdDate,
    lastUpdatedBy AS lastUpdatedBy,
    lastUpadatedDate AS lastUpadatedDate  ';

    SET @FOR_JSON_PATH=' FOR JSON PATH, ROOT(''roles''); '

    SET @SELECT_ROLES_QUERY = @SELECT_ROLES + @FROM_CLAUSE + @WHERE_CLAUSE + @OFFSET + @FOR_JSON_PATH
    PRINT  @SELECT_ROLES_QUERY;
    EXEC SP_EXECUTESQL @SELECT_ROLES_QUERY,@PARAMS,@search,@pageRequested

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------