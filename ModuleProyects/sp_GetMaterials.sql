-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-07-2024
-- Description: Get materials of a position proyect
-- STORED PROCEDURE NAME:	sp_GetMaterials
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idProyect INT - Proyect id
-- @idPosition INT - Position id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @totalCost DECIMAL(20,4) - Total cost of the materials
-- @residueCost DECIMAL(20,4) - Residue cost of the materials
-- @currentCost DECIMAL(20,4) - Current cost of the materials
-- @solped NVARCHAR(256) - Solped
-- @position NVARCHAR(256) - Position
-- @client NVARCHAR(256) - Client
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-06-07		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetMaterials')
    BEGIN 

        DROP PROCEDURE sp_GetMaterials;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/07/2024
-- Description: sp_GetMaterials - Get materials of a position proyect
CREATE PROCEDURE sp_GetMaterials(
    @idProyect INT,
    @idPosition INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @totalCost DECIMAL(20,4);
    DECLARE @residueCost DECIMAL(20,4);
    DECLARE @currentCost DECIMAL(20,4);

    DECLARE @solped NVARCHAR(256);
    DECLARE @position NVARCHAR(256);
    DECLARE @client NVARCHAR(256);

    SELECT 
        @totalCost = SUM(material.totalCost),
        @residueCost = SUM((material.residueQuantity* material.cost)),
        @currentCost = SUM((material.currentQuantity* material.cost))
    FROM Materials AS material
    WHERE 
        material.idProyect = @idProyect 
        AND material.idPosition = @idPosition
        AND material.[status] = 1;

    SELECT 
        @solped = proyect.solped,
        @position = position.pos,
        @client = proyect.buyer
    FROM PositionsProyects AS position
    LEFT JOIN Proyects AS proyect ON position.idProject = proyect.id
    WHERE 
        position.id = @idPosition
        AND proyect.id = @idProyect;


    SELECT 
        catalogue.[description] AS [description],
        catalogue.satUmDescription AS unit,
        material.initialQuantity,
        material.residueQuantity,
        material.cost,
        material.id,
        material.idCatalogue,
        material.idPosition,
        material.idProyect,
        (
            SELECT 
                SUM(item.receivedMaterials)
            FROM DocumentItems AS item
            LEFT JOIN Documents AS document ON material.idPosition = document.idPosition
            WHERE 
                document.[idStatus] !=12 
                AND document.idTypeDocument = 3 
                AND item.idCatalogue = material.idCatalogue
                AND material.idPosition = document.idPosition
        )AS receivedMaterials
    FROM Materials AS material
    LEFT JOIN Catalogue AS catalogue ON material.idCatalogue = catalogue.id_code
    WHERE 
        material.idProyect = @idProyect 
        AND material.idPosition = @idPosition
        AND material.[status] = 1;

    SELECT 
        @solped AS solped,
        @position AS pos,
        @client AS buyer,
        @totalCost AS totalCost,
        @residueCost AS residueCost,
        @currentCost AS currentCost;
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------


/**
Para obtener la cantidad de materiales recibidos
Tengo que sumar la cantidad de materiales recibidos de cada orden de compra relacionada a la posicion del proyecto
Tengo que identificar las ordenes de compra relacionadas a la posicion del proyecto
**/