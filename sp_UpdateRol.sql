CREATE PROCEDURE sp_UpdateRol(

	@rolId INT,
	@description NVARCHAR(50),
	@status TINYINT,
	@lastUpdatedBy NVARCHAR(30)

)

AS BEGIN

UPDATE Roles 
SET
    description = @description,
    status = @status,
    lastUpdatedBy = @lastUpdatedBy,
    lastUpadatedDate = GETDATE()
    
WHERE rolID = @rolId

END