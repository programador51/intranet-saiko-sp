CREATE PROCEDURE sp_GetAssociatedCorporative(

	@idCorporative INT

)

AS BEGIN

	SELECT 
        customerID AS corporativeId,
        shortName AS shortNameCorporative

    FROM Customers WHERE customerID = @idCorporative

END