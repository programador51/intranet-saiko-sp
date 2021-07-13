CREATE PROCEDURE sp_GetHashedPass(

	@idUser INT

)

AS BEGIN

	SELECT password FROM Users WHERE userID = @idUser

END