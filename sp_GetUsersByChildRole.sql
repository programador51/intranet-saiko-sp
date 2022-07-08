-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-08-2022
-- Description: Get the users, the actual user has access to by his role
-- STORED PROCEDURE NAME:	sp_GetUsersByChildRole
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idExecutive: Executive id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @userStatus: User status, would be 1 to indicate it is active
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-07-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/08/2022
-- Description: sp_GetUsersByChildRole - Get the users the actual user has access to by his role
CREATE PROCEDURE sp_GetUsersByChildRole(
    @idExecutive INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @userStatus INT=1;
    IF OBJECT_ID(N'tempdb..#TemChildRoles') IS NOT NULL
        BEGIN
            DROP TABLE #TemChildRoles
        END

    CREATE TABLE #TemChildRoles (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        idChildRole INT
    )

    INSERT INTO #TemChildRoles (
        idChildRole
    )
        SELECT 
            parentRole.idChildRole 
        FROM Users AS users
        LEFT JOIN ParentRoles AS parentRole ON parentRole.idParentRole= users.rol
        WHERE users.userID= @idExecutive
        
        SELECT 
            users.userID AS idRegister,
            users.userID AS idUser,
            users.rol AS rolID,
            users.userID AS ignore,
            users.firstName,
            users.middleName,
            users.lastName1,
            users.lastName2,
            CONCAT(users.firstName,' ',users.middleName,' ',users.lastName1,' ',users.lastName2) AS fullName,
            CONVERT(BIT,0) AS mustErase
        
        FROM #TemChildRoles AS tempRoles
        LEFT JOIN Users AS users ON users.rol= tempRoles.idChildRole
        WHERE users.[status]= @userStatus ORDER BY users.lastName1



        IF OBJECT_ID(N'tempdb..#TemChildRoles') IS NOT NULL
            BEGIN
                DROP TABLE #TemChildRoles
            END
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------