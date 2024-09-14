-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-22-2021

-- Description: Count how many rows contain the table Customers
-- to calculate the "number of pages" that are on Customers according to the
-- text typed

-- STORED PROCEDURE NAME:	sp_GetPaginationSearchCorporatives
-- STORED PROCEDURE OLD NAME: sp_PaginationSearchCorporatives

-- **************************************************************************************************************************************************
-- PARAMETERS:
-- @search: Text that the user is looking for (search input text)
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetPaginationSearchCorporatives(

	@search NVARCHAR(100)

)

AS BEGIN

SELECT Count(*) FROM Customers 
            WHERE 
                socialReason LIKE @search OR
                rfc LIKE @search OR
                commercialName LIKE @search OR
                shortName LIKE @search

END