CREATE PROCEDURE sp_FindUserName(

	@userName NVARCHAR(50)

)

AS BEGIN

	SELECT * FROM Users WHERE username = @userName

END