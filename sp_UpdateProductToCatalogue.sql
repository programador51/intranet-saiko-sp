-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-03-2023
-- Description: Update the product
-- STORED PROCEDURE NAME:	sp_UpdateProductToCatalogue
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
--	2023-08-03		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/10/2023
-- Description: sp_UpdateProductToCatalogue - Update the product
CREATE PROCEDURE sp_UpdateProductToCatalogue(
    @idCatalogue INT,
    @description NVARCHAR(1000),
    @unitPrice DECIMAL(14,4),
    @unitCost DECIMAL(14,4),
    @satCode NVARCHAR(20),
    @satUM NVARCHAR(20),
    @iva DECIMAL(4,2),
    @uen INT,
    @createdBy NVARCHAR(30),
    @sku NVARCHAR(256),
    @currency INT,
    @status TINYINT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='updateUen';
    DECLARE @trancount INT;

    SET @trancount = @@trancount;
    BEGIN TRY
        IF (@trancount= 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
        ELSE
            BEGIN
                SAVE TRANSACTION @tranName
            END

        DECLARE @today DATETIME;
        SELECT @today = GETUTCDATE();

        UPDATE Catalogue SET 
        [description]=@description,
        unit_price=@unitPrice,
        unit_cost=@unitCost,
        SATCODE=@satCode,
        SATUM=@satUM,
        iva=@iva,
        uen=@uen,
        lastUpdatedBy=@createdBy,
        lastUpdatedDate=@today,
        sku=@sku,
        currency=@currency,
        [status]=@status
        WHERE id_code=@idCatalogue
        SELECT @idCatalogue AS id
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
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------