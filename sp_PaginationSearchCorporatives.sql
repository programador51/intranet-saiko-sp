CREATE PROCEDURE sp_PaginationSearchCorporatives(

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