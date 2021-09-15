-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Counts how many rows contain the table advertisements
-- to calculate the "number of pages" that are on advertisements according to the
-- text typed

-- STORED PROCEDURE NAME:	sp_GetPaginationAdvertisementSearch
-- STORED PROCEDURE OLD NAME: sp_PaginationAdvertisementSearch

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @textSearch: Text that the user is looking for (search input text)
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetPaginationAdvertisementSearch(

	@textSearch NVARCHAR(255)

)

AS BEGIN

	SELECT Count(*) FROM Advertisements AS a
        JOIN AdvertisementTypes on
            a.messageTypeID = AdvertisementTypes.advertisementTypeID
        WHERE (a.startDate LIKE @textSearch) OR (a.endDate LIKE @textSearch) OR
              (AdvertisementTypes.description LIKE @textSearch) OR 
              (a.createdDate LIKE @textSearch) OR
              (a.lastUpdatedBy LIKE @textSearch)OR
              (a.message LIKE @textSearch) OR
              (a.status LIKE @textSearch)

END