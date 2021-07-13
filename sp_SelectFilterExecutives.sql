CREATE PROCEDURE sp_SelectFilterExecutives(

	@rolID INT

)

AS BEGIN

	SELECT

        AssociatedUsers.AssociatedID AS idRegister,
        AssociatedUsers.userID AS idUser,
        AssociatedUsers.rolID AS rolID,
        Users.userID AS ignore,
        Users.firstName,
        Users.middleName,
        Users.lastName1,
        Users.lastName2,
        CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
        CONVERT(BIT,0) AS mustErase
        
        FROM AssociatedUsers

        JOIN Users ON AssociatedUsers.userID = Users.userID

        WHERE AssociatedUsers.rolID = @rolID

        ORDER BY firstName

END