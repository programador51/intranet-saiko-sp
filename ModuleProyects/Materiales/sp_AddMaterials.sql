-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-06-2024
-- Description: Add a new material to position proyect
-- STORED PROCEDURE NAME:	sp_AddMaterials
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @cost DECIMAL(20,4) - Cost of the material
-- @idCatalogue INT - Catalogue id
-- @idPosition INT - Position id
-- @idProyect INT - Proyect id
-- @idSupplier INT - Supplier id
-- @labourCost DECIMAL(20,4) - Labour cost
-- @labourPrice DECIMAL(20,4) - Labour price
-- @initialQuantity INT - Initial quantity
-- @sell DECIMAL(20,4) - Sell price
-- @subPos NVARCHAR(256) - Subposition
-- @createdBy NVARCHAR(256) - Created by
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns:
-- idMaterial INT - Material id
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-06-06		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_AddMaterials')
    BEGIN 

        DROP PROCEDURE sp_AddMaterials;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/06/2024
-- Description: sp_AddMaterials - Add a new material to position proyect
CREATE PROCEDURE sp_AddMaterials(
    @cost DECIMAL(20,4),
    @idCatalogue INT,
    @idPosition INT,
    @idProyect INT,
    @initialQuantity INT,
    @sell DECIMAL(20,4),
    @createdBy NVARCHAR(256),
    @description NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='addMaterial';
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


        INSERT INTO Materials (
            cost,
            idCatalogue,
            idPosition,
            idProyect,
            initialQuantity,
            sell,
            createdBy,
            updatedBy,
            [description]
        )VALUES(
            @cost,
            @idCatalogue,
            @idPosition,
            @idProyect,
            @initialQuantity,
            @sell,
            @createdBy,
            @createdBy,
            @description
        );

        SELECT SCOPE_IDENTITY() AS idMaterial;


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