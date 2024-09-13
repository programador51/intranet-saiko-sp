-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-20-2024
-- Description: Get the proyect information by the position id
-- STORED PROCEDURE NAME:	sp_GetProyectByPositionId
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idPosition: The position id
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
--	2024-08-20		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetProyectByPositionId')
    BEGIN 

        DROP PROCEDURE sp_GetProyectByPositionId;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/20/2024
-- Description: sp_GetProyectByPositionId - Get the proyect information by the position id
CREATE PROCEDURE sp_GetProyectByPositionId(
    @idPosition INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        proyect.*
    FROM Proyects AS proyect
    LEFT JOIN PositionsProyects AS position ON proyect.id = position.idProject
    WHERE position.id = @idPosition;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------