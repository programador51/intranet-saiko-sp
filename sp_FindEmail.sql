CREATE PROCEDURE sp_FindEmail(

	@email NVARCHAR(50)

)

AS BEGIN

	SELECT * FROM Users WHERE email = @email

END