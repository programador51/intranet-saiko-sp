
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_UpdateUen')
    BEGIN 

        DROP PROCEDURE sp_UpdateUen;
    END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/03/2023
-- Description: sp_UpdateUen - Some Notes
CREATE PROCEDURE [dbo].[sp_UpdateUen](
    @idUen INT,
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
    @status TINYINT,
    @requierdConfirmation BIT,
    @requierdCFSign BIT,
    @requierdContractSing BIT,
    @requierdLicences BIT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='updateUen';
    DECLARE @trancount INT;
    DECLARE @today DATETIME;
    SELECT @today = GETUTCDATE();
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

        UPDATE UEN SET
        [description]= @description,
        family=@family,
        subFamily=@subFamily,
        SATcode=@satCode,
        SATUM=@satUm,
        iva=@iva,
        lastUpdatedBy=@createdBy,
        lastUpdatedDate=@today,
        marginRate=@marginRate,
        satCodeDescription=@satCodeDescription,
        satUmDescription=@satUmDescription,
        excent=@excent,
        [status]=@status,
        requierdConfirmation= ISNULL(@requierdConfirmation,0),
        requierdCFSign= ISNULL(@requierdCFSign,0),
        requierdContractSing= ISNULL(@requierdContractSing,0),
        requierdLicences= ISNULL(@requierdLicences,0)
        WHERE UENID=@idUen;

        SELECT @idUen AS id
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
