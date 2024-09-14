-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-02-2021
-- Description: gets all the users on the sistem
-- STORED PROCEDURE NAME:	sp_getAllUsers
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-02		Adrian Alardin   			1.0.0.0			Initial Revision
--  2021-07-23      Adrian Alardin              1.0.0.1         Documentation update		
-- *****************************************************************************************************************************
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
