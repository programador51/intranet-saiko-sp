CREATE PROCEDURE sp_AddUser(

	@userName NVARCHAR(50),
	@password NVARCHAR(300),
	@passTemp NVARCHAR(300),
	@email NVARCHAR(50),
	@initials NVARCHAR(5),
	@firstName NVARCHAR(30),
	@middleName NVARCHAR(30),
	@lastName1 NVARCHAR(30),
	@lastName2 NVARCHAR(30),
	@birthDay INT,
	@birthMonth INT,
	@userCreated INT,
	@rol INT,
	@status TINYINT

)

AS BEGIN

INSERT INTO Users 

(
	userName,password,
	temporalPassword,email,initials,
	firstName,middleName,lastName1,
	lastName2,birthDay,birthMonth,
	rol,status,
	createdBy,createdDate,lastUpdatedBy,
	lastUpdatedDate
				
)
            
	VALUES 
(
	@userName, @password,
	@passTemp, @email, @initials,
	@firstName, @middleName, @lastName1,
	@lastName2, @birthDay, @birthMonth,
	@rol, @status,
	@userCreated, GETDATE(), @userCreated,
	GETDATE()
)

END