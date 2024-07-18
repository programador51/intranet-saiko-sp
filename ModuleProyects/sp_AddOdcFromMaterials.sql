-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-15-2024
-- Description: Add a new ODC from materials
-- STORED PROCEDURE NAME:	sp_AddOdcFromMaterials
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idSupplier: The supplier id
-- @subTotalCost: The sub total cost
-- @subTotalSell: The sub total sell
-- @createdBy: The user who created the ODC
-- @idExecutive: The executive id
-- @idPosition: The position id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @tranName: The transaction name
-- @trancount: The transaction count
-- @tc: The exchange rate
-- @idTypeDocument: The type document id
-- @idStatus: The status id
-- @iva: The IVA
-- @generateCxP: The generate CxP
-- @idCurrency: The currency id
-- @acreditedAmount: The acredited amount
-- @initialDate: The initial date
-- @expirationDate: The expiration date
-- @reminderDate: The reminder date
-- @ivaAmount: The IVA amount
-- @totalAmount: The total amount

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
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_AddOdcFromMaterials')
    BEGIN 

        DROP PROCEDURE sp_AddOdcFromMaterials;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/15/2024
-- Description: sp_AddOdcFromMaterials - Add a new ODC from materials
CREATE PROCEDURE sp_AddOdcFromMaterials(
    @idSupplier INT,
    @subTotalCost DECIMAL(14,4),
    @subTotalSell DECIMAL(14,4),
    @createdBy NVARCHAR(30),
    @idExecutive INT,
    @idPosition INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(50) = 'addOdcFromMaterials';
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
        DECLARE @tc DECIMAL(14,4);

        DECLARE @idTypeDocument INT = 3;
        DECLARE @idStatus INT = 10;
        DECLARE @iva DECIMAL(14,4) = 0.16;
        DECLARE @generateCxP BIT = 1;
        DECLARE @idCurrency INT = 1;
        DECLARE @acreditedAmount DECIMAL(14,4)=0;

        DECLARE @initialDate DATETIME = GETUTCDATE();
        DECLARE @expirationDate DATETIME = EOMONTH(@initialDate);
        DECLARE @reminderDate DATETIME = DATEADD(DAY, (DAY(EOMONTH(@initialDate))/2), EOMONTH(@initialDate, -1));

        DECLARE @ivaAmount DECIMAL(14,4)= @subTotalCost * @iva;
        DECLARE @totalAmount DECIMAL(14,4)= @subTotalCost + @ivaAmount;

    INSERT INTO Documents (
        amountToBeCredited,
        amountToPay,
        createdBy,
        expirationDate,
        generateCxP,
        idCurrency,
        idCustomer,
        idExecutive,
        idStatus,
        idTypeDocument,
        ivaAmount,
        lastUpdatedBy,
        protected,
        reminderDate,
        subTotalAmount,
        totalAcreditedAmount,
        totalAmount,
        initialDate,
        idPosition,
        UEN
    )
    VALUES (
        @totalAmount,
        @totalAmount,
        @createdBy,
        @expirationDate,
        @generateCxP,
        @idCurrency,
        @idSupplier,
        @idExecutive,
        @idStatus,
        @idTypeDocument,
        @ivaAmount,
        @createdBy,
        @tc,
        @reminderDate,
        @subTotalCost,
        @acreditedAmount,
        @totalAmount,
        @initialDate,
        @idPosition,
        1
    )


    SELECT SCOPE_IDENTITY() AS idOdc;

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