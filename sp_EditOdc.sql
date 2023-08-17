-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 01-12-2023
-- Description: Edit the odc document
-- STORED PROCEDURE NAME:	sp_EditOdc
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
--	2023-01-12		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 01/12/2023
-- Description: sp_EditOdc - Some Notes
CREATE PROCEDURE sp_EditOdc(
    @idDocument INT,
    @isNewContact BIT,
    @name NVARCHAR(30),
    @middleName NVARCHAR(30),
    @lastName1 NVARCHAR(30),
    @lastName2 NVARCHAR(30),
    @ladaPhoen NVARCHAR(3),
    @phone NVARCHAR(30),
    @ladaCel NVARCHAR(3),
    @cel NVARCHAR(30),
    @email NVARCHAR(50),
    @position NVARCHAR(100),
    @isForCollection BIT,
    @isForPayment BIT,
    @birthday DATETIME,
    @idContact INT,
    @idCurrency INT,
    @tc DECIMAL(14,2),
    @initialDate DATETIME,
    @expirationDate DATETIME,
    @reminderDate DATETIME,
    @idProbability INT,
    @creditDays INT,
    @subtotal DECIMAL(14,2),
    @iva DECIMAL(14,2),
    @totalAmount DECIMAL(14,2),
    @createdBy NVARCHAR(30),
    @idCustomer INT,
    @idExecutive INT,
    @tempComents Comments READONLY,
    @tempItems Items READONLY,
    @tempItemsUpdateCatalogue Items READONLY,
    @tempItemsAddCatalogue Items READONLY
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR = 'editQuote';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;

    DECLARE @idContactToUse INT;
    DECLARE @idInsertedDocument INT;
    DECLARE @areNewItems BIT;
    DECLARE @areEditItems BIT;

    DECLARE @itemsToTheDocument AS Items;
    DECLARE @itemsToAdd  AS Items;
    DECLARE @itemsToUpdate AS Items;
    DECLARE @documentStatus INT =1-- Abierta
    DECLARE @documentType INT =1 --Cotizacion

    DECLARE @active TINYINT =1


    IF OBJECT_ID(N'tempdb..#NewItemsId') IS NOT NULL 
        BEGIN
        DROP TABLE #NewItemsId
    END
    CREATE TABLE #NewItemsId
    (
        id INT NOT NULL IDENTITY(1,1),
        idItemInserted INT
    )
    BEGIN TRY
        IF (@trancount= 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
             END
        ELSE
            BEGIN
                SAVE TRANSACTION @tranName
            END
        
        INSERT INTO @itemsToTheDocument SELECT * FROM @tempItems
        INSERT INTO @itemsToAdd SELECT * FROM @tempItemsAddCatalogue
        INSERT INTO @itemsToUpdate SELECT * FROM @tempItemsUpdateCatalogue

        IF(@isNewContact=1)
            BEGIN
                EXEC @idContactToUse= sp_AddContact @idCustomer,@name,@middleName,@lastName1,@lastName2,@ladaPhoen,@phone,@ladaCel,@cel,@position,@email,@createdBy,@isForPayment,@isForCollection,@birthday
            END
        ELSE 
            BEGIN
                SET @idContactToUse= @idContact
            END

        SELECT
            @areNewItems= 
            CASE
                WHEN COUNT(*) > 0 THEN 1
                ELSE 0
            END
        FROM @tempItemsAddCatalogue;
        SELECT
            @areEditItems= 
            CASE
                WHEN COUNT(*) > 0 THEN 1
                ELSE 0
            END
        FROM @tempItemsUpdateCatalogue;

        IF(@areNewItems=1)
            BEGIN
                INSERT INTO Catalogue
                    (
                    [description],
                    unit_price,
                    unit_cost,
                    SATCODE,
                    SATUM,
                    iva,
                    uen,
                    [status],
                    createdBy,
                    createdDate,
                    lastUpdatedBy,
                    lastUpdatedDate,
                    sku,
                    currency,
                    satCodeDescription,
                    satUmDescription,
                    excent

                    )
                OUTPUT inserted.id_code INTO #NewItemsId(idItemInserted)
                SELECT
                    [description],
                    costU,
                    priceU,
                    satCode, -- productServiceKey => satCode
                    um,
                    ivaPercentage,
                    uen,---Esto es la UEN se va a cambiar despues
                    @active, ---Status
                    @createdBy,
                    GETUTCDATE(),
                    @createdBy,
                    GETUTCDATE(),
                    sku, -- -- productServiceKey => sku
                    @idCurrency,
                    productServiceDescription,
                    umDescription,
                    ivaExempt
                FROM @tempItemsAddCatalogue

                UPDATE @itemsToAdd 
                        SET idCatalogue= catalogo.idItemInserted
                    FROM @itemsToAdd AS itemsInserted
                    INNER JOIN #NewItemsId AS catalogo ON catalogo.id=itemsInserted.id

                UPDATE @itemsToTheDocument
                    SET idCatalogue= catalogoInsertado.idCatalogue
                    FROM @itemsToTheDocument AS itemsDocumento
                    INNER JOIN @itemsToAdd  AS catalogoInsertado ON catalogoInsertado.uuid=itemsDocumento.uuid
        END

        IF (@areEditItems=1)
            BEGIN
                UPDATE Catalogue SET
                    [description]= itemesToUpdate.[description],
                    unit_price=itemesToUpdate.priceU,
                    unit_cost=itemesToUpdate.costU,
                    iva=itemesToUpdate.ivaPercentage,
                    lastUpdatedBy=@createdBy,
                    lastUpdatedDate=GETUTCDATE(),
                    excent=itemesToUpdate.ivaExempt
                FROM Catalogue AS catalogo
                INNER JOIN @itemsToUpdate AS itemesToUpdate ON itemesToUpdate.idCatalogue= catalogo.id_code
            END

        DELETE FROM DocumentItems WHERE document=@idDocument
        DELETE FROM CommentsNotesAndConsiderations WHERE idDocument=@idDocument

        UPDATE Documents SET 
            amountToBeCredited=@totalAmount,
            amountToPay=@totalAmount,
            creditDays=@creditDays,
            expirationDate=@expirationDate,
            idContact=@idContactToUse,
            idCurrency=@idCurrency,
            ivaAmount=@iva,
            lastUpdatedBy=@createdBy,
            lastUpdatedDate=GETUTCDATE(),
            protected=@tc,
            reminderDate=@reminderDate,
            subTotalAmount=@subtotal,
            totalAmount=@totalAmount,
            initialDate=@initialDate
        WHERE idDocument= @idDocument;

        INSERT INTO DocumentItems
            (
            calculationCostDiscount,
            calculationCostImport,
            calculationCostIva,
            calculationCostSubtotal,
            calculationCostUnitary,
            calculationPriceDiscount,
            calculationPriceImport,
            calculationPriceIva,
            calculationPriceSubtotal,
            calculationPriceUnitary,
            costDiscount,
            createdBy,
            createdDate,
            discount,
            discountPercentage,
            document,
            idCatalogue,
            iva,
            ivaPercentage,
            lastUpdatedBy,
            lastUpdatedDate,
            [order],
            priceDiscount,
            quantity,
            [status],
            subTotal,
            totalImport,
            unit_cost,
            unit_price,
            utility,
            [description],
            claveProductoServicio,
            claveProductoServicioDescripcion,
            um,
            umDescripcion,
            ivaExcento
            )
        SELECT
            costDiscount,
            costImport,
            costIva,
            costSubTotal,
            costU,
            priceDiscount,
            priceImport,
            priceIva,
            priceSubTotal,
            priceU,
            costDiscountPercentage,
            @createdBy,
            GETUTCDATE(),
            priceDiscountPercentage,
            priceDiscountPercentage,
            @idDocument,
            idCatalogue,
            priceIva,
            ivaPercentage,
            @createdBy,
            GETUTCDATE(),
            [order],
            priceDiscount,
            quantity,
            @active,--Status
            subTotal,
            total,
            costU,
            priceU,
            utility,
            [description],
            satCode,
            productServiceDescription,
            um,
            umDescription,
            ivaExempt

        FROM @itemsToTheDocument

            INSERT INTO CommentsNotesAndConsiderations
            (
            idDocument,
            comment,
            commentType,
            createdBy,
            createdDate,
            isEditable,
            isRemovable,
            lastUpdateBy,
            lastUpdateDate,
            [order],
            [status]
            )
        SELECT
            @idDocument,
            comment,
            commnetType,
            @createdBy,
            GETUTCDATE(),
            isEditable,
            isRemovable,
            @createdBy,
            GETUTCDATE(),
            [order],
            @active
        --Status
        FROM @tempComents

        SELECT @idDocument AS idDocument


        IF (@trancount=0)
            BEGIN
                COMMIT TRANSACTION @tranName
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
      IF OBJECT_ID(N'tempdb..#NewItemsId') IS NOT NULL 
        BEGIN
            DROP TABLE #NewItemsId
        END
    IF OBJECT_ID(N'tempdb..#itemsToTheDocument') IS NOT NULL 
        BEGIN
            DROP TABLE #itemsToTheDocument
        END
    IF OBJECT_ID(N'tempdb..#itemsToTheCatalog') IS NOT NULL 
        BEGIN
            DROP TABLE #itemsToTheCatalog
        END
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------