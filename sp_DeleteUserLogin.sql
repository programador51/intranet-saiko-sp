-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-11-2022
-- Description: Sing out the current user from all devices
-- STORED PROCEDURE NAME:	sp_DeleteUserLogin
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idExecutive: the executive id
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
--	2022-07-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/11/2022
-- Description: sp_DeleteUserLogin - Sing out the current user from all devices
CREATE PROCEDURE sp_DeleteUserLogin(
    @idExecutive INT,
    @lastUpdatedBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(30)= 'singOut';
    BEGIN TRY
        BEGIN TRANSACTION @tranName
        DELETE FROM RefreshTokens 
        WHERE [user]=@idExecutive
        COMMIT TRANSACTION @tranName
    END TRY
    BEGIN CATCH
    DECLARE @Severity  INT= ERROR_SEVERITY()
            DECLARE @State   SMALLINT = ERROR_SEVERITY()
            DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_UpdateUserProfile @idExecutive';
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