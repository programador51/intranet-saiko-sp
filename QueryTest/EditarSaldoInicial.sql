DECLARE @idBankAccount INT =3;
DECLARE @newKeyMonth INT;
DECLARE @initialAmount DECIMAL (14,4)=2232683.77;
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
                [status]= 1

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

