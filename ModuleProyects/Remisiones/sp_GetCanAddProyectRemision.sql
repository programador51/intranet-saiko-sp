-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-24-2024
-- Description: Validate if can add a proyect remision
-- STORED PROCEDURE NAME:	sp_GetCanAddProyectRemision
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idPosition INT - Id proyect to filter
-- @subTotal DECIMAL(14,4) - sub total before IVA 
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @totalRemisions DECIMAL(14,4) - Total amount of remisions
-- @idCancelRemision INT - Id status to cancel remision
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-07-24		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT *
FROM sys.objects
WHERE type = 'P' AND name ='sp_GetCanAddProyectRemision')
    BEGIN

    DROP PROCEDURE sp_GetCanAddProyectRemision;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/24/2024
-- Description: sp_GetCanAddProyectRemision - Validate if can add a proyect remision
CREATE PROCEDURE sp_GetCanAddProyectRemision(
    @idPosition INT,
    @subTotal DECIMAL(14,4)
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @totalRemisions DECIMAL(14,4);
    DECLARE @idCancelRemision INT =6;
    DECLARE @ivaRate DECIMAL(14,4);
    DECLARE @totalAmount DECIMAL(14,4) 

    SELECT 
        @ivaRate = ivaSellRate 
    FROM PositionsProyects 
    WHERE id = @idPosition;

    SET @totalAmount = @subTotal + (@subTotal * @ivaRate / 100);

    SELECT
        @totalRemisions = ISNULL(SUM(document.totalAmount), 0)
    FROM Documents AS document
    WHERE 
        document.idPosition = @idPosition
        AND document.idTypeDocument = 2
        AND document.idStatus != @idCancelRemision
    GROUP BY document.idPosition;

    SELECT
        CASE 
            WHEN (@totalRemisions + (@totalAmount)) <= position.totalSell THEN 1
            ELSE 0
        END AS canAddProyectRemision
    FROM PositionsProyects AS position
    WHERE 
        position.id = @idPosition
        AND position.[status] = 1;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------