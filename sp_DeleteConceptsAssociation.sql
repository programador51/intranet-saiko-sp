-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-08-2023
-- Description: Cancel the oconcept association
-- STORED PROCEDURE NAME:	sp_DeleteConceptsAssociation
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idMovemenet
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
--	2023-03-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/08/2023
-- Description: sp_DeleteConceptsAssociation - Cancel the oconcept association
CREATE PROCEDURE sp_DeleteConceptsAssociation(
    @idMovement INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR = 'cancelConceptAssociation';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;

    BEGIN TRY
        -- ConceptAssociation

         IF (@trancount= 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
                ELSE
                    BEGIN
                SAVE TRANSACTION @tranName
            END

        UPDATE ConceptAssociation SET [status]=0 WHERE idMovement=@idMovement


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