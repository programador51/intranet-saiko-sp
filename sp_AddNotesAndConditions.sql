-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-12-2022
-- Description: Create the notes and conditions for the selected documents
-- STORED PROCEDURE NAME:	sp_AddNotesAndConditions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @type: Type of comment (1: Notes | 2: Considerations)
-- @documentTypeIdArray: Array of documents type id
-- @createdBy: The user who create the record
-- @currency: Currency code (USD | MXN | NULL)
-- @content: Note or condition message
-- @isDelatable: Indicates if it is delatable
-- @isEditable: Indicates if it is editable
-- @uen: The UEN id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @tranName: Transaction name
-- @idNoteCondition: The note/condition id
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
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
--	2022-04-12		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/12/2022
-- Description: sp_AddNotesAndConditions - Create the notes and conditions for the selected documents
CREATE PROCEDURE sp_AddNotesAndConditions(
    @type INT,
    @documentTypeIdArray NVARCHAR(MAX),
    @createdBy NVARCHAR (30),
    @currency NVARCHAR(3),
    @content NVARCHAR (256),
    @isDelatable TINYINT,
    @isEditable TINYINT,
    @isActive TINYINT,
    @uen INT 
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(30) ='GenericNotes';
    DECLARE @idNoteCondition INT;

    DECLARE @ErrorOccurred TINYINT;
    DECLARE @Message NVARCHAR (256);
    DECLARE @CodeNumber INT;

    BEGIN TRY
        BEGIN TRANSACTION @tranName
            INSERT INTO NoteAndCondition (
                content,
                createdBy,
                currency,
                isDelatable,
                isEditable,
                lastUpdatedBy,
                [type],
                uen
            )
            VALUES (
                @content,
                @createdBy,
                @currency,
                @isDelatable,
                @isEditable,
                @createdBy,
                @type,
                @uen
            )

        SELECT @idNoteCondition= SCOPE_IDENTITY()

        INSERT INTO NoteAndConditionToDocType (
            createdBy,
            idDocumentType,
            idNoteAndCondition,
            lastUpdatedBy
        )
            SELECT
                @createdBy,
                value,
                @idNoteCondition,
                @createdBy
            FROM STRING_SPLIT(@documentTypeIdArray, ',')
            WHERE RTRIM(value)<>''

        IF @@ERROR <>0
            BEGIN
                SET @ErrorOccurred= 1 -- Significa que fallo
                SELECT @Message= text FROM sys.messages WHERE message_id=@@ERROR
                SET @CodeNumber= @@ERROR
                ROLLBACK TRANSACTION @tranName
            END
        ELSE
            BEGIN
                SET @ErrorOccurred= 0
                SET @Message='Registros insertados correctamente'
                SET @CodeNumber= 200
                COMMIT TRANSACTION @tranName
            END

        SELECT @ErrorOccurred AS ErrorOccurred, @Message AS [Message], @CodeNumber AS CodeNumber
    END TRY

    BEGIN CATCH
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
                ROLLBACK TRANSACTION;   
            END
        SELECT 
            1 AS ErrorOccurred, 
            'Problemas con la Base de datos, no se pudo insertar los registros' AS [Message],
            ERROR_NUMBER() AS CodeNumber

    END CATCH

END