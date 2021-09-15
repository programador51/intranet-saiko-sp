-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-22-2021

-- Description: Count how many rows contain the table Customers
-- to calculate the "number of pages" that are on Customers according to the
-- text typed

-- STORED PROCEDURE NAME:	sp_GetPaginationSearchUser
-- STORED PROCEDURE OLD NAME: sp_PaginationSearchUser

-- **************************************************************************************************************************************************
-- PARAMETERS:
-- @textSearch: Text that the user is looking for (search input text)
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetPaginationSearchUser(

	@textSearch NVARCHAR(300)

)

AS BEGIN

SELECT Count(*) 
	FROM Users
    WHERE userName LIKE @textSearch

END