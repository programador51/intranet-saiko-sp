-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-25-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_AddItemsForRemisions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @quantity INT - The quantity
-- @createdBy NVARCHAR(30) - The user who created the item
-- @idDocument INT - The document id
-- @unitPrice DECIMAL(14,4) - The unit price
-- @idPosition INT - The position id
-- @description NVARCHAR(256) - The description
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @iva DECIMAL(4,2) - The IVA
-- @um NVARCHAR(256) - The unit of measure
-- @umDescription NVARCHAR(256) - The unit of measure description
-- @productKey NVARCHAR(256) - The product key
-- @productKeyDescription NVARCHAR(256) - The product key description
-- @cost DECIMAL(14,4) - The cost
-- @odcClient NVARCHAR(256) - The ODC client
-- @solped NVARCHAR(256) - The solped
-- @positionDescription NVARCHAR(256) - The position description
-- @idCatalogue INT - The catalogue id
-- @idProyect INT - The proyect id
-- @buildDescription NVARCHAR(256) - The build description
-- @subTotalCost DECIMAL(14,4) - The sub total cost
-- @subTotalSell DECIMAL(14,4) - The sub total sell
-- @ivaCost DECIMAL(14,4) - The IVA cost
-- @ivaSell DECIMAL(14,4) - The IVA sell
-- @totalCost DECIMAL(14,4) - The total cost
-- @totalSell DECIMAL(14,4) - The total sell
-- @discount DECIMAL(14,4) - The discount
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
--	2024-07-25		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_AddItemsForRemisions')
    BEGIN 

        DROP PROCEDURE sp_AddItemsForRemisions;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/25/2024
-- Description: sp_AddItemsForRemisions - Some Notes
CREATE PROCEDURE sp_AddItemsForRemisions(
    @quantity INT,
    @createdBy NVARCHAR(30),
    @idDocument INT,
    @unitPrice DECIMAL(14,4),
    @idPosition INT,
    @description NVARCHAR(256)
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
    DECLARE @cost DECIMAL(14,4) = 0;

    DECLARE @odcClient NVARCHAR(256);
    DECLARE @solped NVARCHAR(256);
    DECLARE @positionDescription NVARCHAR(256);
    
    DECLARE @idCatalogue INT=0
    DECLARE @idProyect INT;
    
    SELECT 
        @iva =ivaSellRate,
        @um = um,    
        @umDescription = umDescription,
        @productKey= satKey,
        @productKeyDescription= satDescription,
        @odcClient = ISNULL(ocCustomer,'ND'),
        @positionDescription = ISNULL([description],'ND'),
        @idProyect = idProject
    FROM PositionsProyects WHERE id = @idPosition;

    SELECT 
        @solped = ISNULL(solped,'ND')
    FROM Proyects WHERE id = @idProyect;

    DECLARE @buildDescription NVARCHAR(256) = 
    'Orden de compra No. ' + @odcClient + ' - ' + 
    'Solped No. ' + @solped + ' - ' + 
    @positionDescription + ' - ' + @description;




    DECLARE @subTotalCost DECIMAL(14,4)= @cost * @quantity;
    DECLARE @subTotalSell DECIMAL(14,4)= @unitPrice * @quantity;

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
        currency
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
        @unitPrice,
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
        @subTotalSell,--subTotal
        @subTotalSell,-- subTotalBeforeExchange
        @totalSell,-- totalImport
        @cost,-- unit_cost
        @unitPrice,-- unit_price
        @cost,-- unitCostBeforeExchange
        @unitPrice,-- unitPriceBeforeExchange
        @unitPrice,-- unitSellingPrice
        @unitPrice,-- unitSellingPriceBeforeExchange
        (@unitPrice - @cost)/100,-- utility
        @buildDescription,-- description
        @productKey,-- claveProductoServicio
        @productKeyDescription,-- claveProductoServicioDescripcion
        @um,-- um
        @umDescription,-- umDescripcion
        0,-- ivaExcento
        'MXN'-- currency
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