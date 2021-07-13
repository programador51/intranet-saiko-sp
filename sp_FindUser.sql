CREATE PROCEDURE sp_FindUser(

	@request_user NVARCHAR(50)

)

AS BEGIN

	SELECT * FROM Users 
	
	WHERE
        userName = @request_user OR 
		email = @request_user

END