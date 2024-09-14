-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-22-2022
-- Description: Creates the ToDo for the documest which the reminder date is less than today
-- STORED PROCEDURE NAME:	sp_RobotCreateDocumentsToDos
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
--	2022-06-22		Adrian Alardin   			1.0.0.0			Initial Revision	
--	2022-06-23		Adrian Alardin   			1.0.0.1			The documents status was missing, so we added	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/22/2022
-- Description: sp_RobotCreateDocumentsToDos - Creates the ToDo for the documest which the reminder date is less than today
CREATE PROCEDURE sp_RobotCreateDocumentsToDos AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @todayDate DATETIME = dbo.fn_MexicoLocalTime (GETDATE());

    DECLARE @tranName NVARCHAR(30) ='documentsRemiders'

    BEGIN TRY
        BEGIN TRANSACTION @tranName

        INSERT INTO ToDo (
                            atentionDate,
                            createdBy,
                            executiveWhoCreatedId,
                            executiveWhoAttendsId,
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
                    SELECT 
                        @todayDate, -- AttentionDate
                        'SISTEMA', -- createdBy
                        document.idExecutive, -- executiveWhoCreatedId
                        document.idExecutive, -- executiveWhoAttendsId
                        document.idDocument, -- fromId
                        1, -- idSection
                        -99, --idTag
                        'SISTEMA',-- lastUpdateBy
                        @todayDate,-- reminderDate
                        docType.[description],-- tagDescription
                        CONCAT (docType.[description], ' ',FORMAT(document.documentNumber,'0000000')),-- title
                        CASE 
                            WHEN DATEDIFF(DAY,reminderDate,@todayDate) > 1 
                                THEN CONCAT (DATEDIFF(DAY,reminderDate,@todayDate),
                                    ' recordatorio para atender ',
                                    CASE WHEN document.idTypeDocument=2 THEN 'el 'ELSE 'la ' END,
                                    'No. ',FORMAT(document.documentNumber,'0000000'), ' del ', customerType.[description], ' ', customer.socialReason  )
                                ELSE CONCAT ('Recordatorio para atender ',
                                    CASE WHEN document.idTypeDocument=2 THEN 'el 'ELSE 'la ' END,
                                    'No. ',FORMAT(document.documentNumber,'0000000'), ' del ', customerType.[description], ' ', customer.socialReason  )
                        END ,-- toDoNote
                        document.idCustomer, --customerId,
                        CONCAT('id-document- ',document.idDocument)--parent
                    FROM Documents AS document
                    LEFT JOIN DocumentTypes AS docType ON docType.documentTypeID=document.idTypeDocument
                    LEFT JOIN Customers AS customer ON customer.customerID= document.idCustomer
                    LEFT JOIN CustomerTypes AS customerType ON customerType.customerTypeID= customer.customerType
                    WHERE 
                        reminderDate <= @todayDate AND 
                        (document.idTypeDocument =1 OR document.idTypeDocument=2 OR document.idTypeDocument=3 ) AND
                        (document.idStatus=1 OR document.idStatus= 5 OR document.idStatus=9)

                COMMIT TRANSACTION @tranName
    END TRY

    BEGIN CATCH
    DECLARE @Severity  INT= ERROR_SEVERITY()
            DECLARE @State   SMALLINT = ERROR_SEVERITY()
            DECLARE @Message   NVARCHAR(MAX)

            DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_CancelQuoteDocument,,@atentionDate,
                @createdBy,
                @executiveWhoCreatedId,
                @fromId,
                @idSection,
                @idTag,
                @reminderDate,
                @tagDescription,
                @title,
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
            EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;
    END CATCH

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------