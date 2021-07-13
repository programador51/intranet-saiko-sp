CREATE PROCEDURE sp_PaginationSearchRol(

	@textSearch NVARCHAR(50)

)

AS BEGIN

	SELECT Count(*) FROM Roles
    WHERE description LIKE @textSearch

END