CREATE PROCEDURE sp_ValidateEmailRepeated(

	@newEmail NVARCHAR(50),
	@userEditing INT

)

AS BEGIN

	SELECT email 
		FROM Users 
    
		WHERE 
			email = @newEmail
            AND userID != @userEditing

END