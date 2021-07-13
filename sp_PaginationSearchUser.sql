CREATE PROCEDURE sp_PaginationSearchUser(

	@textSearch NVARCHAR(300)

)

AS BEGIN

SELECT Count(*) 
	FROM Users
    WHERE userName LIKE @textSearch

END