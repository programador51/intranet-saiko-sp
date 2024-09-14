-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-24-2022
-- Description: create a birthday notice for system executives
-- STORED PROCEDURE NAME:	RobotHappyBirthdayExecutive
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
--	2022-06-24		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/24/2022
-- Description: RobotHappyBirthdayExecutive - create a birthday notice for system executives
CREATE PROCEDURE RobotHappyBirthdayExecutive AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(30) ='documentsRemiders'

    BEGIN TRY
    BEGIN TRANSACTION @tranName
        DECLARE @todayDate DATETIME= dbo.fn_MexicoLocalTime(GETDATE());
        DECLARE @paramMessage NVARCHAR(1000);

        SELECT  @paramMessage=[value] FROM Parameters WHERE parameter=36
        
        INSERT INTO Advertisements (
            registrationUserID,
            registrationDate,
            startDate,
            endDate,
            [message],
            messageTypeID,
            [status],
            createdBy,
            createdDate,
            lastUpdatedBy,
            lastUpadatedDate
        ) 

            SELECT
                20,-- registrationUserID
                dbo.fn_MexicoLocalTime(GETDATE()) ,-- registrationDate
                dbo.fn_MexicoLocalTime(GETDATE()) ,-- startDate
                dbo.fn_MexicoLocalTime(GETDATE()) ,-- endDate
                CASE 
                    WHEN middleName IS NULL THEN CONCAT(firstName, ' ', lastName1, ' ', lastName2, ' ',@paramMessage)
                    ELSE CONCAT(firstName, ' ',middleName,' ', lastName1, ' ', lastName2, ' ',@paramMessage)
                END,-- message
                2, -- messageTypeID
                1,--status
                'SISTEMA',--createdBy
                dbo.fn_MexicoLocalTime(GETDATE()),--createdDate
                'SISTEMA',--lastUpdatedBy
                dbo.fn_MexicoLocalTime(GETDATE())--lastUpadatedDate
            FROM Users
            WHERE birthDay= DAY (@todayDate) AND birthMonth = MONTH(@todayDate)

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