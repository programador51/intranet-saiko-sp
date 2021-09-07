-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 06-09-2021

-- Description: Update the information of a document item

-- ===================================================================================================================================
-- PARAMETERS:
-- @quantity: Number of items/services that the user requested on input
-- @idItem: ID of the doc item to edit
-- @price: Unit price that the user typed on input
-- @unitCost: Unit cost that the user typed on input
-- @discount: Discunt that the user typed on input
-- @modifyBy: Fullname of executive who edited
-- @totalImport: Calculated, IVA subtotal + subtotal(with discount applied) x quantity requested
-- @order: Order to display on UI when data it's fetched

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  06-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateDocumentItem(
    @quantity INT,
    @idItem INT,
    @price DECIMAL(14,4),
    @unitCost DECIMAL(14,4),
    @discount DECIMAL(14,4),
    @modifyBy NVARCHAR(30),
    @totalImport DECIMAL(14,4),
    @order INT
)

AS BEGIN

    UPDATE DocumentItems 
    
    SET
        quantity = @quantity,
        unit_price = @price,
        unit_cost = @unitCost,
        discount = @discount,
        lastUpdatedBy = @modifyBy,
        lastUpdatedDate = GETDATE(),
        totalImport = @totalImport,
        [order] = @order
    
    WHERE idItem = @idItem

END