-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-19-2023
-- Description: Cancel the egress for concepts
-- STORED PROCEDURE NAME:	sp_UpdateCancelEgressConcept
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idMovement: The movement id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- amount: The movement amount,
-- idBankAccount: The id of the bank account
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2023-04-19		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/19/2023
-- Description: sp_UpdateCancelEgressConcept - Cancel the egress for concepts
CREATE PROCEDURE sp_UpdateCancelEgressConcept(
    @idMovement INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='cancelEgressConcept';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;
    BEGIN TRY

        IF (@trancount= 0)
                BEGIN
                    BEGIN TRANSACTION @tranName;
                END
            ELSE
                BEGIN
                    SAVE TRANSACTION @tranName
                END
        DECLARE @idStatus INT; -- Movement id status. the movemnet status must be '[2] Activo'  OR '[5] En proceso'
        DECLARE @amount DECIMAL(14,2)
        DECLARE @idBankAccount INT
        SELECT 
            @idStatus=[status],
            @amount= amount,
            @idBankAccount=bankAccount

         FROM Movements WHERE MovementID=@idMovement;

         IF(@idStatus=2 OR @idStatus=5)
            BEGIN
                UPDATE Movements SET [status]=4 WHERE MovementID=@idMovement;
                UPDATE NonDeductibleAssociations SET [status]=0 WHERE idMovement=@idMovement;
                EXEC sp_UpdateBankAccountBalance @amount,@idBankAccount;
            END
        ELSE
            BEGIN
            ;THROW 51000, 'El movimiento no es cancelable revise que el estatus sea el adecuado',1;
            END


    END TRY
    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()
        DECLARE @Message   NVARCHAR(MAX)
        DECLARE @xstate INT= XACT_STATE();

        DECLARE @infoSended NVARCHAR(MAX)= 'Sin informacion por el momento';
        DECLARE @wasAnError TINYINT=1;
        DECLARE @mustBeSyncManually TINYINT=1;
        DECLARE @provider TINYINT=4;

        SET @Message= ERROR_MESSAGE();
        IF (@xstate= -1)
            BEGIN
        ROLLBACK TRANSACTION @tranName
    END
        IF (@xstate=1 AND @trancount=0)
            BEGIN
        -- COMMIT TRANSACTION @tranName
        ROLLBACK TRANSACTION @tranName
    END

        IF (@xstate=1 AND @trancount > 0)
            BEGIN
        ROLLBACK TRANSACTION @tranName;
    END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;

    END CATCH

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------