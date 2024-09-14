-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-10-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_AddItemsToDocuments
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
--	2022-02-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/10/2022
-- Description: sp_AddItemsToDocuments - Some Notes
-- CREATE TYPE
CREATE PROCEDURE sp_AddItemsToDocuments(
    @documentId INT,
    @createdBy NVARCHAR (30),
    @existNewItems BIT,
    @itemsTableType ItemsToDocuments READONLY
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @itemsToDocuments TABLE (
    id INT PRIMARY KEY NOT NULL IDENTITY (1,1),
    [CAT_description] NVARCHAR (100) NOT NULL, --[CATALOGO]
    CAT_unite_price DECIMAL(14,2) NOT NULL,-- [CATALOGO]
    CAT_unit_cost DECIMAL (14,2) NOT NULL, -- [CATALOGO]
    CAT_SATCODE NVARCHAR(20) NOT NULL,-- [CATALOGO]
    CAT_SATUM NVARCHAR(20) NOT NULL,-- [CATALOGO]
    CAT_iva DECIMAL(4,2) NOT NULL,-- [CATALOGO]
    CAT_uen INT NOT NULL,-- [CATALOGO]
    CAT_sku NVARCHAR(25) NULL,-- [CATALOGO]
    CAT_currency INT NOT NULL,-- [CATALOGO]
    DOC_documentId INT, -- [DCUMENT ITEMS]
    DOC_unit_price DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_unit_cost DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_itemId INT, -- idCatalogue si es nuevo va a ser NULL [DCUMENT ITEMS]
    DOC_quantity INT NOT NULL, -- [DCUMENT ITEMS]
    DOC_discount DECIMAL(14,4) NOT NULL, -- [DCUMENT ITEMS]
    DOC_totalImport DECIMAL(14,4) NOT NULL, -- [DCUMENT ITEMS]
    DOC_order INT NOT NULL, -- [DCUMENT ITEMS]
    DOC_ivaPercentage DECIMAL(5,2) NOT NULL, -- [DCUMENT ITEMS]
    DOC_iva DECIMAL(14,2) NOT NULL, -- [DCUMENT ITEMS]
    DOC_subTotal DECIMAL(14,4) NOT NULL, -- [DCUMENT ITEMS]
    DOC_unitSellingPrice DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_unitPriceBeforeExchange DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_unitCostBeforeExchange DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_ivaBeforeExchange DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_subTotalBeforeExchange DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_unitSellingPriceBeforeExchange DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationCostDiscount DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationCostImport DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationCostIva DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationCostSell DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationCostSubtotal DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationCostUnitary DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationPriceDiscount DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationPriceImport DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationPriceIva DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationPriceSell DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationPriceSubtotal DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_calculationPriceUnitary DECIMAL(14,4), -- [DCUMENT ITEMS]
    DOC_discountPercentage DECIMAL(14,4) NOT NULL, -- [DCUMENT ITEMS]
    DOC_utility DECIMAL(14,4) NOT NULL, -- [DCUMENT ITEMS]
    [status] TINYINT NOT NULL, -- [APLICA PARA TODO],
    createdBy NVARCHAR(30) NOT NULL, -- [APLICA PARA TODO],
    lastUpdateBy NVARCHAR(30), -- [APLICA PARA TODO]
    createdDate DATETIME DEFAULT  dbo.fn_MexicoLocalTime(GETDATE()) , -- [APLICA PARA TODO]
    lastUpdateDate DATETIME DEFAULT dbo.fn_MexicoLocalTime(GETDATE()), -- [APLICA PARA TODO]
    isNew BIT NOT NULL -- [EXTRA]

)
    INSERT INTO @itemsToDocuments (
        CAT_description,
        CAT_unite_price,
        CAT_unit_cost,
        CAT_SATCODE,
        CAT_SATUM,
        CAT_iva,
        CAT_uen,
        CAT_sku,
        CAT_currency,
        DOC_documentId,
        DOC_unit_price,
        DOC_unit_cost,
        DOC_itemId,
        DOC_quantity,
        DOC_discount,
        DOC_totalImport,
        DOC_order,
        DOC_ivaPercentage,
        DOC_iva,
        DOC_subTotal,
        DOC_unitSellingPrice,
        DOC_unitPriceBeforeExchange,
        DOC_unitCostBeforeExchange,
        DOC_ivaBeforeExchange,
        DOC_subTotalBeforeExchange,
        DOC_unitSellingPriceBeforeExchange,
        DOC_calculationCostDiscount,
        DOC_calculationCostImport,
        DOC_calculationCostIva,
        DOC_calculationCostSell,
        DOC_calculationCostSubtotal,
        DOC_calculationCostUnitary,
        DOC_calculationPriceDiscount,
        DOC_calculationPriceImport,
        DOC_calculationPriceIva,
        DOC_calculationPriceSell,
        DOC_calculationPriceSubtotal,
        DOC_calculationPriceUnitary,
        DOC_discountPercentage,
        DOC_utility,
        [status],
        createdBy,
        lastUpdateBy,
        createdDate,
        lastUpdateDate,
        isNew
    )
    SELECT 
        CAT_description,
        CAT_unite_price,
        CAT_unit_cost,
        CAT_SATCODE,
        CAT_SATUM,
        CAT_iva,
        CAT_uen,
        CAT_sku,
        CAT_currency,
        DOC_documentId,
        DOC_unit_price,
        DOC_unit_cost,
        DOC_itemId,
        DOC_quantity,
        DOC_discount,
        DOC_totalImport,
        DOC_order,
        DOC_ivaPercentage,
        DOC_iva,
        DOC_subTotal,
        DOC_unitSellingPrice,
        DOC_unitPriceBeforeExchange,
        DOC_unitCostBeforeExchange,
        DOC_ivaBeforeExchange,
        DOC_subTotalBeforeExchange,
        DOC_unitSellingPriceBeforeExchange,
        DOC_calculationCostDiscount,
        DOC_calculationCostImport,
        DOC_calculationCostIva,
        DOC_calculationCostSell,
        DOC_calculationCostSubtotal,
        DOC_calculationCostUnitary,
        DOC_calculationPriceDiscount,
        DOC_calculationPriceImport,
        DOC_calculationPriceIva,
        DOC_calculationPriceSell,
        DOC_calculationPriceSubtotal,
        DOC_calculationPriceUnitary,
        DOC_discountPercentage,
        DOC_utility,
        [status],
        createdBy,
        lastUpdateBy,
        createdDate,
        lastUpdateDate,
        isNew
     FROM @itemsTableType


    DECLARE @itemsInsertedCatalgue TABLE (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        itemId INT NOT NULL -- ID insertado en el catalogo
    )

    -- Tabla que almacena los productos que se van a agregar al catalogo
    DECLARE @referenceTableToCatalogue TABLE (
        id INT PRIMARY KEY NOT NULL IDENTITY (1,1),
        itemsToDocumentsId INT NOT NULL, -- id de referencia a la tabla @itemsToDocuments,
        itemId INT, -- Id del catalogo.
        [CAT_description] NVARCHAR (100) NOT NULL, --[CATALOGO]
        CAT_unite_price DECIMAL(14,2) NOT NULL,-- [CATALOGO]
        CAT_unit_cost DECIMAL (14,2) NOT NULL, -- [CATALOGO]
        CAT_SATCODE NVARCHAR(20) NOT NULL,-- [CATALOGO]
        CAT_SATUM NVARCHAR(20) NOT NULL,-- [CATALOGO]
        CAT_iva DECIMAL(4,2) NOT NULL,-- [CATALOGO]
        CAT_uen INT NOT NULL,-- [CATALOGO]
        CAT_sku NVARCHAR(25) NULL,-- [CATALOGO]
        CAT_currency INT NOT NULL-- [CATALOGO]
    )

    -- Accion que guarda los itmes que necesitan ser craedos en el catalogo
    INSERT INTO @referenceTableToCatalogue (
        itemsToDocumentsId, -- id de referencia a la tabla @itemsToDocuments
        [CAT_description], --[CATALOGO]
        CAT_unite_price ,-- [CATALOGO]
        CAT_unit_cost , -- [CATALOGO]
        CAT_SATCODE ,-- [CATALOGO]
        CAT_SATUM ,-- [CATALOGO]
        CAT_iva ,-- [CATALOGO]
        CAT_uen, -- [CATALOGO]
        CAT_sku,-- [CATALOGO]
        CAT_currency -- [CATALOGO]
    )
    SELECT 
        id ,
        [CAT_description], --[CATALOGO]
        CAT_unite_price ,-- [CATALOGO]
        CAT_unit_cost , -- [CATALOGO]
        CAT_SATCODE ,-- [CATALOGO]
        CAT_SATUM ,-- [CATALOGO]
        CAT_iva ,-- [CATALOGO]
        CAT_uen, -- [CATALOGO] 
        CAT_sku,
        CAT_currency
        FROM @itemsToDocuments WHERE isNew = 1

    -- Accion que guarda los id de los items insertados en el catalogo
    INSERT INTO Catalogue (
        [description],
        unit_price,
        unit_cost,
        SATCODE,
        SATUM,
        iva,
        uen,
        [status],
        createdBy,
        createdDate,
        lastUpdatedDate,
        lastUpdatedBy,
        sku,
        currency
    )
    OUTPUT inserted.id_code INTO @itemsInsertedCatalgue(itemId)

    SELECT 
        [CAT_description], --[CATALOGO]
        CAT_unite_price ,-- [CATALOGO]
        CAT_unit_cost , -- [CATALOGO]
        CAT_SATCODE ,-- [CATALOGO]
        CAT_SATUM ,-- [CATALOGO]
        CAT_iva ,-- [CATALOGO]
        CAT_uen,-- [CATALOGO]
        1,
        @createdBy,
        dbo.fn_MexicoLocalTime(GETDATE()),
        dbo.fn_MexicoLocalTime(GETDATE()),
        @createdBy,
        CAT_sku,
        CAT_currency
    FROM @referenceTableToCatalogue


    UPDATE referensTable SET
        referensTable.itemId = insertedItems.itemId
        FROM @referenceTableToCatalogue AS referensTable
        INNER JOIN @itemsInsertedCatalgue AS insertedItems
        ON referensTable.id= insertedItems.id

    UPDATE itemsToDocuments SET
        itemsToDocuments.DOC_itemId = referensTable.itemId
        FROM @itemsToDocuments AS itemsToDocuments
        INNER JOIN @referenceTableToCatalogue AS referensTable
        ON itemsToDocuments.id= referensTable.itemsToDocumentsId

END