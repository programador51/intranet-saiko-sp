CREATE PROCEDURE sp_UpdatePermissionsRol(

	@status TINYINT,
	@id INT

)

AS BEGIN

	UPDATE Permissions SET
		status = @status
        WHERE permissionID = @id

END