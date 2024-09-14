-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-05-2023
-- Description: 
-- STORED PROCEDURE NAME:	spGetBanksResiduesReport
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
--	2023-07-05		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/05/2023
-- Description: spGetBanksResiduesReport - Some Notes
CREATE PROCEDURE spGetBanksResiduesReport AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    
    DECLARE @totalMxn DECIMAL(14,2);
    DECLARE @totalUSD DECIMAL(14,2);
    SELECT 
        @totalMxn = SUM(
        CASE 
            WHEN currency.code='MXN' THEN bankAcount.currentAmount
            ELSE 0
        END
        ),
        @totalUSD = SUM(
        CASE 
            WHEN currency.code='USD' THEN bankAcount.currentAmount
            ELSE 0
        END
    )
    FROM BankAccounts AS bankAcount
    LEFT JOIN Currencies AS currency ON currency.currencyID= bankAcount.currencyID


    SELECT 
        @totalMxn AS totalMxn,
        @totalUSD AS totalUSD,
        (
        SELECT 
            ISNULL(bank.commercialName,'ND') AS [name],
            bankAcount.comments AS [description],
            bankAcount.accountNumber AS account,
            currency.code AS currency,
            bankAcount.currentAmount AS amount,
            @totalMxn AS totalMXN,
            @totalUSD AS totalUSD

        FROM BankAccounts AS bankAcount
        LEFT JOIN Banks AS bank ON bank.bankID=bankAcount.bankID
        LEFT JOIN Currencies AS currency ON currency.currencyID= bankAcount.currencyID
        WHERE bankAcount.[status]=1
        FOR JSON PATH
        ) AS banckAccounts
    FOR JSON PATH , ROOT('report')

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------