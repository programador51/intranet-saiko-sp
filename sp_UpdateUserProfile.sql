-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-08-2022
-- Description: Updates the user profile
-- STORED PROCEDURE NAME:	sp_UpdateUserProfile
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @birthDay
-- @birthMonth
-- @birthYear
-- @email
-- @firstName
-- @idUser
-- @ladaMovil
-- @lastName1
-- @lastName2
-- @middleName
-- @movil
-- @profilePicture
-- @profilePictureScale
-- @profilePictureX
-- @profilePictureY
-- @reminderEmail
-- @reminderSms
-- @reminderWhatsapp
-- @userName
-- @lastUpdatedBy
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
--	2022-07-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/08/2022
-- Description: sp_UpdateUserProfile - Updates the user profile
CREATE PROCEDURE sp_UpdateUserProfile(
    @birthDay TINYINT,
    @birthMonth TINYINT,
    @birthYear CHAR(4),
    @email NVARCHAR(50),
    @firstName NVARCHAR(30),
    @idUser INT,
    @ladaMovil NVARCHAR(10),
    @lastName1 NVARCHAR(30),
    @lastName2 NVARCHAR(30),
    @middleName NVARCHAR(30),
    @movil NVARCHAR(30),
    @profilePicture NVARCHAR(MAX),
    @profilePictureScale DECIMAL(4,2),
    @profilePictureX DECIMAL(20,19),
    @profilePictureY DECIMAL(20,19),
    @reminderEmail BIT,
    @reminderSms BIT,
    @reminderWhatsapp BIT,
    @userName NVARCHAR(50),
    @lastUpdatedBy NVARCHAR(30)
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(30)='updateProfile'
    BEGIN TRY
        BEGIN TRANSACTION @tranName
        UPDATE Users SET
        birthDay = @birthDay,
        birthMonth = @birthMonth,
        birthYear = @birthYear,
        firstName = @firstName,
        ladaMovil = @ladaMovil,
        lastName1 = @lastName1,
        lastName2 = @lastName2,
        middleName = @middleName,
        userName = @userName,
        email = @email,
        movil = @movil,
        profilePicture = CASE WHEN @profilePicture IS NULL THEN profilePicture ELSE @profilePicture END,
        profilePictureScale = @profilePictureScale,
        profilePictureX = @profilePictureX,
        profilePictureY = @profilePictureY,
        reminderEmail = @reminderEmail,
        reminderSms = @reminderSms,
        reminderWhatsapp = @reminderWhatsapp,
        lastUpdatedDate= GETUTCDATE(),
        lastUpdatedBy= @lastUpdatedBy
        WHERE userID = @idUser;
        COMMIT TRANSACTION @tranName
    END TRY
    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()
        DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_UpdateUserProfile @birthDay
            @birthMonth
            @birthYear
            @email
            @firstName
            @idUser
            @ladaMovil
            @lastName1
            @lastName2
            @middleName
            @movil
            @profilePicture
            @profilePictureScale
            @profilePictureX
            @profilePictureY
            @reminderEmail
            @reminderSms
            @reminderWhatsapp
            @userName';
        DECLARE @wasAnError TINYINT=1;
        DECLARE @mustBeSyncManually TINYINT=1;
        DECLARE @provider TINYINT=4;
        DECLARE @Message NVARCHAR(MAX);

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