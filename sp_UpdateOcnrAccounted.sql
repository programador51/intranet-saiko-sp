-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-20-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_UpdateOcnrAccounted
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
--	2023-10-20		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 10/20/2023
-- Description: sp_UpdateOcnrAccounted - Some Notes
ALTER PROCEDURE sp_UpdateOcnrAccounted(
    @accounted NVARCHAR(MAX),
    @deaccounted NVARCHAR(MAX),
    @idSummary INT,
    @updatedBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='updateOcnrAccounted';
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

        IF(@accounted IS NOT NULL)
            BEGIN
                UPDATE DetailOCNR SET
                    [status]=1
                WHERE
                    idSummary= @idSummary AND
                    id IN (
                        SELECT
                            CAST(value AS INT)
                        FROM STRING_SPLIT(@accounted, ',')
                        WHERE RTRIM(value)<>''
                    )
            END
        IF(@deaccounted IS NOT NULL)
            BEGIN
                UPDATE DetailOCNR SET
                        [status]=0
                    WHERE
                        idSummary= @idSummary AND
                        id IN (
                            SELECT
                                CAST(value AS INT)
                            FROM STRING_SPLIT(@deaccounted, ',')
                            WHERE RTRIM(value)<>''
                        )
            END
        IF(@deaccounted IS NOT NULL AND @accounted IS NOT NULL)
        BEGIN
            DECLARE @subTotalMXN DECIMAL(14,4)
            DECLARE @subTotalUSD DECIMAL(14,4)
            SELECT 
                @subTotalMXN = SUM(odc.amountToPay)
            FROM DetailOCNR AS detailOcnr
            LEFT JOIN Documents AS odc ON odc.idDocument=detailOcnr.idOdc
            WHERE 
                detailOcnr.idSummary=@idSummary AND
                detailOcnr.[status]=1 AND
                odc.idCurrency=1
            SELECT 
                @subTotalUSD = SUM(odc.amountToPay)
            FROM DetailOCNR AS detailOcnr
            LEFT JOIN Documents AS odc ON odc.idDocument=detailOcnr.idOdc
            WHERE 
                detailOcnr.idSummary=@idSummary AND
                detailOcnr.[status]=1 AND
                odc.idCurrency=2
            UPDATE SummaryOCNR SET 
                mxnTotal=@subTotalMXN,
                usdTotal=@subTotalUSD,
                updatedBy=@updatedBy,
                updatedDate=GETUTCDATE()
            WHERE 
                id=@idSummary
        END
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