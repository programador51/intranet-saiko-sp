-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 01-16-2024
-- Description: Add cfdis cancellation history
-- STORED PROCEDURE NAME:	sp_AddInvoiceHistoryCancelation
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-01-16		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_AddInvoiceHistoryCancelation')
    BEGIN 

        DROP PROCEDURE sp_AddInvoiceHistoryCancelation;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 01/16/2024
-- Description: sp_AddInvoiceHistoryCancelation - Add cfdis cancellation history
CREATE PROCEDURE sp_AddInvoiceHistoryCancelation(
        @idInvoice  INT,
        @idUser  INT,
        @documentType  NVARCHAR(256),
        @createdBy  NVARCHAR(50)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(50)='AddInvoiceHistoryCancelation';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;
    DECLARE @updatedBy NVARCHAR(50)=@createdBy;

    BEGIN TRY
        IF (@trancount= 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
        ELSE
            BEGIN
                SAVE TRANSACTION @tranName
            END

        INSERT INTO InvoiceCancellationHistory (
            idInvoice,
            idUser,
            documentType,
            createdBy,
            updatedBy
        )VALUES(
            @idInvoice,
            @idUser,
            @documentType,
            @createdBy,
            @updatedBy
        )

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