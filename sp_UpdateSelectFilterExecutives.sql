CREATE PROCEDURE sp_UpdateSelectFilterExecutives(

	@id INT

)

AS BEGIN

	DELETE FROM AssociatedUsers WHERE AssociatedID = @id

END