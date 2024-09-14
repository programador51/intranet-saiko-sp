-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-05-2024
-- Description: Validates if a proposal can be added
-- STORED PROCEDURE NAME:	sp_GetCanAddProposal
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS
-- @positions: The positions to validate
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @isSameProject: Identify if all the positions are from the same project
-- @isAllStatusGood: Identify if all the positions have a good status
-- ===================================================================================================================================
-- Returns: 
-- @canAddProposal: Identify if the proposal can be added
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-08-05		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCanAddProposal')
    BEGIN 

        DROP PROCEDURE sp_GetCanAddProposal;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/05/2024
-- Description: sp_GetCanAddProposal - Validates if a proposal can be added
CREATE PROCEDURE sp_GetCanAddProposal(
    @positions ProposalPositionIdType READONLY
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @isSameProject BIT;
    DECLARE @isAllStatusGood BIT;


    -- Inserta los IDs de proyecto asociados con las posiciones en una tabla temporal
    SELECT idProject INTO #Projects
    FROM PositionsProyects
    WHERE id IN (SELECT idPosition FROM @positions);

    -- Comprueba si todos los IDs de posición pertenecen al mismo proyecto
    SELECT @isSameProject = CASE
        WHEN COUNT(DISTINCT idProject) = 1 THEN 1
        ELSE 0
    END
    FROM #Projects;

    DROP TABLE #Projects 

    SELECT 
        @isAllStatusGood = 
            CASE
                WHEN COUNT(*) = SUM(CASE WHEN statusPosition != 'Cancelar' THEN 1 ELSE 0 END) THEN 1
                ELSE 0
            END
        FROM PositionsProyects WHERE id IN (SELECT idPosition FROM @positions);


    SELECT 
        CASE 
            WHEN @isSameProject = 1 AND @isAllStatusGood = 1 THEN CAST(1 AS BIT)
            ELSE CAST(0 AS BIT)
        END AS canAddProposal;


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------