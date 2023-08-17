-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-13-2023
-- Description: Upload the movment ingress concepts for setup propourse only
-- STORED PROCEDURE NAME:	sp_UploadIngressConcepts
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
--	2023-06-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/13/2023
-- Description: sp_UploadIngressConcepts - Upload the movment ingress concepts for setup propourse only
CREATE PROCEDURE sp_UploadIngressConcepts(
    @tempConcepts MovementConcepts READONLY,
    @createdBy  NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR = 'uploadIngressConcepts';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;

    DECLARE @currency INT = 1
    DECLARE @default BIT = 0;

    BEGIN TRY
        IF (@trancount= 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
        ELSE
            BEGIN
                SAVE TRANSACTION @tranName
            END

        INSERT INTO InformativeIncomes (
            createdBy,
            createdDate,
            currency,
            [description],
            idTypeInformativeIncomes,
            lastUpadatedDate,
            lastUpdatedBy,
            [status],
            defaultToDocument,
            isForDocuments
        )
        SELECT 
            @createdBy,
            GETUTCDATE(),
            @currency,
            [description],
            idType,
            GETUTCDATE(),
            @createdBy,
            [status],
            @default,
            @default
            
        FROM @tempConcepts
        WHERE idConcept IS NULL

        UPDATE infoIngress SET
            infoIngress.[description]= tempConcept.[description],
            infoIngress.idTypeInformativeIncomes= tempConcept.idType,
            infoIngress.[status]=tempConcept.[status]
        FROM InformativeIncomes AS infoIngress
        INNER JOIN @tempConcepts  AS tempConcept ON tempConcept.idConcept= infoIngress.id

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