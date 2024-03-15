-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 01-03-2024
-- Description: Update the opening balance of the bank account as long as there is only one month closed
-- STORED PROCEDURE NAME:	sp_UpdateBeginBankAccountBalance
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
    -- @idBankAccount: Bank account id
    -- @initialAmount: The new initial amount
    -- @newKeyMonth: The new month mey for the colsed months
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-01-03		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_UpdateBeginBankAccountBalance')
    BEGIN 

        DROP PROCEDURE sp_UpdateBeginBankAccountBalance;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 01/03/2024
-- Description: sp_UpdateBeginBankAccountBalance - Update the opening balance of the bank account as long as there is only one month closed
CREATE PROCEDURE sp_UpdateBeginBankAccountBalance(
    @idBankAccount INT,
    @initialAmount DECIMAL (14,4),
    @newKeyMonth INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @keyMonth INT;
    DECLARE @canUpdate BIT;
    DECLARE @currentBalance DECIMAL (14,4);

    DECLARE @tranName NVARCHAR(50)='updateBalance';
    DECLARE @trancount INT;
    DECLARE @today DATETIME;
    SELECT @today = GETUTCDATE();
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
        SELECT 
            @canUpdate = 
                CASE 
                    WHEN COUNT(*) = 1 THEN 1
                    WHEN COUNT(*) > 1 THEN 0
                    ELSE 0
                END
        FROM MonthConsilation
        WHERE 
            idAccount = @idBankAccount AND 
            [status]= 1;

        IF(@canUpdate=1)
        BEGIN
            SELECT 
                @keyMonth = [key]
            FROM MonthConsilation 
                WHERE idAccount =@idBankAccount

            SELECT 
                @currentBalance = @initialAmount + SUM(
                    CASE 
                        WHEN movementType= 1 THEN amount
                        ELSE amount * -1
                    END
                )
            FROM Movements
            WHERE 
                bankAccount = @idBankAccount AND
                [status]!=4 

            UPDATE BankAccountsV2 SET 
                closingBalance = @initialAmount,
                currentBalance= ISNULL(@currentBalance,@initialAmount)
            WHERE id= @idBankAccount

            UPDATE MonthConsilation SET
                amount= @currentBalance,
                [key]= ISNULL(@newKeyMonth,@keyMonth)
            WHERE 
                [key]=@keyMonth AND
                idAccount= @idBankAccount
        END
    ELSE 
        BEGIN
            ;THROW 51000, 'No puede ser actualizado el registro',1;
        END
    IF (@trancount=0)
            BEGIN
                COMMIT TRANSACTION @tranName
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