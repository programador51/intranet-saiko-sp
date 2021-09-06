-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 06-09-2021

-- Description: Get the catalogue of the items/services that exist on the system

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  06-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

SELECT 
    Catalogue.id_code AS id,
    Catalogue.description,
    Catalogue.unit_price AS unitPrice,
    Catalogue.SATCODE AS satCode,
    Catalogue.iva,
    Catalogue.uen,
    Catalogue.unit_cost as sellPrice,
    Catalogue.SATUM as satUm,
    Catalogue.sku as code,
    UEN.UENID as idUen,
    UEN.description as uenDescription

FROM Catalogue 

JOIN UEN ON UEN.UENID = Catalogue.uen

ORDER BY description ASC