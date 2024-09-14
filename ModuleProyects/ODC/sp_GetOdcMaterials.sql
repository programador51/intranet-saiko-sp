-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-23-2024
-- Description: Get ODC materials
-- STORED PROCEDURE NAME:	sp_GetOdcMaterials
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idOdc INT - ODC id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-07-23		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetOdcMaterials')
    BEGIN 

        DROP PROCEDURE sp_GetOdcMaterials;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/23/2024
-- Description: sp_GetOdcMaterials - Get ODC materials
CREATE PROCEDURE sp_GetOdcMaterials(
    @idOdc INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    SELECT 
        materials.id AS id,
        items.unit_cost AS cost,
        items.quantity AS currentQuantity,
        items.description AS [description],
        items.idCatalogue AS idCatalogue,
        materials.idPosition AS idPosition,
        materials.idProyect AS idProyect,
        items.quantity AS initialQuantity,
        ISNULL(items.receivedMaterials,0) AS receivedMaterials,
        (items.quantity  - ISNULL(items.receivedMaterials,0)) AS residueQuantity,
        items.unit_price AS sell,
        items.status AS status,
        items.calculationCostImport AS totalCost,
        items.calculationCostSell AS totalSell,
        items.umDescripcion AS unit

    FROM DocumentItems AS items
    LEFT JOIN Materials AS materials ON materials.id = items.idMaterial
    WHERE 
        items.document =@idOdc

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------