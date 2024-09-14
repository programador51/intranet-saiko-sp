-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Get the corporatives from a "x" page requested and text
-- interested to find

-- STORED PROCEDURE NAME:	sp_GetSearchCorporative
-- STORED PROCEDURE OLD NAME: sp_SearchCorporative

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @rangeBegin: Since which row start bringing the data. For instance, since the row number 120
-- @noRegisters: How many register bring since the "rangeBegin". For instnace, bring the next 20 registers
-- @search: Text search that must be like the rows to fetch

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetSearchCorporative(

	@rangeBegin INT,
	@noRegisters INT,
	@search NVARCHAR(100)

)

AS BEGIN

SELECT 

	socialReason AS Razon_social,
	rfc AS RFC,
	commercialName AS Nombre_comercial,
	shortName AS Nombre_corto,
	customerID AS ID_cliente

	FROM Customers

	WHERE 
		socialReason LIKE @search OR
		rfc LIKE @search OR
		commercialName LIKE @search OR
		shortName LIKE @search

	ORDER BY customerID

	OFFSET @rangeBegin ROWS 
	FETCH NEXT @noRegisters ROWS ONLY 

END