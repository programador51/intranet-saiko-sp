-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-15-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_AddItemsFromMaterials
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @cost: The cost
-- @sell: The sell
-- @idCatalogue: The catalogue id
-- @quantity: The quantity
-- @createdBy: The user who created the ODC
-- @idDocument: The document id
-- @description: The description
-- @idMaterial: The material id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @iva: The IVA
-- @um: The unit of measure
-- @umDescription: The unit of measure description
-- @subTotalCost: The sub total cost
-- @subTotalSell: The sub total sell
-- @ivaCost: The IVA cost
-- @ivaSell: The IVA sell
-- @totalCost: The total cost
-- @totalSell: The total sell
-- @discount: The discount
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
--	2024-07-15		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_AddItemsFromMaterials')
    BEGIN 

        DROP PROCEDURE sp_AddItemsFromMaterials;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/15/2024
-- Description: sp_AddItemsFromMaterials - Some Notes
CREATE PROCEDURE sp_AddItemsFromMaterials(
    @quantity INT,
    @createdBy NVARCHAR(30),
    @idDocument INT,
    @idMaterial INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(50) = 'addItemFromMaterials';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;
    BEGIN TRY
        IF (@trancount = 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
        ELSE
            BEGIN
                SAVE TRANSACTION @tranName;
            END


    DECLARE @iva DECIMAL(4,2);
    DECLARE @um NVARCHAR(256)
    DECLARE @umDescription NVARCHAR(256)
    DECLARE @productKey NVARCHAR(256)
    DECLARE @productKeyDescription NVARCHAR(256)
    DECLARE @cost DECIMAL(14,4);
    DECLARE @sell DECIMAL(14,4);
    DECLARE @description NVARCHAR(256)
    DECLARE @idCatalogue INT;
    SELECT 
        @iva =iva,
        @um = SATUM,    
        @umDescription = satUmDescription,
        @productKey= SATCODE,
        @productKeyDescription= satCodeDescription 
    FROM Catalogue WHERE id_code = @idCatalogue;


    SELECT 
        @cost = cost,
        @sell = sell,
        @description = [description],
        @idCatalogue = idCatalogue
    FROM Materials WHERE id = @idMaterial;

    DECLARE @subTotalCost DECIMAL(14,4)= @cost * @quantity;
    DECLARE @subTotalSell DECIMAL(14,4)= @sell * @quantity;

    DECLARE @ivaCost DECIMAL(14,4)= @subTotalCost * @iva/100;
    DECLARE @ivaSell DECIMAL(14,4)= @subTotalSell * @iva/100;

    DECLARE @totalCost DECIMAL(14,4)= @subTotalCost + @ivaCost;
    DECLARE @totalSell DECIMAL(14,4)= @subTotalSell + @ivaSell;
    
    DECLARE @discount DECIMAL(14,4)= 0;

    INSERT INTO DocumentItems (
        calculationCostDiscount,
        calculationCostImport,
        calculationCostIva,
        calculationCostSell,
        calculationCostSubtotal,
        calculationCostUnitary,
        calculationPriceDiscount,
        calculationPriceImport,
        calculationPriceIva,
        calculationPriceSell,
        calculationPriceSubtotal,
        calculationPriceUnitary,
        costDiscount,-- 
        createdBy,
        createdDate,
        discount,
        discountPercentage,
        document,
        idCatalogue,
        iva,
        ivaBeforeExchange,
        ivaPercentage,
        lastUpdatedBy,
        lastUpdatedDate,
        [order],
        priceDiscount,
        quantity,
        [status],
        subTotal,
        subTotalBeforeExchange,
        totalImport,
        unit_cost,
        unit_price, 
        unitCostBeforeExchange,
        unitPriceBeforeExchange,
        unitSellingPrice,
        unitSellingPriceBeforeExchange,  
        utility,
        [description],
        claveProductoServicio,
        claveProductoServicioDescripcion,
        um,
        umDescripcion,
        ivaExcento,
        currency,
        receivedMaterials,
        idMaterial
    )
    VALUES (
        @discount,
        @subTotalCost,
        @ivaCost,
        @subTotalSell,
        @subTotalCost,
        @cost,
        @discount,
        @subTotalSell,
        @ivaSell,
        @subTotalSell,
        @subTotalSell,
        @sell,
        @discount,
        @createdBy,
        GETUTCDATE(),
        @discount,
        @discount,
        @idDocument,
        @idCatalogue,
        @iva,
        @ivaCost,
        @iva,
        @createdBy,
        GETUTCDATE(),
        1,
        @discount,
        @quantity,
        1,
        @subTotalCost,
        @subTotalCost,
        @totalCost,
        @cost,
        @sell,
        @cost,
        @sell,
        @sell,
        @sell,
        (@sell - @cost)/100,
        @description,
        @productKey,
        @productKeyDescription,
        @um,
        @umDescription,
        0,
        'MXN',
        0,
        @idMaterial
    )
IF (@trancount = 0)
            BEGIN
                COMMIT TRANSACTION @tranName;
            END
    END TRY
    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()
        DECLARE @Message   NVARCHAR(MAX)
        DECLARE @xstate INT= XACT_STATE();

        DECLARE @infoSended NVARCHAR(MAX)= 'Sin informacion por el momento';
        DECLARE @wasAnError TINYINT=1;
        DECLARE @mustBeSyncManually TINYINT=1;
        DECLARE @provider TINYINT=4;

        SET @Message= ERROR_MESSAGE();
        IF (@xstate= -1)
            BEGIN
                ROLLBACK TRANSACTION @tranName
            END
        IF (@xstate=1 AND @trancount=0)
            BEGIN
                -- COMMIT TRANSACTION @tranName
                ROLLBACK TRANSACTION @tranName
            END

        IF (@xstate=1 AND @trancount > 0)
            BEGIN
                ROLLBACK TRANSACTION @tranName;
            END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;
    END CATCH



END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------