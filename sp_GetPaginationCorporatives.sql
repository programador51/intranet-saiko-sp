-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-22-2021

-- Description: Counts how many rows contain the table customers
-- to calculate the "number of pages" that are on customers. This it's used to associate
-- a corporative when it's creating a new customer

-- STORED PROCEDURE NAME:	sp_GetPaginationAdvertisements
-- STORED PROCEDURE OLD NAME: sp_PaginationAdvertisements

-- **************************************************************************************************************************************************

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetPaginationCorporatives

AS BEGIN

	SELECT Count(*) FROM Customers

END