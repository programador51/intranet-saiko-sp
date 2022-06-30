-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-13-2022
-- Description: Terminates the Todo
-- STORED PROCEDURE NAME:	sp_UpdateTerminateToDo
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @todoId: The Todo id record
-- @executiveId: Executive who terminate the todo
-- @lastUpdatedBy: Last update by
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
--	2022-06-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/13/2022
-- Description: sp_UpdateTerminateToDo - Terminates the Todo
CREATE PROCEDURE sp_UpdateTerminateToDo(
    @todoId INT,
    @executiveId INT,
    @lastUpdatedBy NVARCHAR(30),
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(30)= 'terminateTodo'
    DECLARE @Message NVARCHAR(MAX);
    BEGIN TRY
        BEGIN TRANSACTION @tranName
        UPDATE ToDo SET 
        completedBy=@executiveId,
        finishDate= dbo.fn_MexicoLocalTime(GETDATE()),
        isTaskFinished= 1,
        lastUpdateBy= @lastUpdatedBy,
        lastUpdateDate= dbo.fn_MexicoLocalTime(GETDATE())
        WHERE id= @todoId
        COMMIT TRANSACTION @tranName

    END TRY

    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()

        DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_UpdateTerminateToDo ,@todoId, @executiveId,@lastUpdatedBy';
        DECLARE @wasAnError TINYINT=1;
        DECLARE @mustBeSyncManually TINYINT=1;
        DECLARE @provider TINYINT=4;

        SET @Message= ERROR_MESSAGE();
        IF (XACT_STATE()= -1)
            BEGIN
                ROLLBACK TRANSACTION @tranName
            END
        IF (XACT_STATE()=1)
            BEGIN
                COMMIT TRANSACTION @tranName
            END

        IF @@TRANCOUNT > 0  
            BEGIN
                ROLLBACK TRANSACTION @tranName;   
            END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog @lastUpdatedBy,@infoSended,@Message,@Message,@wasAnError,@mustBeSyncManually,@provider;
    END CATCH
    

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------