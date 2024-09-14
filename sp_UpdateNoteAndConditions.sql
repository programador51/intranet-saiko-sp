-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-13-2022
-- Description: Updates the generic comment and also assigns or removes said comment to the associated document type
-- STORED PROCEDURE NAME:	sp_UpdateNoteAndConditions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idNote: Note id
-- @type: Type of comment (1: Notes | 2: Considerations)
-- @documentTypeIdArrayToAdd: Array of documents type id to add
-- @documentTypeIdArrayToRemove: Array of documents type id to remove
-- @updatedBy: The user who modify the record
-- @currency:Currency code (USD | MXN | NULL)
-- @content:Note or condition message
-- @isDelatable:Indicates if it is delatable
-- @isEditable:Indicates if it is editable
-- @isActive: If is active or not (1: Yes |  2: No)
-- @uen:The UEN id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @tranName: Transaction name
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- @toAddLength: Lenght of documents types to add
-- @toRemoveLength: Lenght of documents types to remove
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-04-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/13/2022
-- Description: sp_UpdateNoteAndConditions - Updates the generic comment and also assigns or removes said comment to the associated document type
CREATE PROCEDURE sp_UpdateNoteAndConditions(
    @idNote INT,
    @type INT,
    @documentTypeIdArrayToAdd NVARCHAR(MAX),
    @documentTypeIdArrayToRemove NVARCHAR(MAX),
    @updatedBy NVARCHAR (30),
    @currency NVARCHAR(3) ,
    @content NVARCHAR (256),
    @isDelatable TINYINT ,
    @isEditable TINYINT ,
    @isActive TINYINT,
    @uen INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(30) ='UpdateGenericNotes';
    DECLARE @ErrorOccurred TINYINT;
    DECLARE @Message NVARCHAR (256);
    DECLARE @CodeNumber INT;


    DECLARE @toAddLength INT;
    DECLARE @toRemoveLength INT;
    BEGIN TRY
        BEGIN TRANSACTION @tranName

        SELECT @toAddLength= LEN(@documentTypeIdArrayToAdd)
        SELECT @toRemoveLength= LEN(@documentTypeIdArrayToRemove)


        UPDATE NoteAndCondition SET 
            content=@content,
            currency=@currency,
            isDelatable=@isDelatable,
            isEditable=@isEditable,
            lastUpdatedBy=@updatedBy,
            lastUpdatedDate= dbo.fn_MexicoLocalTime(GETDATE()),
            [status]=@isActive,
            [type]=@type,
            uen= @uen
        WHERE id=@idNote

        IF @toAddLength > 0
            BEGIN
                INSERT INTO NoteAndConditionToDocType (
                    createdBy,
                    idDocumentType,
                    idNoteAndCondition,
                    lastUpdatedBy,
                    lastUpdatedDate
                )
                    SELECT
                        @updatedBy,
                        value,
                        @idNote,
                        @updatedBy,
                        dbo.fn_MexicoLocalTime(GETDATE())
                    FROM STRING_SPLIT(@documentTypeIdArrayToAdd, ',')
                    WHERE RTRIM(value)<>''
            END
        IF @toRemoveLength > 0
            BEGIN
                DELETE FROM NoteAndConditionToDocType 
                WHERE (idNoteAndCondition= @idNote AND 
                idDocumentType IN (
                    SELECT
                        value
                    FROM STRING_SPLIT(@documentTypeIdArrayToRemove, ',')
                    WHERE RTRIM(value)<>''
                        
                        ))
            END

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
                SET @Message='Registros actualizados correctamente'
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