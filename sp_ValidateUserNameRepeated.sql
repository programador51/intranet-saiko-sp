CREATE PROCEDURE sp_ValidateUserNameRepeated(

	@newUsername NVARCHAR(50),
	@userEditing INT

)

AS BEGIN

SELECT userName 
	FROM Users 
    WHERE 
		userName = @newUsername
        AND userID != @userEditing

END