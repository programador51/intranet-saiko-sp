-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-02-2021
-- Description: Update the information contact related to the customers
-- STORED PROCEDURE NAME:	sp_UpdateInfoContact
-- STORED PROCEDURE OLD NAME: sp_editInfoContact
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerID: Is the id of the customer to whom the contact is related
-- @nombre: Is the firstname of the contact (not null)
-- @middleName: Is the middle name of the contact (allow null)
-- @apellidoP: Is the paternal surname (not null)
-- @apellidoM: Is the maternal surname (not null)
-- @ladaPhone: The phone lada (allow null)
-- @phone: The phone number (allow null)
-- @ladaCel: The celphone lada (allow null)
-- @cellphone: The cellphone number (allow null)
-- @puesto: charge description (allow null)
-- @email: The email 
-- @estatus: Indicates whether the contact is active or not
-- @modifyBy: Who added/modify the record
-- @today: The day it was created or modified
-- ===================================================================================================================================
-- Returns:    
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-02		Adrian Alardin   			1.0.0.0			Initial Revision
--  2021-07-23      Adrian Alardin              1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_editInfoContact
(
    -- Add the parameters for the stored procedure here
    @contactID INT,
    @nombre NVARCHAR(30),
    @middleName NVARCHAR(30),
    @apellidoP NVARCHAR(30),
    @apellidoM NVARCHAR(30),
    @ladaPhone NVARCHAR(3),
    @phone NVARCHAR(20),
    @ladaCel NVARCHAR(3),
    @cellphone NVARCHAR(20),
    @puesto NVARCHAR(100),
    @email NVARCHAR(50),
    @estatus TINYINT,
    @modifyBy NVARCHAR(30),
    @today DATETIME
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    UPDATE  Contacts 
            SET 
            firstName=@nombre,
            middleName=@middleName,
            lastName1=@apellidoP,
            lastName2=@apellidoM,
            phoneNumberAreaCode=@ladaPhone,
            phoneNumber=@phone,
            cellNumberAreaCode=@ladaCel,
            cellNumber=@cellphone,
            position=@puesto,
            email=@email,
            status=@estatus,
            lastUpdatedBy=@modifyBy,
            lastUpdatedDate=@today
            WHERE contactID=@contactID
END
GO
