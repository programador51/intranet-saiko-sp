IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_AddUen')
    BEGIN 

        DROP PROCEDURE sp_AddUen;
    END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/02/2023
-- Description: sp_AddUen - Add a new UEN
CREATE PROCEDURE [dbo].[sp_AddUen](
    @description NVARCHAR(256),
    @family NVARCHAR(100),
    @subFamily NVARCHAR(100),
    @satCode NVARCHAR(100),
    @satUm NVARCHAR(100),
    @iva DECIMAL(4,2),
    @createdBy NVARCHAR(30),
    @marginRate DECIMAL(5,2),
    @satCodeDescription NVARCHAR(256),
    @satUmDescription NVARCHAR(256),
    @excent TINYINT,
    @requierdConfirmation BIT,
    @requierdCFSign BIT,
    @requierdContractSing BIT,
    @requierdLicences BIT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(50)='addUen';
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
        DECLARE @status TINYINT=1;
        SELECT @today = GETUTCDATE();


        INSERT INTO UEN (
            [description],
            family,
            subFamily,
            SATcode,
            SATUM,
            [status],
            iva,
            createdBy,
            createdDate,
            lastUpdatedBy,
            lastUpdatedDate,
            marginRate,
            satCodeDescription,
            satUmDescription,
            excent,
            requierdConfirmation ,
            requierdCFSign ,
            requierdContractSing ,
            requierdLicences 
        )
        VALUES(
            @description,
            @family,
            @subFamily,
            @satCode,
            @satUm,
            @status,
            @iva,
            @createdBy,
            @today,
            @createdBy,
            @today,
            @marginRate,
            @satCodeDescription,
            @satUmDescription,
            @excent,
            ISNULL(@requierdConfirmation,0),
            ISNULL(@requierdCFSign,0),
            ISNULL(@requierdContractSing,0),
            ISNULL(@requierdLicences,0)
        )

        DECLARE @lastIdentity INT;
        SET @lastIdentity = SCOPE_IDENTITY();

        exec sp_AddFeeUen @uen = @lastIdentity;

        SELECT @lastIdentity AS id;
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
GO
