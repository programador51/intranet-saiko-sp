-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06-03-2023
-- Description: Actualiza el saldo de una cuenta de banco
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_UpdateBankAccountBalance')
    BEGIN 

        DROP PROCEDURE sp_UpdateBankAccountBalance;
    END
GO
CREATE PROCEDURE [dbo].[sp_UpdateBankAccountBalance]
(
    @ammount DECIMAL(14, 2),
    @id INT
)
AS
BEGIN

    UPDATE BankAccountsV2
    SET currentBalance = currentBalance + @ammount
    WHERE id = @id;

    SELECT currentBalance FROM BankAccountsV2 WHERE id = @id;

END