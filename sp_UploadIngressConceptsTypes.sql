-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-13-2023
-- Description: Upload the movment ingress concepts types for setup propourse only
-- STORED PROCEDURE NAME:	sp_UploadIngressConceptsTypes
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
-- Description: sp_UploadIngressConceptsTypes - Upload the movment ingress concepts types for setup propourse only
CREATE PROCEDURE sp_UploadIngressConceptsTypes(
    @tempTypes MovementConceptsTypes READONLY,
    @createdBy  NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR = 'uploadIngressConceptsTypes';
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

        INSERT INTO TypeInformativeIncomes (
            createdBy,
            createdDate,
            [description],
            lastUpadatedDate,
            lastUpdatedBy,
            [status]
        )
        SELECT 
            @createdBy,
            GETUTCDATE(),
            [description],
            GETUTCDATE(),
            @createdBy,
            [status]
            
        FROM @tempTypes
        WHERE idType IS NULL

        UPDATE infoExpenses SET
            infoExpenses.[description]= tempConcept.[description],
            infoExpenses.[status]=tempConcept.[status]
        FROM TypeInformativeIncomes AS infoExpenses
        INNER JOIN @tempTypes  AS tempConcept ON tempConcept.idType= infoExpenses.id

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