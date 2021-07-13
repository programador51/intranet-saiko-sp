CREATE PROCEDURE sp_UpdateTempPass(

	@temp_password NVARCHAR(300),
	@user NVARCHAR(50)

)

AS BEGIN

	UPDATE Users SET 
		temporalPassword = @temp_password 
		
	WHERE 
		userName = @user
        OR email = @user

END