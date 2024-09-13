-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-18-2024
-- Description: Get total remission by proyect
-- STORED PROCEDURE NAME:	sp_GetTotalRemissionByProyect
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idPosition INT - Id position to filter
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @TotalSellByPosition DECIMAL(20,4) - Total sell by position
-- @CurrentTotalSellByPosition DECIMAL(20,4) - Current total sell by position
-- @ResiduSellByPosition DECIMAL(20,4) - Residu sell by position
-- ===================================================================================================================================
-- Returns: 
-- totalSellByPosition DECIMAL(20,4) - Total sell by position
-- currentTotalSellByPosition DECIMAL(20,4) - Current total sell by position
-- residuSellByPosition DECIMAL(20,4) - Residu sell by position
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-06-18		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetTotalRemissionByProyect')
    BEGIN 

        DROP PROCEDURE sp_GetTotalRemissionByProyect;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/18/2024
-- Description: sp_GetTotalRemissionByProyect - get total remission by proyect
CREATE PROCEDURE sp_GetTotalRemissionByProyect(
    @idPosition INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @TotalSellByPosition DECIMAL(20,4);
    DECLARE @CurrentTotalSellByPosition DECIMAL(20,4);
    DECLARE @ResiduSellByPosition DECIMAL(20,4);

    SELECT 
        @TotalSellByPosition= SUM(totalSell)
    FROM Materials 
    WHERE 
        idPosition = @idPosition
        AND [status] = 1

    SELECT 
        @CurrentTotalSellByPosition= SUM(subTotalAmount)
    FROM Documents 
    WHERE 
        idPosition = @idPosition
        AND idTypeDocument = 2
        AND idStatus IN (4,5)

    SET @ResiduSellByPosition = @TotalSellByPosition - @CurrentTotalSellByPosition;

    SELECT 
        @TotalSellByPosition AS totalSellByPosition,
        @CurrentTotalSellByPosition AS currentTotalSellByPosition,
        @ResiduSellByPosition AS residuSellByPosition;
    

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------