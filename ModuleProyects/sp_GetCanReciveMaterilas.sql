-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-22-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetCanReciveMaterilas
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idMaterial: The material id
-- @idOdc: The ODC id
-- @quantityToRecive: The quantity to recive
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @recivedMaterials: The recived materials
-- @itemQuantity: The item quantity
-- @totalRecivedMaterials: The total recived materials
-- @canReciveMaterials: Identify if the material can be received
-- @isValidDocument: Identify if the document is valid
-- ===================================================================================================================================
-- Returns: 
-- @canReciveMaterials: Identify if the material can be received
-- @isValidDocument: Identify if the document is valid
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-07-22		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCanReciveMaterilas')
    BEGIN 

        DROP PROCEDURE sp_GetCanReciveMaterilas;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/22/2024
-- Description: sp_GetCanReciveMaterilas - Some Notes
CREATE PROCEDURE sp_GetCanReciveMaterilas(
    @idMaterial INT,
    @idOdc INT,
    @quantityToRecive INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @recivedMaterials INT;
    DECLARE @itemQuantity INT;
    DECLARE @totalRecivedMaterials INT;
    DECLARE @canReciveMaterials BIT =0;
    DECLARE @isValidDocument BIT = 0;

    SELECT
        @isValidDocument = CASE 
            WHEN document.idStatus != 12 THEN 1
            ELSE 0
        END
    FROM  Documents AS document
    WHERE 
        document.idDocument = @idOdc
        AND document.idTypeDocument = 3

    IF(@isValidDocument = 1)
        BEGIN
            SELECT 
                @totalRecivedMaterials = SUM(ISNULL(items.quantity,0))
            FROM 
                DocumentItems AS items
            LEFT JOIN Documents AS document ON items.document = document.idDocument
            WHERE 
                document.idStatus != 12
                AND document.idTypeDocument = 3
            GROUP BY 
                items.idMaterial;



            SELECT 
                @recivedMaterials = ISNULL(items.receivedMaterials,0),
                @itemQuantity = items.quantity
            FROM DocumentItems AS items
            WHERE 
                items.document = @idOdc
                AND items.idMaterial = @idMaterial;

            DECLARE @supposedlyReceivedMaterials INT = @recivedMaterials + @quantityToRecive;


            SELECT 
                @canReciveMaterials = CASE 
                    WHEN (@supposedlyReceivedMaterials  < @itemQuantity) AND (@supposedlyReceivedMaterials < @totalRecivedMaterials) THEN 1
                    ELSE 0
                END

        END

        SELECT 
            @canReciveMaterials AS canReciveMaterials,
            @isValidDocument AS isValidDocument;



END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------