-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-13-2022
-- Description: Adds a ToDo
-- STORED PROCEDURE NAME:	sp_AddToDo
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
--	2022-06-15		Adrian Alardin   			1.0.0.1			Added customer id property	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/10/2022
-- Description: sp_AddToDo - Adds a ToDo
CREATE PROCEDURE sp_AddToDo(
    @atentionDate DATETIME,
    @createdBy NVARCHAR(30),
    @executiveWhoCreatedId INT,
    @fromId INT,
    @idSection INT,
    @idTag INT,
    @reminderDate INT,
    @tagDescription INT,
    @title NVARCHAR(128),
    @todoNote NVARCHAR(256),
    @customerId INT,
    @parent INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(30)= 'addTodo'
    DECLARE @Message NVARCHAR(MAX);

    BEGIN TRY

        BEGIN TRANSACTION @tranName

        IF (@idTag=-1)
            BEGIN
            -- it measn the tag is new
            EXEC @idTag= sp_AddTags @createdBy,@tagDescription,@executiveWhoCreatedId, @idSection
            END
        IF (@parent IS NULL)
            BEGIN
                INSERT INTO ToDo (
                    atentionDate,
                    createdBy,
                    executiveWhoCreatedId,
                    fromId,
                    idSection,
                    idTag,
                    lastUpdateBy,
                    reminderDate,
                    tagDescription,
                    title,
                    toDoNote,
                    customerId
                    )
                VALUES (
                    @atentionDate,
                    @createdBy,
                    @executiveWhoCreatedId,
                    @fromId,
                    @idSection,
                    @idTag,
                    @createdBy,
                    @reminderDate,
                    @tagDescription,
                    @title,
                    @todoNote,
                    @customerId
                )
            END
        ELSE 
            BEGIN
                INSERT INTO ToDo (
                        atentionDate,
                        createdBy,
                        executiveWhoCreatedId,
                        fromId,
                        idSection,
                        idTag,
                        lastUpdateBy,
                        reminderDate,
                        tagDescription,
                        title,
                        toDoNote,
                        customerId,
                        parent
                        )
                    VALUES (
                        @atentionDate,
                        @createdBy,
                        @executiveWhoCreatedId,
                        @fromId,
                        @idSection,
                        @idTag,
                        @createdBy,
                        @reminderDate,
                        @tagDescription,
                        @title,
                        @todoNote,
                        @customerId,
                        @parent
                    )
            END

    END TRY

    BEGIN CATCH

        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()

        DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar en orden para el SP sp_CancelQuoteDocument',@atentionDate,
            @createdBy,
            @executiveWhoCreatedId,
            @fromId,
            @idSection,
            @idTag,
            @reminderDate,
            @tagDescription,
            @title,
            @todoNote);
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
        EXEC sp_AddLog @createdBy,@infoSended,@Message,@Message,@wasAnError,@mustBeSyncManually,@provider;
    END CATCH

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------