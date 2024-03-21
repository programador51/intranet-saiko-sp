-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-09-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetBankAccountsReports
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
--	2023-03-09		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/09/2023
-- Description: sp_GetBankAccountsReports - Some Notes

CREATE PROCEDURE sp_GetBankAccountsReports(
    @withMovement BIT,
    @beginDate DATETIME,
    @endDate DATETIME,
    @idBankAccount INT
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    IF OBJECT_ID(N'tempdb..#BankAccountsIds') IS NOT NULL 
        BEGIN
        DROP TABLE #BankAccountsIds
    END
    IF OBJECT_ID(N'tempdb..#MovementToSum') IS NOT NULL 
        BEGIN
        DROP TABLE #MovementToSum
    END
    IF OBJECT_ID(N'tempdb..#MovementToShow') IS NOT NULL 
        BEGIN
        DROP TABLE #MovementToShow
    END

    DECLARE @year INT;
    DECLARE @month INT;

    DECLARE @codeToInitialBalance NVARCHAR(6);
    DECLARE @codeToFinalBalance NVARCHAR(6);

    DECLARE @initialBalance DECIMAL(14,4)=0;
    DECLARE @finalBalance DECIMAL(14,4)=0

    DECLARE @totalIngress DECIMAL(14,4)=0;
    DECLARE @totalEgress DECIMAL(14,4)=0;

    SELECT 
        @year =
            CASE 
                WHEN @beginDate IS NOT NULL THEN YEAR(@beginDate)
                ELSE -1
            END,
        @month =
            CASE 
                WHEN @beginDate IS NOT NULL THEN MONTH(@beginDate)
                ELSE -1
            END;

    SELECT 
        @codeToFinalBalance= 
            CASE 
                WHEN @year!=-1 THEN 
                    CASE 
                        WHEN @month - 1 = 0 THEN CONCAT(@year-1,12)
                        ELSE CONCAT(@year,@month-1)
                    END
                ELSE null
            END,
        @codeToInitialBalance= 
            CASE 
                WHEN @year!=-1 THEN 
                    CASE 
                        WHEN @month - 2 = 0 THEN CONCAT(@year-1,12)
                        ELSE CONCAT(@year,@month-2)
                    END
                ELSE null
            END

    
    SELECT 
        @initialBalance= amount 
    FROM MonthConsilation WHERE [key]=@codeToInitialBalance 
    SELECT 
        @finalBalance= amount 
    FROM MonthConsilation WHERE [key]=@codeToFinalBalance 

    SELECT 
        @totalIngress = 
        CASE
            WHEN @withMovement=1 THEN (
                SELECT 
                    SUM(amount) 
                FROM Movements AS movement  
                WHERE 
                    movement.bankAccount=@idBankAccount AND 
                    ( movement.createdDate>= @beginDate AND movement.createdDate<= @endDate) AND
                    movement.status!=4 AND 
                    movement.movementType=1
             )
             ELSE 0
        END,
        @totalEgress = 
        CASE
            WHEN @withMovement=1 THEN (
                SELECT SUM(amount) 
                FROM Movements AS movement  
                WHERE 
                    movement.bankAccount=@idBankAccount AND 
                    ( movement.createdDate>= @beginDate AND movement.createdDate<= @endDate) AND
                    movement.status!=4 AND 
                    movement.movementType!=1
             )
             ELSE 0
        END

    CREATE TABLE #BankAccountsIds
    (
        id INT NOT NULL
    )
    CREATE TABLE #MovementToSum
    (
        id INT NOT NULL IDENTITY(1,1),
        idMovement INT,
        amount DECIMAL(14,4),
        [status] BIT,
    )
    CREATE TABLE #MovementToShow
    (
        id INT NOT NULL IDENTITY(1,1),
        idMovement INT,
        socialReson NVARCHAR(256),
        [date] DATETIME,
        reference NVARCHAR(128),
        paymentMethod NVARCHAR(128),
        balance DECIMAL(14,4),
        amount DECIMAL(14,4),
        [status] BIT,
    )
    INSERT INTO #MovementToSum (amount,[status])  VALUES (@finalBalance,0);
    INSERT INTO #MovementToSum (idMovement,amount,[status])  
        SELECT 
        movement.MovementID,
            CASE
                WHEN movement.movementType=1 THEN amount 
                ELSE amount*-1
            END,
            1
        FROM Movements AS movement
        WHERE 
            movement.bankAccount=@idBankAccount AND 
            ( movement.movementDate>= @beginDate AND movement.movementDate<= @endDate) AND 
            movement.[status]!=4
    INSERT INTO #MovementToShow (
        idMovement,
        socialReson,
        [date],
        reference,
        paymentMethod,
        balance,
        amount,
        [status]
    )
    SELECT 
        movementToSum.idMovement,
        ISNULL(customer.socialReason,'ND'),
        movement.movementDate,
        movement.reference,
        paymentMethod.[description],
        SUM(SUM( movementToSum.amount )) OVER (ORDER BY movementToSum.idMovement),
        movementToSum.amount,
        movementToSum.[status]
    FROM #MovementToSum AS movementToSum
    LEFT JOIN Movements AS movement ON movement.MovementID = movementToSum.idMovement
    LEFT JOIN Customers AS customer ON customer.customerID=movement.customerAssociated
    LEFT JOIN PaymentMethods AS paymentMethod ON paymentMethod.code=movement.paymentMethod
    GROUP BY 
        movementToSum.idMovement,
        customer.socialReason,
        movement.movementDate,
        movement.reference,
        paymentMethod.[description],
        movementToSum.amount,
        movementToSum.[status]

    IF @idBankAccount IS NULL
        BEGIN
            INSERT INTO #BankAccountsIds (id) 
            SELECT id FROM BankAccountsV2 WHERE [status]=1
        END
    ELSE
        BEGIN
            INSERT INTO #BankAccountsIds (id) VALUES(@idBankAccount)
        END

    SELECT DISTINCT
        bankAccount.id AS id,
        bank.clave AS clave,
        bank.shortName AS bankName,
        bank.socialReason AS bankSocialReason,
        bankAccount.[description] AS [description],
        bankAccount.accountNumber AS account,
        bankAccount.CLABE AS clabe,
        bankAccount.currency AS currency,
        bankAccount.currentBalance AS [balance.number],
        DBO.fn_FormatCurrency(bankAccount.currentBalance) AS [balance.text],
        @initialBalance AS [initialBalance.number],
        DBO.fn_FormatCurrency(@initialBalance) AS [initialBalance.text],
        @finalBalance AS [finalBalance.number],
        DBO.fn_FormatCurrency(@finalBalance) AS [finalBalance.text],
        ISNULL(@totalIngress,0) AS [totalIngress.number],
        dbo.fn_FormatCurrency(ISNULL(@totalIngress,0) ) AS [totalIngress.text],
        ISNULL(@totalEgress,0) AS [totalEgress.number],
        dbo.fn_FormatCurrency(ISNULL(@totalEgress,0)) AS [totalEgress.text],
        JSON_QUERY( CASE
            WHEN @withMovement=1 THEN 
                (
                    SELECT 
                        idMovement AS [no],
                        socialReson AS socialReasonReference,
                        dbo.FormatDateYYYMMDD([date]) AS [date],
                        reference AS [reference],
                        paymentMethod AS [movementType],
                        amount AS [amount.number],
                        dbo.fn_FormatCurrency(amount) AS [amount.text],
                        balance AS  [balance.number],
                        dbo.fn_FormatCurrency(balance) AS  [balance.text]
                     FROM #MovementToShow
                     WHERE [status]=1
                     FOR JSON PATH, INCLUDE_NULL_VALUES
                )
    ELSE NULL
    END) AS [movements]
    FROM BankAccountsV2 AS bankAccount
        LEFT JOIN Banks AS bank ON bank.bankID= bankAccount.bank
    WHERE bankAccount.id IN (SELECT id FROM #BankAccountsIds)
    FOR JSON PATH,ROOT('bankAccounts'),INCLUDE_NULL_VALUES

    IF OBJECT_ID(N'tempdb..#BankAccountsIds') IS NOT NULL 
        BEGIN
        DROP TABLE #BankAccountsIds
    END
    IF OBJECT_ID(N'tempdb..#MovementToSum') IS NOT NULL 
        BEGIN
        DROP TABLE #MovementToSum
    END
    IF OBJECT_ID(N'tempdb..#MovementToShow') IS NOT NULL 
        BEGIN
        DROP TABLE #MovementToShow
    END

    END

    -- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
    -- ----------------- ↑↑↑ END ↑↑↑ -----------------------

    -- EXEC sp_GetBankAccountsReports 1,'2023-03-01','2023-03-11',21