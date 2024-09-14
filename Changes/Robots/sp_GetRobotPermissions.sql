-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-30-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetRobotPermissions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-04-30		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetRobotPermissions')
    BEGIN 

        DROP PROCEDURE sp_GetRobotPermissions;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/30/2024
-- Description: sp_GetRobotPermissions - Some Notes
CREATE PROCEDURE sp_GetRobotPermissions AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    DECLARE @permission TABLE (
        id INT NOT NULL IDENTITY(1,1),
        idParameter INT
    )
    INSERT INTO @permission (
        idParameter
    )
    VALUES
    (48),
    (49),
    (50),
    (51),
    (52),
    (53),
    (54)

    SELECT 
        [description],
        [value]
    FROM Parameters
    WHERE parameter  IN (SELECT idParameter FROM @permission);
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------