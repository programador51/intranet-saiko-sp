


IF OBJECT_ID(N'tempdb..#TempIngress') IS NOT NULL
        BEGIN
            DROP TABLE #TempIngress
        END
IF OBJECT_ID(N'tempdb..#TempEgress') IS NOT NULL
        BEGIN
            DROP TABLE #TempEgress
        END


CREATE TABLE #TempIngress (
    id INT NOT NULL IDENTITY(1,1),
    idBankAccount INT NOT NULL,
    total DECIMAL(14,2) NOT NULL
)

CREATE TABLE #TempEgress (
    id INT NOT NULL IDENTITY(1,1),
    idBankAccount INT NOT NULL,
    total DECIMAL(14,2) NOT NULL
)

INSERT INTO #TempIngress (
    idBankAccount,
    total
)
SELECT 
    
    bankAccount,
    SUM(amount) 
FROM Movements 
WHERE [status]!=5 AND movementType=1
GROUP BY bankAccount

INSERT INTO #TempEgress (
    idBankAccount,
    total
)
SELECT 
    
    bankAccount,
    SUM(amount) 
FROM Movements 
WHERE [status]!=5 AND movementType=0
GROUP BY bankAccount



SELECT 
    movement.bankAccount AS banckAccount,
    account.initialAmount + tempIngress.total - tempEgress.total AS currentResidue
FROM Movements AS movement
LEFT JOIN BankAccounts AS account ON account.bankAccountID = movement.bankAccount
LEFT JOIN #TempIngress AS tempIngress ON tempIngress.idBankAccount = movement.bankAccount
LEFT JOIN #TempEgress AS tempEgress ON tempEgress.idBankAccount = movement.bankAccount
WHERE 
    movement.[status]!=5 
GROUP BY 
    movement.bankAccount,
    account.initialAmount,
    tempEgress.total,
    tempIngress.total


SELECT * FROM #TempIngress
SELECT * FROM #TempEgress
SELECT bankAccountID,initialAmount FROM BankAccounts 

IF OBJECT_ID(N'tempdb..#TempIngress') IS NOT NULL
        BEGIN
            DROP TABLE #TempIngress
        END
IF OBJECT_ID(N'tempdb..#TempEgress') IS NOT NULL
        BEGIN
            DROP TABLE #TempEgress
        END