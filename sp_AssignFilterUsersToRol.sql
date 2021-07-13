CREATE PROCEDURE sp_AssignFilterUsersToRol(

@rolID INT,
@userID INT,
@createdBy VARCHAR(30)

)

AS BEGIN

INSERT INTO AssociatedUsers

(
    rolID,status,createdBy,
    createdDate,lastUpdatedBy,lastUpadatedDate,
    userID
)
            
VALUES

(
    @rolID,1,@createdBy,
    GETDATE(),@createdBy,GETDATE(),
    @userID
)

END