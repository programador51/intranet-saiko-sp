-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-02-2023
-- Description: Add a new UEN
-- STORED PROCEDURE NAME:	sp_AddUen
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
--	2023-08-02		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/02/2023
-- Description: sp_AddUen - Add a new UEN
CREATE PROCEDURE sp_AddUen(
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
    @excent TINYINT
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
            excent
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
            @excent
        )
        SELECT SCOPE_IDENTITY() AS id
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