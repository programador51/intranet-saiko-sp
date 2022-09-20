-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-10-2022
-- Description: Upates the movement status to consiliate the moemvent
-- STORED PROCEDURE NAME:	sp_UpdateMovementConsilation
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idMovement: Movement id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @idStatus: Id of the status to vaalidate ('Asociado');
-- @idNewStatus: Id of the new status ('Consiliado');
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
--	2022-08-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/10/2022
-- Description: sp_UpdateMovementConsilation - Upates the movement status to consiliate the moemvent
CREATE PROCEDURE sp_UpdateMovementConsilation(
    @idMovement NVARCHAR(MAX),
    @itIsToConciliate BIT,
    @lastUpdateBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='consiliateMovement';
    DECLARE @idStatus INT;
    DECLARE @idNewStatus INT;

    IF (@itIsToConciliate=1)
        BEGIN
            -- CONSILIARA EL MOVIMIENTO
            SET @idStatus= 2
            SET @idNewStatus=3
        END
    ELSE
        -- CANCELARA LA CONSILIACION
        BEGIN
            SET @idStatus= 3
            SET @idNewStatus=2
        END

    
    BEGIN TRY
        BEGIN TRANSACTION @tranName;
        IF EXISTS (SELECT * FROM Movements WHERE MovementID IN(@idMovement) AND [status]=@idStatus)
            BEGIN
                UPDATE Movements SET 
                    [status]= @idNewStatus,
                    lastUpdatedDate= GETUTCDATE(),
                    lastUpdatedBy= @lastUpdateBy

                WHERE MovementID IN(@idMovement) AND [status]=@idStatus
                COMMIT TRANSACTION @tranName
                RETURN 'Succes updated'
            END
        ELSE
            BEGIN
                PRINT('No tiene')
                COMMIT TRANSACTION @tranName
                RETURN 'This updated is not allowed'
            END

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