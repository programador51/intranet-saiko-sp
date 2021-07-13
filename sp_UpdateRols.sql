CREATE PROCEDURE sp_UpdateRols(

	@description NVARCHAR(50),
	@rolEditing INT

)

AS BEGIN

SELECT 
	description from Roles 
    
	WHERE description = @description and rolID != @rolEditing

END