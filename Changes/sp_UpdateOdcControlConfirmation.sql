-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 13-12-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_UpdateOdcControlConfirmation
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
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_UpdateOdcControlConfirmation')
    BEGIN 

        DROP PROCEDURE sp_UpdateOdcControlConfirmation;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 13/12/2023
-- Description: sp_UpdateOdcControlConfirmation - Some Notes
CREATE PROCEDURE sp_UpdateOdcControlConfirmation(
    @noRequiered NVARCHAR(MAX),
    @confirmation OdcControlConfirm READONLY,
    @updatedBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='updateOdcControlConfirmation';
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
        
        UPDATE odc SET
            odc.confirmed= 1,
            odc.confirmedDate= GETUTCDATE(),
            odc.confirmationNumber = tempTable.confirmNumber,
            odc.lastUpdatedDate=GETUTCDATE(),
            odc.lastUpdatedBy= @updatedBy
        FROM Documents AS odc
        LEFT JOIN @confirmation AS tempTable ON tempTable.idOdc= odc.idDocument
        WHERE 
            odc.confirmed = 0 AND
            odc.confirmedDate IS NULL AND
            odc.idDocument = tempTable.idOdc

    IF (@noRequiered IS NOT NULL)
        BEGIN 

            INSERT INTO @notRequierd (
                idOdc
            )
            SELECT
                CAST(value AS INT)
            FROM STRING_SPLIT(@noRequiered, ',')
            WHERE RTRIM(value)<>'' ;

                UPDATE odc SET
                    odc.confirmed= 2,
                    odc.confirmedDate= GETUTCDATE(),
                    odc.confirmationNumber = 'N/A',
                    odc.lastUpdatedDate=GETUTCDATE(),
                    odc.lastUpdatedBy= @updatedBy
                FROM Documents AS odc
                LEFT JOIN @notRequierd AS tempTable ON tempTable.idOdc= odc.idDocument
                WHERE 
                    odc.confirmed=0 AND
                    odc.confirmedDate IS NULL AND
                    odc.idTypeDocument= 3 AND
                    odc.idDocument= tempTable.idOdc

        END
        SELECT @noRequiered as notRequierd 

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