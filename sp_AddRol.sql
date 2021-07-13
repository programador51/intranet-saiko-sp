CREATE PROCEDURE sp_AddRol(

	 @description VARCHAR(50),
	 @status TINYINT,
	 @createdBy VARCHAR(30)

)

AS BEGIN

	INSERT INTO Roles 
	(
		description,status,
		createdBy,createdDate,lastUpdatedBy,
		lastUpadatedDate)
    VALUES 
	
	(
        @description, @status,
        @createdBy, GETDATE(), @createdBy,
        GETDATE()
    );
            
    SELECT SCOPE_IDENTITY()

END