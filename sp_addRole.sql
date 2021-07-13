-- =======================================================
-- Create Stored Procedure Template for Azure SQL Database
-- =======================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/05/2021
-- Description: sp_addRole permite agregar el rol del usuario
-- =============================================
CREATE PROCEDURE sp_addRole
(
    -- Add the parameters for the stored procedure here
    @description NVARCHAR(30),
    @status TINYINT,
    @nameUserCreated NVARCHAR(30),
    @today DATETIME
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
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
END
GO
