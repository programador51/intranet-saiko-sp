-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 13-12-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_UpdateOdcControlSingF
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
--	2023-13-12		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_UpdateOdcControlSingF')
    BEGIN 

        DROP PROCEDURE sp_UpdateOdcControlSingF;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 13/12/2023
-- Description: sp_UpdateOdcControlSingF - Some Notes
CREATE PROCEDURE sp_UpdateOdcControlSingF(
    @odcSingF NVARCHAR(MAX),
    @updatedBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='updateOdcControlSingF';
    DECLARE @trancount INT;

    DECLARE @notRequierd TABLE (
        id INT NOT NULL IDENTITY(1,1),
        idOdc INT NOT NULL
    );

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
     IF (@trancount=0)
            BEGIN
                COMMIT TRANSACTION @tranName
            END

    IF (@odcSingF IS NOT NULL)
        BEGIN 

            INSERT INTO @notRequierd (
                idOdc
            )
            SELECT
                CAST(value AS INT)
            FROM STRING_SPLIT(@odcSingF, ',')
            WHERE RTRIM(value)<>'' ;

                UPDATE odc SET
                    odc.cfSing= 1,
                    odc.cfSingedDate= GETUTCDATE(),
                    odc.lastUpdatedDate=GETUTCDATE(),
                    odc.lastUpdatedBy= @updatedBy
                FROM Documents AS odc
                LEFT JOIN @notRequierd AS tempTable ON tempTable.idOdc= odc.idDocument

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