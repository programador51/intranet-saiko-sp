-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 12-28-2022
-- Description: Adds the odc document
-- STORED PROCEDURE NAME:	sp_AddOdc
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
--	2022-12-28		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************

DROP PROCEDURE dbo.sp_AddOdc -- !Eliminar cuando sea necesaario

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 12/28/2022
-- Description: sp_AddOdc - Adds the odc document

CREATE PROCEDURE sp_AddOdc(
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
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR = 'addOrder';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;

    DECLARE @idContactToUse INT;
    DECLARE @idInsertedDocument INT;
    DECLARE @areNewItems BIT;
    DECLARE @areEditItems BIT;

    DECLARE @itemsToTheDocument AS Items;
    DECLARE @itemsToAdd  AS Items;
    DECLARE @itemsToUpdate AS Items;

    DECLARE @documentStatus INT =5-- No facturado
    DECLARE @documentType INT =3 --ODC

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

    INSERT INTO Documents
        (
        amountToBeCredited,
        amountToPay,
        createdBy,
        createdDate,
        creditDays,
        documentNumber, --dbo.fn_NextDocumentNumber(1)
        expirationDate,
        idContact,
        idCurrency,
        idCustomer,
        idExecutive,
        idProgress,
        idStatus,
        idTypeDocument,
        ivaAmount,
        lastUpdatedBy,
        lastUpdatedDate,
        protected,
        reminderDate,
        subTotalAmount,
        totalAmount,
        initialDate

        )
    VALUES(
            @totalAmount,
            @totalAmount,
            @createdBy,
            GETUTCDATE(),
            30, -- dias de creadito
            dbo.fn_NextDocumentNumber(@documentType),
            @expirationDate,
            @idContactToUse,
            @idCurrency,
            @idCustomer,
            @idExecutive,
            @idProbability,
            @active,--Estauts de la cotización.
            @documentType, -- Id del tipo de documento
            @iva,
            @createdBy,
            GETUTCDATE(),
            @tc,
            @reminderDate,
            @subtotal,
            @totalAmount,
            @initialDate
        )
        SELECT @idInsertedDocument= SCOPE_IDENTITY();

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
        @idInsertedDocument,
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
        @idInsertedDocument,
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

    SELECT @idInsertedDocument AS idDocument

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