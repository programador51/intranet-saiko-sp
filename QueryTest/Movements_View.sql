

SELECT 
    movement.MovementID AS id,
    dbo.FormatDateYYYMMDD(movement.movementDate) AS date,

    CASE 
        WHEN movement.reference IS NULL THEN ''
        ELSE movement.reference
    END AS reference,
    movementTypes.description AS statusDescription,
    movement.[status] AS [status],

    CASE 
        WHEN movement.checkNumber IS NULL THEN ''
        ELSE movement.checkNumber
    END AS checkNumber,

    CASE
        WHEN movement.movementType = 1 THEN 'Ingreso'
        ELSE 'Egreso'
    END AS movementTypeDescription,

     movement.movementType,
     
    CASE 
        WHEN movement.movementType = 1 THEN ''
        ELSE dbo.fn_FormatCurrency(movement.amount)
    END AS egress,

    CASE 
        WHEN movement.movementType = 0 THEN ''
        ELSE dbo.fn_FormatCurrency(movement.amount)
    END AS ingress,

    movement.concept AS concept,

    CASE 
        WHEN movement.paymentMethod = NULL THEN CONVERT(NVARCHAR(10),movement.paymentMethod)
        ELSE  ''
    END AS method,

    movement.paymentMethod,
    FORMAT(movement.noMovement,'0000000') AS folio,

    movement.customerAssociated,

    dbo.fn_RoundDecimals(movement.[amount],2) AS import,
    -- dbo.fn_FormatCurrency(dbo.fn_RoundDecimals(movement.[amount],2)) AS [importe.text],

    dbo.fn_RoundDecimals(movement.[saldo],2) AS residue,
        -- dbo.fn_FormatCurrency(dbo.fn_RoundDecimals(movement.[saldo],2)) AS [residue.text],

    dbo.fn_RoundDecimals(movement.[acreditedAmountCalculated],2) AS asociated,
    -- dbo.fn_FormatCurrency(dbo.fn_RoundDecimals(movement.[acreditedAmountCalculated],2)) AS [asociado.text],

    movementAssociatios.description AS typeAssocitionDescription,
    movement.movementTypeNumber AS typeAssociationId,

    movement.noMovement,
    movement.bankAccount,
    movement.movementType,
    movement.amount,
    CASE 
        WHEN movement.movementType=1
            THEN 
                movement.amount + LAG(currentBankResidue,1,account.initialAmount) OVER (ORDER BY movement.noMovement ASC)
        ELSE
            LAG(currentBankResidue,1,account.initialAmount) OVER (ORDER BY movement.noMovement ASC) - movement.amount 
    END AS currentResidue

 FROM Movements AS movement
 LEFT JOIN ingress_view AS ingressView ON ingressView.bankAccount= movement.bankAccount
 LEFT JOIN egress_view AS egressView ON egressView.bankAccount= movement.bankAccount
 LEFT JOIN BankAccounts AS account ON account.bankAccountID=movement.bankAccount
 LEFT JOIN MovementTypes AS movementTypes ON movementTypes.movementID= movement.[status]
 LEFT JOIN MovementTypeAssociation AS movementAssociatios ON movementAssociatios.id= movement.movementTypeNumber
 
 WHERE movement.[status]!=5 
 ORDER BY movement.bankAccount,movement.noMovement ASC
