CREATE PROCEDURE sp_AddPermission(

	@rolID INT,
	@sectionID INT,
	@description NVARCHAR(50),
	@status TINYINT,
	@lastUpdatedBy NVARCHAR(50)

)

AS BEGIN

	INSERT INTO Permissions (
            rolID,sectionID,description,
            status,createdBy,createdDate,
            lastUpdatedBy,lastUpadatedDate)
        
        VALUES
    
        (
            @rolID,@sectionID,@description,
            @status,@lastUpdatedBy,GETDATE(),
            @lastUpdatedBy,GETDATE()
        )

END