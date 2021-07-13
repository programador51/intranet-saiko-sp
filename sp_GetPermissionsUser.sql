CREATE PROCEDURE sp_GetPermissionsUser(

	@rolUser INT

)

AS BEGIN

	SELECT * FROM Permissions WHERE rolID = @rolUser

END