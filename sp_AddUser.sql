-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Create a new executive on the system

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @userName: Username will have the executive
-- @password: Will be a random password but hashed and encrypted
-- @passTemp: Will be a random password but hashed and encrypted
-- @email: Email will be associated the executive account
-- @initials: Initials of the executive according of his name
-- @firstName: First name of the executive
-- @middleName: Middlename of executive
-- @lastName1: Parent last name 
-- @lastName2: Mother last name
-- @birthDay: Birth day executive
-- @birthMonth: Birth month executive
-- @userCreated: FirstName, middleName and lastName1 of the user who created the new executive
-- @rol: ID rol will have the executive
-- @status: 1 active or 0 inactive executive

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

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