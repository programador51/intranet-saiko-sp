-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-10-2024
-- Description: Update a position
-- STORED PROCEDURE NAME:	sp_UpdatePosition
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @id INT - Id
-- @percentageOfCompletion DECIMAL(5,2) - Percentage of completion
-- @laborCost DECIMAL(20,4) - Labor cost
-- @laborSell DECIMAL(20,4) - Labor sell
-- @ocCustomer VARCHAR(256) - OC customer
-- @updatedBy VARCHAR(256) - Updated by
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @updateDate DATETIME - Update date
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-06-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_UpdatePosition')
    BEGIN 

        DROP PROCEDURE sp_UpdatePosition;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/10/2024
-- Description: sp_UpdatePosition - Update a position
CREATE PROCEDURE sp_UpdatePosition(
    @id INT,
    @percentageOfCompletion DECIMAL(5,2),
    @laborCost DECIMAL(20,4),
    @laborSell DECIMAL(20,4),
    @ocCustomer VARCHAR(256),
    @updatedBy VARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @updateDate DATETIME = GETUTCDATE();
    DECLARE @tranName NVARCHAR(50)='updatePosition';
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

        UPDATE PositionsProyects SET 
            percentageOfCompletion = @percentageOfCompletion,
            laborCost = @laborCost,
            laborSell = @laborSell,
            ocCustomer = @ocCustomer,
            updatedBy = @updatedBy,
            updatedDate = @updateDate
        WHERE id = @id;

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