-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-26-2021
-- Description: create banks accounts
-- STORED PROCEDURE NAME:	sp_AddBankAccount
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @bankID: Bank id
-- @accountNumber: account number
-- @CLABE: CLABE code
-- @SAT: SAT code
-- @currencyID: The currency type id
-- @initialAmount: Initial amount
-- @nextIncome: next income
-- @nextEgress: next egress
-- @accontType: Account type (is save on comments)
-- @today: the day of the record it wase created
-- @modifyBy: the user how create/modify the record
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-07-26		Adrian Alardin   			1.0.0.0			Initial Revision
-- *****************************************************************************************************************************




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_AddBankAccount
    (
    -- Add the parameters for the stored procedure here
    @bankID INT,
    @accountNumber NVARCHAR(50),
    @CLABE NVARCHAR(50),
    @SAT NVARCHAR(100),
    @currencyID INT,
    @initialAmount DECIMAL(14,4),
    @nextIncome INT,
    @nextEgress INT,
    @accontType NVARCHAR(256),
    @modifyBy NVARCHAR(30),
    @today DATETIME
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    INSERT INTO BankAccounts
        (
        bankID,accountNumber,CLABE,SATcode,currencyID,initialAmount,nextIncome,nextEgress,comments,status,createdBy,createdDate,
        lastUpdatedBy,lastUpdatedDate)
    VALUES
        (
            @bankID, @accountNumber, @CLABE, @SAT, @currencyID,
            @initialAmount, @nextIncome, @nextEgress, @accontType, 1, @modifyBy, @today, @modifyBy, @today
            )
END
GO
