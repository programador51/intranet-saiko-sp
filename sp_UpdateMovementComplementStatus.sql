-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-07-2022
-- Description: Update the movement complement status
-- STORED PROCEDURE NAME:	sp_UpdateMovementComplementStatus
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idMovement: Movement id
-- @idStatus: Complement status id
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
--	2022-09-07		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/07/2022
-- Description: sp_UpdateMovementComplementStatus - Update the movement complement status
CREATE PROCEDURE sp_UpdateMovementComplementStatus(
    @idMovement INT,
    @idStatus INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='updateMovComplentStatus';
    BEGIN TRY
        BEGIN TRANSACTION @tranName
        UPDATE Movements SET
            idPaymentPluginStatus=@idStatus
        WHERE MovementID=@idMovement;
        COMMIT TRANSACTION @tranName;
    END TRY
    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
            DECLARE @State   SMALLINT = ERROR_SEVERITY()
            DECLARE @Message   NVARCHAR(MAX)

            DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de actualizar el movimiento
            SP sp_UpdateMovementComplementStatus
                    @idMovment,@idStatus
                    ';
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