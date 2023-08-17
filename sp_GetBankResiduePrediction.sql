-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-11-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetBankResiduePrediction
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
--	2023-07-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/11/2023
-- Description: sp_GetBankResiduePrediction - Some Notes
CREATE PROCEDURE sp_GetBankResiduePrediction(
    @currencyIWant NVARCHAR(3),
    @currencyToShow NVARCHAR(3),
    @tc DECIMAL (14,2)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

     SELECT DISTINCT
            bankAcount.id AS [id],
            ISNULL(bank.commercialName,'ND') AS [name],
            bankAcount.comments AS [description],
            bankAcount.accountNumber AS account,
            bankAcount.currency AS currency,
            CASE 
                WHEN @currencyToShow='MXN' THEN (
                    CASE 
                        WHEN bankAcount.currency='MXN' THEN ISNULL(bankAcount.currentBalance ,0)
                        ELSE ISNULL(bankAcount.currentBalance,0) * @tc
                    END
                )
                ELSE (
                    CASE 
                        WHEN bankAcount.currency='USD' THEN ISNULL(bankAcount.currentBalance,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) / @tc
                    END
                )
            END AS amount,
            CASE 
                WHEN @currencyToShow='MXN' THEN (
                    CASE 
                        WHEN bankAcount.currency='MXN' THEN ISNULL(bankAcount.currentBalance ,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) * @tc
                    END
                )
                ELSE (
                    CASE 
                        WHEN bankAcount.currency='USD' THEN ISNULL(bankAcount.currentBalance,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) / @tc
                    END
                )
            END AS yesterdayCxc,
            CASE 
                WHEN @currencyToShow='MXN' THEN (
                    CASE 
                        WHEN bankAcount.currency='MXN' THEN ISNULL(bankAcount.currentBalance ,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) * @tc
                    END
                )
                ELSE (
                    CASE 
                        WHEN bankAcount.currency='USD' THEN ISNULL(bankAcount.currentBalance ,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) / @tc
                    END
                )
            END AS todayCxc,
            
            CASE 
                WHEN @currencyToShow='MXN' THEN (
                    CASE 
                        WHEN bankAcount.currency='MXN' THEN ISNULL(bankAcount.currentBalance ,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) * @tc
                    END
                )
                ELSE (
                    CASE 
                        WHEN bankAcount.currency='USD' THEN ISNULL(bankAcount.currentBalance ,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) / @tc
                    END
                )
            END AS nextDay,
            CASE 
                WHEN @currencyToShow='MXN' THEN (
                    CASE 
                        WHEN bankAcount.currency='MXN' THEN ISNULL(bankAcount.currentBalance ,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) * @tc
                    END
                )
                ELSE (
                    CASE 
                        WHEN bankAcount.currency='USD' THEN ISNULL(bankAcount.currentBalance ,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) / @tc
                    END
                )
            END AS next7Days,
            CASE 
                WHEN @currencyToShow='MXN' THEN (
                    CASE 
                        WHEN bankAcount.currency='MXN' THEN ISNULL(bankAcount.currentBalance ,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) * @tc
                    END
                )
                ELSE (
                    CASE 
                        WHEN bankAcount.currency='USD' THEN ISNULL(bankAcount.currentBalance ,0)
                        ELSE ISNULL(bankAcount.currentBalance ,0) / @tc
                    END
                )
            END AS next14Days,
            bank.clave AS satCode

        FROM BankAccountsV2 AS bankAcount
        LEFT JOIN Banks AS bank ON bank.bankID=bankAcount.bank
        WHERE 
            bankAcount.[status]=1 AND 
            bankAcount.currency LIKE ISNULL(@currencyIWant,'')+'%'
    FOR JSON PATH , ROOT('bankAccounts')

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------