-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-23-2022
-- Description: Add a banck account
-- STORED PROCEDURE NAME:	sp_AddBanckAccount
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
--	2022-09-23		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/23/2022
-- Description: sp_AddBanckAccount - Add a banck account
CREATE PROCEDURE sp_AddBanckAccount(
    @bankID INT,
    @accountNumber NVARCHAR(50),
    @CLABE NVARCHAR(50),
    @SAT NVARCHAR(100),
    @currencyID INT,
    @initialAmount DECIMAL(14,4),
    @nextIncome INT,
    @nextEgress INT,
    @accontType NVARCHAR(256),
    @today DATE,
    @modifyBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idAccount INT;

    INSERT INTO BankAccounts (
        bankID,
        accountNumber,
        CLABE,
        SATcode,
        currencyID,
        initialAmount,
        nextIncome,
        nextEgress,
        comments,
        [status],
        createdBy,
        createdDate,
        lastUpdatedBy,
        lastUpdatedDate
    )
    VALUES (
        @bankID,
        @accountNumber,
        @CLABE,
        @SAT,
        @currencyID,
        @initialAmount,
        @nextIncome,
        @nextEgress,
        @accontType,
        1,
        @modifyBy,
        @today,
        @modifyBy,
        @today
    )

    SELECT @idAccount= SCOPE_IDENTITY();

    EXEC sp_AddMonthConciliation @initialAmount,@modifyBy,@idAccount

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------