-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 11-09-2021

-- Description: Update the unit cost of an item on the catalogue

-- ===================================================================================================================================
-- PARAMETERS:
-- @unitCost: New unit cost to use on catalogue
-- @editedBy: Fullname of the executive who edited the item on catalogue
-- @id: ID of the item on the catalogue to edit

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  11-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateCatalogueCosts(
    @id INT,
    @unitCost DECIMAL(14,4),
    @editedBy NVARCHAR(30)
)

AS BEGIN

    UPDATE Catalogue 
        SET
        unit_cost = @unitCost,
        lastUpdatedBy = @editedBy,
        lastUpdatedDate = GETDATE()

    WHERE 
        id_code = @id

END