CREATE PROCEDURE sp_GetCorporative(

	@idCorporative INT

)

AS BEGIN

	SELECT * FROM Customers WHERE customerID = @idCorporative

END