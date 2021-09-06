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
-- @idDocument: ID of the document that the document item will belong
-- @unitCost: Unit cost that the user typed on the input
-- @unitPrice: Unit price that the user typed on the input
-- @idCatalogue: ID from where it was picked the document item
-- @quantity: Number of items/services that the user requested on the input
-- @discount: Percentage of discount that the executive typed on input
-- @totalImport: Calculated, IVA subtotal + subtotal(with discount applied) x quantity requested
-- @createdBy: Executive name who created the item
-- @order: Order must have the items when they get requested 
-- @iva: Iva percentage that was applied on item

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  06-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************


CREATE PROCEDURE sp_AddDocumentItems(
    @idDocument INT,
    @unitPrice DECIMAL(14,4),
    @unitCost DECIMAL(14,4),
    @idCatalogue INT,
    @quantity INT,
    @discount DECIMAL(5,2),
    @totalImport DECIMAL(14,4),
    @createdBy NVARCHAR(30),
    @order INT,
    @iva DECIMAL(5,2)
)

AS BEGIN

    INSERT 
    
    INTO DocumentItems

        (

            document, unit_price,unit_cost,
            idCatalogue, quantity, discount,
            totalImport, "order", createdBy,
            createdDate,ivaPercentage,status

        )

    VALUES

        (

            @idDocument, @unitPrice, @unitCost,
            @idCatalogue, @quantity, @discount,
            @totalImport, @order, @createdBy,
            GETDATE(), @iva, 1

        )

END