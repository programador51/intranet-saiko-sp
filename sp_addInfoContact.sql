-- =======================================================
-- Create Stored Procedure Template for Azure SQL Database
-- =======================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/02/2021
-- Description: sp_addInfoContact permite agregar la infromacion de contacto relacionado a la cuenta
-- =============================================
CREATE PROCEDURE sp_addInfoContact
(
    -- Add the parameters for the stored procedure here
    @customerID INT,
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
    INSERT INTO Contacts (
            customerID,
            firstName,
            middleName,
            lastName1,
            lastName2,
            phoneNumberAreaCode,
            phoneNumber,
            cellNumberAreaCode,
            cellNumber,
            position,
            email,
            status,
            createdBy,
            createdDate,
            lastUpdatedBy,
            lastUpdatedDate)
            VALUES (
                @customerID,
                @nombre,
                @middleName,
                @apellidoP,
                @apellidoM,
                @ladaPhone,
                @phone,
                @ladaCel,
                @cellphone,
                @puesto,
                @email,
                @estatus,
                @modifyBy,
                @today,
                @modifyBy,
                @today
            )
END
GO
