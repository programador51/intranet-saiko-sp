-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 06-09-2021

-- Description: Get the catalogue of the items/services that exist on the system

-- =================================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================================================================
--  06-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query	
--  14-09-2021     Jose Luis Perez             1.0.0.1         Joins
--  06-10-2021	   Iván Díaz		       1.0.0.2	       Left Joins
-- **************************************************************************************************************************************************

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
    Catalogue.currency,
    UEN.UENID as idUen,
    UEN.description as uenDescription,
    Currencies.currencyID,
	Currencies.code AS currencyCode,
	Currencies.symbol,
	Currencies.description AS currencyDescription

FROM Catalogue 

LEFT JOIN UEN ON UEN.UENID = Catalogue.uen					--1.0.0.2	
LEFT JOIN Currencies ON Catalogue.currency = Currencies.currencyID		--1.0.0.2	

ORDER BY Catalogue.description ASC
