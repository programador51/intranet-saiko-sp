CREATE PROCEDURE sp_CreatePermissionsRol(

	@sectionID INT,
	@rolID INT,
	@createdBy VARCHAR(50)

)

AS BEGIN

INSERT INTO Permissions 
(
    sectionID,rolID,
    status,createdBy,
    createdDate,lastUpadatedDate,lastUpdatedBy
) 
            
VALUES

(
    @sectionID,@rolID,
    0,@createdBy,
    GETDATE(),GETDATE(),@createdBy
)

END