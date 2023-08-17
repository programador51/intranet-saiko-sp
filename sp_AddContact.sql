-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 12-27-2022
-- Description: Add a contact to a customer
-- STORED PROCEDURE NAME:	sp_AddContact
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idCustomer
-- @firstName
-- @middleName
-- @lastName1
-- @lastName2
-- @ladaPhone
-- @phone
-- @ladaCel
-- @cel
-- @workTitle
-- @email
-- @createdBy
-- @isForPayments
-- @isForCollection
-- @birthdate
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @idContact INT
-- ===================================================================================================================================
-- Returns: 
-- The id of the inserted row
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-12-27		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 12/27/2022
-- Description: sp_AddContact -  Add a contact to a customer
CREATE PROCEDURE sp_AddContact(
    @idCustomer INT,
    @firstName NVARCHAR(30),
    @middleName NVARCHAR(30),
    @lastName1 NVARCHAR(30),
    @lastName2 NVARCHAR(30),
    @ladaPhone NVARCHAR(3),
    @phone NVARCHAR(30),
    @ladaCel NVARCHAR(3),
    @cel NVARCHAR(30),
    @workTitle NVARCHAR(100),
    @email NVARCHAR(50),
    @createdBy NVARCHAR(30),
    @isForPayments BIT,
    @isForCollection BIT,
    @birthdate DATETIME
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idContact INT;

    INSERT INTO Contacts
        (
        customerID,
        firstName,
        middleName,
        lastName1,
        lastName2,
        phoneNumberAreaCode,
        phoneNumber,
        cellNumberAreaCode,
        cellNumber,
        [position],
        email,
        [status],
        createdBy,
        createdDate,
        lastUpdatedBy,
        lastUpdatedDate,
        isForPayments,
        isForColletion,
        birthDay

        )
    VALUES(
            @idCustomer,
            @firstName,
            @middleName,
            @lastName1,
            @lastName2,
            @ladaPhone,
            @phone,
            @ladaCel,
            @cel,
            @workTitle,
            @email,
            1,
            @createdBy,
            GETUTCDATE(),
            @createdBy,
            GETUTCDATE(),
            @isForPayments,
            @isForCollection,
            @birthdate
    )

    SELECT @idContact= SCOPE_IDENTITY()

    RETURN @idContact;


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------