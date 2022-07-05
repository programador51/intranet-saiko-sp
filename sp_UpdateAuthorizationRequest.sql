-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-05-2022
-- Description: Updates the authorization request (acepted or rejected)
-- STORED PROCEDURE NAME:	sp_UpdateAuthorizationRequest
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @hasItBeenAttended
-- @lasUpdateBy
-- @lastUpdatedDate
-- @limitBillingTime
-- @partialitiesAllowed
-- @tcAllowed
-- @wasAccepted
-- @idAuthorization
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
--	2022-07-05		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/05/2022
-- Description: sp_UpdateAuthorizationRequest - Updates the authorization request (acepted or rejected)
CREATE PROCEDURE sp_UpdateAuthorizationRequest(
    @hasItBeenAttended BIT,
    @lasUpdateBy NVARCHAR(30),
    @lastUpdatedDate DATETIME,
    @limitBillingTime DATETIME,
    @partialitiesAllowed INT,
    @tcAllowed DECIMAL(14,2),
    @wasAccepted BIT,
    @idAuthorization INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(30)= 'updateAuthorization';


    BEGIN TRY
        BEGIN TRANSACTION @tranName
        UPDATE InvoiceAuthorizations SET 
            hasItBeenAttended= @hasItBeenAttended,
            lasUpdateBy= @lasUpdateBy,
            lastUpdatedDate= @lastUpdatedDate,
            limitBillingTime= @limitBillingTime,
            partialitiesAllowed= @partialitiesAllowed,
            tcAllowed= @tcAllowed,
            wasAccepted= @wasAccepted
        WHERE id= @idAuthorization
        COMMIT TRANSACTION @tranName
    END TRY

    BEGIN CATCH
        DECLARE @Message NVARCHAR(MAX);
                DECLARE @Severity  INT= ERROR_SEVERITY()
                DECLARE @State   SMALLINT = ERROR_SEVERITY()

                DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar para actualizar la autorización',
                    @hasItBeenAttended,
                    @lasUpdateBy,
                    @lastUpdatedDate,
                    @limitBillingTime,
                    @partialitiesAllowed,
                    @tcAllowed,
                    @wasAccepted,
                    @idAuthorization
                );
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
                EXEC sp_AddLog @lasUpdateBy,@infoSended,@Message,@Message,@wasAnError,@mustBeSyncManually,@provider;
    END CATCH

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------