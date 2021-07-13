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
-- Description: sp_getPageInfoContact permite obtener la cantidad de paginas para el filtro de estatus y texto
-- =============================================
CREATE PROCEDURE sp_getPageInfoContact
(
    -- Add the parameters for the stored procedure here
    @customerID INT,
    @estatus TINYINT,
    @search NVARCHAR(30)

)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
   SELECT Count(*) FROM Contacts WHERE (customerID=@customerID AND status=@estatus) AND (
                        firstName LIKE @search OR
                        middleName LIKE @search OR
                        lastName1 LIKE @search OR
                        lastName2 LIKE @search
                        )
END
GO
