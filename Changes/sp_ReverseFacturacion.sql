-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-15-2024
-- Description: Delete all the information related to a legal document
-- STORED PROCEDURE NAME:	sp_ReverseFacturacion
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @uuid: The UUID from the legal document
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
--	2024-08-15		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_ReverseFacturacion')
    BEGIN 

        DROP PROCEDURE sp_ReverseFacturacion;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/15/2024
-- Description: sp_ReverseFacturacion - delete all the information related to a legal document
CREATE PROCEDURE sp_ReverseFacturacion(
    @uuid NVARCHAR(MAX)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50) = 'reverseFacturacion';
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
        IF (@trancount = 0)
                BEGIN
                    COMMIT TRANSACTION @tranName;
                END

        
        DELETE FROM LegalDocuments
        WHERE 
            uuid = @uuid
            AND idTypeLegalDocument = 2;

        DELETE FROM InvoiceTaxas
        WHERE 
            uuidInvoce = @uuid;

        DELETE FROM CxCTaxas
        WHERE 
            uuidInvoce = @uuid;
        
        DELETE FROM Documents 
        WHERE 
            uuid = @uuid
            AND idTypeDocument = 5;

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