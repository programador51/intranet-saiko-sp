-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-13-2022
-- Description: Updates the todo
-- STORED PROCEDURE NAME:	sp_UpdateToDo
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
--	2022-06-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/13/2022
-- Description: sp_UpdateToDo - Updates the todo
CREATE PROCEDURE sp_UpdateToDo(
    @toDoId INT,
    @atentionDate DATETIME,
    @lastUpdateBy NVARCHAR(30),
    @executiveWhoCreatedId INT,
    @idSection INT,
    @idTag INT,
    @reminderDate DATETIME,
    @tagDescription NVARCHAR(30),
    @title NVARCHAR(128),
    @todoNote NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(30)= 'editTodo'
    DECLARE @Message NVARCHAR(MAX);

    BEGIN TRY

        BEGIN TRANSACTION @tranName
        IF (@idTag=-1)
            BEGIN
            -- it measn the tag is new
            EXEC @idTag= sp_AddTags @lastUpdateBy,@tagDescription,@executiveWhoCreatedId, @idSection
            END

        IF (@idSection=4)
            BEGIN
                UPDATE ToDo SET 
                idTag=@idTag,
                title=@title,
                tagDescription= @tagDescription,
                reminderDate= @reminderDate,
                atentionDate= @atentionDate,
                toDoNote= @todoNote,
                lastUpdateBy= @lastUpdateBy,
                lastUpdateDate= dbo.fn_MexicoLocalTime(GETDATE())

                WHERE id= @toDoId
            END
        ELSE
            BEGIN
                UPDATE ToDo SET 
                    idTag=@idTag,
                    tagDescription= @tagDescription,
                    reminderDate= @reminderDate,
                    atentionDate= @atentionDate,
                    toDoNote= @todoNote,
                    lastUpdateBy= @lastUpdateBy,
                    lastUpdateDate= dbo.fn_MexicoLocalTime(GETDATE())

                    WHERE id= @toDoId
            END
        

        COMMIT TRANSACTION @tranName

    END TRY

    BEGIN CATCH

    DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()

        DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_UpdateToDo ,@atentionDate,
            @lastUpdateBy,
            @idTag,
            @reminderDate,
            @tagDescription,
            @todoNote';
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
        EXEC sp_AddLog @lastUpdateBy,@infoSended,@Message,@Message,@wasAnError,@mustBeSyncManually,@provider;
    END CATCH

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------