-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-16-2022
-- Description: Updates the ODC when it is sended by email
-- STORED PROCEDURE NAME:	sp_UpdateOdcSendedEmail
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
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
--	2022-08-16		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/16/2022
-- Description: sp_UpdateOdcSendedEmail - Updates the ODC when it is sended by email
CREATE PROCEDURE sp_UpdateOdcSendedEmail(
    @documentStatusId INT,
    @documentId INT,
    @modifyBy NVARCHAR (30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(30)= 'UpdateOdcEmail';

    BEGIN TRY
        BEGIN TRANSACTION @tranName;
        UPDATE Documents SET 
            idStatus=@documentStatusId,
            lastUpdatedDate=GETUTCDATE(),
            lastUpdatedBy=@modifyBy,
            sentDate= GETUTCDATE()
        WHERE
            idDocument = @documentId
        
        COMMIT TRANSACTION @tranName
    END TRY

    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()
        DECLARE @Message   NVARCHAR(MAX)

        DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_UpdateOdcSendedEmail,@documentStatusId,@documentId,@modifyBy';
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