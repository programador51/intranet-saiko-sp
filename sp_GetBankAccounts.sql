-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-26-2021
-- Description: Get all the bank accounts.
-- STORED PROCEDURE NAME:	sp_GetBankAccounts
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @rangeBegin
-- @noRegisters
-- ==================================================================================================================================================
-- Returns:
-- ==================================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ==================================================================================================================================================
--	2021-07-26		Adrian Alardin   			1.0.0.0			Initial Revision
--  2021-10-06      Iván Díaz                   1.0.0.1         INNER JOINS changed to LEFT JOINS
-- **************************************************************************************************************************************************

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetBankAccounts (
    @rangeBegin INT,
    @noRegisters INT
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
   SELECT BankAccounts.bankAccountID AS bankAccountID,
        Banks.socialReason AS socialReason,
        Banks.shortName AS shortName,
        Banks.bankID AS bankID,
        BankAccounts.accountNumber AS accountNumber,
        BankAccounts.CLABE AS clabe,
        BankAccounts.SATcode AS SAT,
        Currencies.code AS currency,
        BankAccounts.nextIncome AS ingreso,
        BankAccounts.nextEgress AS egreso,
        BankAccounts.comments AS tipoCuenta,
        BankAccounts.initialAmount AS saldoInicial
        FROM BankAccounts
        LEFT JOIN Currencies ON BankAccounts.currencyID=Currencies.currencyID       --1.0.0.1 
        LEFT JOIN Banks ON BankAccounts.bankID=Banks.bankID                         --1.0.0.1 
        ORDER BY BankAccounts.bankAccountID
            OFFSET @rangeBegin ROWS
            FETCH NEXT @noRegisters ROWS ONLY
END
GO
