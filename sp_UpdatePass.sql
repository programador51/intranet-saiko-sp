CREATE PROCEDURE sp_UpdatePass(

	@password NVARCHAR(300),
	@userID INT

)

AS BEGIN

UPDATE Users 
	SET
        password = @password 
	WHERE userID = @userID

END