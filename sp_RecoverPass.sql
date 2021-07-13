CREATE PROCEDURE sp_RecoverPass(

	@password_front NVARCHAR(300),
	@userName NVARCHAR(50)

)

AS BEGIN

UPDATE Users 
	SET 
		password = @password_front, 
		temporalPassword = NULL 
	
	WHERE 
		userName = @userName OR 
		email = @userName

END