-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 06-09-2021

-- Description: Insert document items. This items will be related with specific documents
-- using the id of the document

-- ===================================================================================================================================
-- PARAMETERS:
-- @description: Description that the user typed to create the item
-- @unitPrice: Unit price that the user typed to create the item
-- @unitCost: Unit cost that the user typed to create the item
-- @satCode: SAT Code
-- @satUm: SAT UM 
-- @iva: Default iva to use when a user add doc items using this service/product
-- @idUen: ID of the UEN that was used to create the item
-- @createdBy: Name of the executive who created the item
-- @code: SKU code that the user typed

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  06-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
--  15-09-2021     Jose Luis Perez             1.0.0.1         Items from the catalogue can be in a specific currency price		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddCatalogueItem(
    @description NVARCHAR(100),
    @unitPrice DECIMAL(14,4),
    @unitCost DECIMAL(14,4),
    @satCode NVARCHAR(20),
    @satUm NVARCHAR(20),
    @iva DECIMAL(4,2),
    @idUen INT,
    @createdBy NVARCHAR(30),
    @code NVARCHAR(25)
    @idCurrency INT
)

AS BEGIN

INSERT 

INTO Catalogue
    
    (

        description, unit_price, unit_cost,
        SATCODE, SATUM, iva,
        uen, status, createdBy,
        createdDate, sku , currency

    )

VALUES

    (

        @description, @unitPrice, @unitCost,
        @satCode, @satUm, @iva,
        @idUen, 1, @createdBy,
        GETDATE(), @code , @idCurrency

    )

SELECT SCOPE_IDENTITY()

END
