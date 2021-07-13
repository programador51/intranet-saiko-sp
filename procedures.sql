/* Queries about "Users" */
/* 
    Find Email 

    Arguments
    input('email', sql.VarChar, request.params.email)
*/

SELECT * FROM Users WHERE email = @email

////////////////////////////////////////////////////////////////////////

/* 

    Find User

    Arguments
    input('userName', sql.VarChar, request.params.userName)
*/
SELECT * FROM Users WHERE username = @userName


////////////////////////////////////////////////////////////////////////


/* 

    Validate email not repeated on DB at update
    
    Arguments
    input('newEmail', sql.VarChar, request.params.email)
    input('userEditing', sql.Int, request.params.userId)
*/
SELECT email FROM Users 
WHERE email = @newEmail
AND userID != @userEditing


////////////////////////////////////////////////////////////////////////


/* 

    Validate user name not repeated on DB at update

    Arguments
    input('newUsername', sql.VarChar, request.params.userName)
    input('userEditing', sql.Int, request.params.userId)

*/
SELECT userName from Users 
WHERE userName = @newUsername
and userID != @userEditing

////////////////////////////////////////////////////////////////////////


/* 

    Update user information

    Arguments
    .input('userId', sql.Int, request.params.userId)
    .input('userName', sql.VarChar, request.params.userName)
    .input('email', sql.VarChar, request.params.email)
    .input('initials', sql.VarChar, request.params.initials)
    .input('firstName', sql.VarChar, request.params.firstName)
    .input('middleName', sql.VarChar, request.params.middleName)
    .input('lastName1', sql.VarChar, request.params.lastName1)
    .input('lastName2', sql.VarChar, request.params.lastName2)
    .input('birthDay', sql.Int, request.params.day)
    .input('birthMonth', sql.Int, request.params.month)
    .input('userModified', sql.Int, request.params.userModified)
    .input('rol', sql.Int, request.params.rol)
    .input('today', sql.DateTime, today)
    .input('null', sql.Int, null)

*/

UPDATE Users SET
    userName = @userName,
    email = @email,
    rol = @rol,
    initials = @initials,
    firstName = @firstName,
    middleName = @middleName,
    lastName1 = @lastName1,
    lastName2 = @lastName2,
    birthDay = @birthDay,
    birthMonth = @birthMonth,
    lastUpdatedBy = @userModified,
    lastUpdatedDate = @today            
WHERE userID = @userId

////////////////////////////////////////////////////////////////////////


/* Queries about "Roles" */

/* 

    Update permissions of rol

    Arguments
    .input('status', sql.TinyInt, permition.status)
    .input('id',sql.Int,permition.permission)

*/
UPDATE Permissions SET
status = @status
WHERE permissionID = @id

////////////////////////////////////////////////////////////////////////


/* 

    Validate rol name it's not repated at the moment of update

    Arguments
    .input('description', sql.VarChar, request.params.description)
    .input('rolEditing', sql.Int, request.params.rolId)

*/
SELECT description from Roles 
WHERE description = @description
and rolID != @rolEditing

////////////////////////////////////////////////////////////////////////


/* 

    Update rol information

    Arguments
    .input('rolId', sql.Int, request.params.rolId)
    .input('description', sql.VarChar, request.params.description)
    .input('status', sql.TinyInt, request.params.status)
    .input('lastUpdatedBy', sql.Int, request.params.userModified)
    .input('today', sql.DateTime, request.params.today)

*/
UPDATE Roles SET
    description = @description,
    status = @status,
    lastUpdatedBy = @lastUpdatedBy,
    lastUpadatedDate = @today
WHERE rolID = @rolId

////////////////////////////////////////////////////////////////////////


/* 

    Add new rol, at the moment of insertion, get the id of the inserted row

    Arguments
    .input("description", sql.VarChar, request.params.description)
    .input("status", sql.TinyInt, request.params.status)
    .input("createdBy", sql.Int, request.params.createdBy)
    .input("today", sql.DateTime, request.params.today)
    .input('nameUserCreated',sql.VarChar,request.params.userName)   
*/

INSERT INTO Roles (
description,status,
createdBy,createdDate,lastUpdatedBy,
lastUpadatedDate)
values (
    @description, @status,
    @nameUserCreated, @today, @nameUserCreated,
    @today
);
            
SELECT SCOPE_IDENTITY()

////////////////////////////////////////////////////////////////////////

/* 

    Get the skeleton of the permissions to create a three structure for the front-end

    Arguments
    - NONE
*/
SELECT * FROM Sections

////////////////////////////////////////////////////////////////////////

/* 

    Create the permissions of the rol 

    Arguments
    .input('sectionID',sql.Int,section.sectionID)
    .input('rolID',sql.Int,request.body.idRolInserted)
    .input('currentTime',sql.DateTime,request.body.today)
    .input('null',sql.Int,null)
    .input('nameUserCreated',sql.VarChar,request.params.userName)

*/

INSERT INTO Permissions 
(
    sectionID,rolID,
    status,description,createdBy,
    createdDate,lastUpadatedDate,lastUpdatedBy
) 

VALUES

(
    @sectionID,@rolID,
    0,@null,@nameUserCreated,
    @currentTime,@currentTime,@nameUserCreated
)

////////////////////////////////////////////////////////////////////////

/* 

    Get permissions of the rol wanted

    Arguments
    .input('rolUser', sql.Int, request.params.idRol)
*/

SELECT * FROM Permissions WHERE rolID = @rolUser

////////////////////////////////////////////////////////////////////////

/* 

    Get the sections of the system

    Arguments
    .input('rolUser', sql.Int, request.params.idRol)
*/

(SELECT 
    permissions.permissionID AS permission,
    permissions.status AS permissionStatus,
    permissions.createdBy AS permissionCreatedBy,
    permissions.lastUpdatedBy AS permissionLastUpdatedBy,
    permissions.lastUpadatedDate AS permissionLastUpdatedDate,
    
    sections.description AS description,
    sections.level AS level,
    sections.sectionID AS sectionID,
    sections.parentSectionID as parentSectionID,
    sections.Comentarios AS comment,
    sections.status AS sectionStatus,
    sections.createdBy AS sectionCreatedBy,
    sections.lastUpdatedBy AS sectionLastUpdatedBy,
    sections.lastUpadatedDate AS sectionLastUpdatedDate,
    sections.orderElement AS orderElement

    FROM Permissions       
    JOIN Sections on Permissions.sectionID = Sections.sectionID
    WHERE rolID = @rolUser    
            
) ORDER BY orderElement

/* 

    Get the sections of the system

    Arguments  
    -NONE
*/
SELECT 
    sectionID,
    parentSectionID,
    status,
    level,
    description,
    orderElement

    FROM Sections
    
ORDER BY orderElement