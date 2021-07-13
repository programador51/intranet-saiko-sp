CREATE PROCEDURE sp_GetUserInfo(

	@jwtUserID INT

)

AS BEGIN

SELECT
	userID,
	userName,
	email,
	initials,
	CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
	firstName,
	middleName,
	lastName1,
	lastName2,
	birthDay,
	birthMonth,
	birthYear,
	rol,
	description

FROM Users 
    JOIN Roles on Users.rol = Roles.rolID
    WHERE 
		userID = @jwtUserID

END