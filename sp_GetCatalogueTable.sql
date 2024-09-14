-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-04-2023
-- Description: Get the products from the catalogue as a table
-- STORED PROCEDURE NAME:	sp_GetCatalogueTable
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
--	2023-08-04		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/04/2023
-- Description: sp_GetCatalogueTable - Get the products from the catalogue as a table
CREATE PROCEDURE sp_GetCatalogueTable(
    @description NVARCHAR(1000),
    @sku NVARCHAR(256),
    @uen INT,
    @currency INT,
    @pageRequested  INT

) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @noRegisters INT;

    DECLARE @offsetValue INT;

    DECLARE @totalPages DECIMAL;

    DECLARE @rowsPerPage INT = 10;

    SELECT @noRegisters = COUNT(*)
    FROM Catalogue
    WHERE
            [description] LIKE ISNULL(@description,'') + '%' AND
            sku LIKE ISNULL(@sku,'') + '%' AND
            uen IN (
                SELECT 
                    CASE 
                        WHEN @uen IS NULL THEN UENID
                        ELSE @uen
                    END
                FROM UEN
            )  AND
            currency IN (
                SELECT 
                    CASE 
                        WHEN @currency IS NULL THEN currencyID
                        ELSE @currency
                    END
                FROM Currencies
            )
    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;
    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    SELECT 
        product.id_code AS id,
        product.[description],
        product.unit_price AS unitPrice,
        product.unit_cost AS unitCost,
        uen.[description] AS uenDescription,
        currency.code AS currency,
        product.sku AS sku,
        product.SATCODE AS satCode,
        product.SATUM AS satUm,
        product.satCodeDescription AS satCodeDescription,
        product.satUmDescription AS satUmDescription

    FROM Catalogue AS product
    LEFT JOIN UEN AS uen ON uen.UENID= product.uen
    LEFT JOIN Currencies AS currency ON currency.currencyID=product.currency
    WHERE
        product.[description] LIKE ISNULL(@description,'') + '%' AND
        product.sku LIKE ISNULL(@sku,'') + '%' AND
        product.uen IN (
            SELECT 
                CASE 
                    WHEN @uen IS NULL THEN UENID
                    ELSE @uen
                END
            FROM UEN
        ) AND
        product.currency IN (
            SELECT 
                CASE 
                    WHEN @currency IS NULL THEN currencyID
                    ELSE @currency
                END
            FROM Currencies
        )
    ORDER BY product.id_code ASC
    OFFSET @offsetValue ROWS
    FETCH NEXT @rowsPerPage ROWS ONLY
    FOR JSON PATH,ROOT('products'), INCLUDE_NULL_VALUES

     SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------