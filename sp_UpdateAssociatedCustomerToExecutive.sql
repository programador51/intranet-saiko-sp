CREATE PROCEDURE sp_UpdateAssociatedCustomerToExecutive(

	@idExecutive INT,
	@pkRow INT

)

AS BEGIN

	UPDATE Customer_Executive SET 
        executiveID = @idExecutive WHERE customerExecutiveID = @pkRow

END