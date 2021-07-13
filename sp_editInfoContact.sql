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
-- Description: sp_editInfoContact permite actualizar la informacion de contacto
--				que se selecciono de la tabla; el id que se compara es el de contactID
-- =============================================
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
