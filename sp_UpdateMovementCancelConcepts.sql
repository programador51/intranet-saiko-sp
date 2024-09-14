-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-28-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_UpdateMovementCancelConcepts
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
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
--	2023-03-28		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/28/2023
-- Description: sp_UpdateMovementCancelConcepts - Some Notes
-- DROP PROCEDURE sp_UpdateMovementCancelConcepts;
CREATE PROCEDURE sp_UpdateMovementCancelConcepts(
    @idMovement INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR = 'cancelMovementConcepts';
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


        DECLARE @isCancelable BIT;
        SELECT @isCancelable=
            CASE WHEN COUNT(*)>0 THEN 0
            ELSE 1
            END
        FROM Complements WHERE idMovement=@idMovement;



        IF @isCancelable=1
            BEGIN 
                UPDATE Movements SET [status]=4 WHERE MovementID=@idMovement;
                UPDATE ConceptAssociation SET [status]=0 WHERE idMovement=@idMovement;
            END
        ELSE    
            BEGIN
                RAISERROR(N'El movimiento no es cancelable',10,1)
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
      IF OBJECT_ID(N'tempdb..#NewItemsId') IS NOT NULL 
        BEGIN
        DROP TABLE #NewItemsId
    END
    IF OBJECT_ID(N'tempdb..#itemsToTheDocument') IS NOT NULL 
        BEGIN
        DROP TABLE #itemsToTheDocument
    END
    IF OBJECT_ID(N'tempdb..#itemsToTheCatalog') IS NOT NULL 
        BEGIN
        DROP TABLE #itemsToTheCatalog
    END

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------