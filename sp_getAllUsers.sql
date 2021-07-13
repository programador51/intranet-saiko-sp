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
-- Description: sp_getAllUsers permite obtener todos los usuarios del sistema
-- =============================================
CREATE PROCEDURE sp_getAllUsers

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
   SELECT 
                userID AS value,
                firstName,
                middleName,
                lastName1,
                lastName2,
                CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS text FROM Users
            ORDER BY  firstName
END
GO
