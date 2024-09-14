SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/24/2023
-- Description: sp_GetBankAccountStatement - Some Notes
-- DROP PROCEDURE sp_GetBankAccountStatement;
CREATE PROCEDURE [dbo].[sp_GetBankAccountStatement](
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

    DECLARE @codeToInitialBalance NVARCHAR(6);
    DECLARE @codeToFinalBalance NVARCHAR(6);
    DECLARE @dateToCodeInitialBalance DATETIME;

    DECLARE @initialBalance DECIMAL(14,4)=0;
    DECLARE @finalBalance DECIMAL(14,4)=0

    DECLARE @totalIngress DECIMAL(14,4)=0;
    DECLARE @totalEgress DECIMAL(14,4)=0;


    SELECT @codeToFinalBalance = CONCAT(YEAR(@beginDate),CONVERT(NVARCHAR(2),@beginDate,101));
    SELECT @dateToCodeInitialBalance = DATEADD(MONTH, DATEDIFF(MONTH, 0, @beginDate)-1, 0);
    SELECT @codeToInitialBalance= CONCAT(YEAR(@dateToCodeInitialBalance),CONVERT(NVARCHAR(2),@dateToCodeInitialBalance,101));



    
    SELECT 
        @initialBalance= amount 
    FROM MonthConsilation WHERE [key]=@codeToInitialBalance AND idAccount=@idBankAccount
    SELECT 
        @finalBalance= amount 
    FROM MonthConsilation WHERE [key]=@codeToFinalBalance AND idAccount=@idBankAccount



 SELECT 
        @totalIngress = 
        CASE
            WHEN @withMovement=1 THEN (
                SUM(
                    CASE 
                        WHEN movement.movementType=1 AND movement.[status] != 4 THEN movement.amount
                        ELSE 0
                    END
                )
            )
            ELSE 0
        END,
        @totalEgress = 
        CASE
            WHEN @withMovement=1 THEN (
                SUM(
                    CASE 
                        WHEN movement.movementType!=1 AND movement.[status] != 4 THEN movement.amount
                        ELSE 0
                    END
                )
             )
             ELSE 0
        END
    FROM Movements AS movement  
    WHERE 
        movement.bankAccount=@idBankAccount AND 
        ( movement.movementDate>= @beginDate AND movement.movementDate<= @endDate)
    -- SELECT 
    --     @totalIngress = 
    --     CASE
    --         WHEN @withMovement=1 THEN (
    --             SELECT 
    --                 SUM(
    --                     CASE 
    --                         WHEN movement.status=4 THEN 0
    --                         ELSE movement.amount
    --                     END
    --                 ) 
    --             FROM Movements AS movement  
    --             WHERE 
    --                 movement.bankAccount=@idBankAccount AND 
    --                 ( movement.createdDate>= @beginDate AND movement.createdDate<= @endDate) AND
    --                 movement.movementType=1
    --          )
    --          ELSE 0
    --     END,
    --     @totalEgress = 
    --     CASE
    --         WHEN @withMovement=1 THEN (
    --             SELECT SUM(
    --                  CASE 
    --                         WHEN movement.status=4 THEN 0
    --                         ELSE movement.amount
    --                     END
    --             ) 
    --             FROM Movements AS movement  
    --             WHERE 
    --                 movement.bankAccount=@idBankAccount AND 
    --                 ( movement.createdDate>= @beginDate AND movement.createdDate<= @endDate) AND
    --                 movement.movementType!=1
    --          )
    --          ELSE 0
    --     END

    CREATE TABLE #BankAccountsIds
    (
        id INT NOT NULL
    )
    CREATE TABLE #MovementToSum
    (
        id INT NOT NULL IDENTITY(1,1),
        idMovement INT,
        idMovementType INT,
        amount DECIMAL(14,4),
        [status] BIT,
        statusDescription NVARCHAR(30)
    )
    CREATE TABLE #MovementToShow
    (
        id INT NOT NULL IDENTITY(1,1),
        idMovement INT,
        idMovementType INT,
        socialReson NVARCHAR(256),
        [date] DATETIME,
        reference NVARCHAR(128),
        paymentMethod NVARCHAR(128),
        balance DECIMAL(14,4),
        amount DECIMAL(14,4),
        [status] BIT,
        statusDescription NVARCHAR(30),
        idBeneficiary INT
    )
    INSERT INTO #MovementToSum (amount,[status])  VALUES (@initialBalance,0);
    INSERT INTO #MovementToSum (idMovement,idMovementType,amount,[status],statusDescription)  
        SELECT 
        movement.MovementID,
        movement.movementType,
            CASE
                WHEN movement.movementType=1 THEN amount 
                ELSE amount*-1
            END,
            movement.[status],
            movementStatus.[description]
        FROM Movements AS movement
        LEFT JOIN MovementStatus AS movementStatus ON movementStatus.id=movement.[status]
        WHERE 
            movement.bankAccount=@idBankAccount 
            AND movement.[status] != 4
            AND ( movement.movementDate>= @beginDate AND movement.movementDate<= @endDate)
    INSERT INTO #MovementToShow (
        idMovement,
        idMovementType,
        socialReson,
        [date],
        reference,
        paymentMethod,
        balance,
        amount,
        [status],
        statusDescription,
        idBeneficiary
    )
    SELECT 
        movementToSum.idMovement,
        movementToSum.idMovementType,
        ISNULL(customer.socialReason,'ND'),
        movement.movementDate,
        movement.reference,
        paymentMethod.[description],
        SUM(SUM( CASE 
                            WHEN movementToSum.[status]=4 THEN 0
                            ELSE movementToSum.amount
                        END)) OVER (ORDER BY movementToSum.idMovement),
        ABS(movementToSum.amount),
        movementToSum.[status],
        movementToSum.statusDescription,
        movement.idBeneficiary
    FROM #MovementToSum AS movementToSum
    LEFT JOIN Movements AS movement ON movement.MovementID = movementToSum.idMovement
    LEFT JOIN Customers AS customer ON customer.customerID=movement.customerAssociated
    LEFT JOIN PaymentMethods AS paymentMethod ON paymentMethod.code=movement.paymentMethod
    GROUP BY 
        movementToSum.idMovement,
        movementToSum.idMovementType,
        customer.socialReason,
        movement.movementDate,
        movement.reference,
        movement.idBeneficiary,
        paymentMethod.[description],
        movementToSum.amount,
        movementToSum.[status],
        movementToSum.statusDescription
    ORDER BY movement.movementDate

    -- IF @idBankAccount IS NULL
    --     BEGIN
    --         INSERT INTO #BankAccountsIds (id) 
    --         SELECT id FROM BankAccountsV2 WHERE [status]=1
    --     END
    -- ELSE
    --     BEGIN
    --         INSERT INTO #BankAccountsIds (id) VALUES(@idBankAccount)
    --     END

    SELECT DISTINCT
        bankAccount.id AS id,
        bank.clave AS clave,
        bank.shortName AS bankName,
        bank.socialReason AS bankSocialReason,
        bankAccount.[description] AS [description],
        bankAccount.accountNumber AS account,
        bankAccount.CLABE AS clabe,
        bankAccount.currency AS currency,
        dbo.FormatDate(@beginDate) AS [beginDate],
        dbo.FormatDate(@endDate) AS [endDate],
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
                        movementToShow.idMovement AS [no],
                        beneficiary.beneficiary AS [beneficiary],
                        movementToShow.idMovementType AS [type.id],
                        CASE 
                            WHEN movementToShow.idMovementType= 1 THEN 'Ingreso'
                            ELSE 'Egreso'
                        END AS [type.description],
                        JSON_QUERY(
                           ( SELECT
                                ISNULL(movementWithConcept.idConcept,-1) AS [id],
                                ISNULL(movementWithConcept.idConceptType,-2) AS [idType],
                                ISNULL(movementWithConcept.concept,'ND') AS [concept],
                                ISNULL(movementWithConcept.conceptType,'ND') AS [type],
                                ISNULL(movementWithConcept.conceptDescription,'ND') AS [description]
                            FROM MovementWithConcepts AS movementWithConcept
                            WHERE idMovement=movementToShow.idMovement
                            FOR JSON PATH, INCLUDE_NULL_VALUES
                        )) AS [concept],
                        ISNULL(
                            JSON_QUERY(
                           ( SELECT DISTINCT
                                invoice.noDocument AS folio
                            FROM ConcilationCxC AS movementToInvoice
                            LEFT JOIN LegalDocuments AS invoice ON invoice.uuid= movementToInvoice.uuid
                            WHERE movementToInvoice.idMovement=movementToShow.idMovement
                            FOR JSON PATH, INCLUDE_NULL_VALUES
                        )),
                        '[]'
                        ) AS [invoiceEmited],
                        ISNULL(
                            JSON_QUERY(
                           ( SELECT DISTINCT
                                invoice.noDocument AS folio
                            FROM ConcilationCxP AS movementToInvoice
                            LEFT JOIN LegalDocuments AS invoice ON invoice.uuid= movementToInvoice.uuid
                            WHERE movementToInvoice.idMovement=movementToShow.idMovement
                            FOR JSON PATH, INCLUDE_NULL_VALUES
                        )),
                        '[]'
                        ) AS [invoiceRecived],
                        movementToShow.socialReson AS socialReasonReference,
                        dbo.FormatDate(movementToShow.[date]) AS [date],
                        CONVERT(date,movementToShow.[date]) AS yyyymmdd,
                        movementToShow.reference AS [reference],
                        movementToShow.paymentMethod AS [movementType],
                        movementToShow.[status] AS [status],
                        movementToShow.statusDescription AS statusDescription,
                        movementToShow.amount AS [amount.number],
                        dbo.fn_FormatCurrency(movementToShow.amount) AS [amount.text],
                        movementToShow.balance AS  [balance.number],
                        dbo.fn_FormatCurrency(movementToShow.balance) AS  [balance.text]
                     FROM #MovementToShow AS movementToShow
                     LEFT JOIN Beneficiary AS beneficiary ON beneficiary.id=movementToShow.idBeneficiary
                     WHERE movementToShow.[status]=1
                     ORDER BY
                        movementToShow.[date]
                     FOR JSON PATH, INCLUDE_NULL_VALUES
                )
    ELSE NULL
    END) AS [movements]
    FROM BankAccountsV2 AS bankAccount
        LEFT JOIN Banks AS bank ON bank.bankID= bankAccount.bank
    WHERE bankAccount.id =@idBankAccount
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

    -- ----------------- â†“â†“â†“ BEGIN â†“â†“â†“ -----------------------
    -- ----------------- â†‘â†‘â†‘ END â†‘â†‘â†‘ -----------------------

    -- EXEC sp_GetBankAccountsReports 1,'2023-03-01','2023-03-11',21
GO
