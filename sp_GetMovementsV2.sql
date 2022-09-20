-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 21-12-2021
-- Description: Get the movements filtered by some params
-- STORED PROCEDURE NAME:	sp_GetMovementsV2
-- ===============================================================================================================================
-- PARAMETERS:
-- @account: Id of the bank account to request the information
-- @pageRequested: Number of page requested among all the information
-- @beginDate: Filter by range date (begin)
-- @endDate: Filter by range date (end)
-- @status: Id of the status to filter the movements (1-5)
-- ===============================================================================================================================
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ===============================================================================================================================
--	21-12-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

-- ================================== FOLLOWING RESULT ===========================================================================

-- {
--     "movements": [
--         {
--             "pages": 3,
--             "actualPage": 1,
--             "noRegisters": 23
--         },
--         [
--             {
--     "Fecha": "16-12-2021",
--     "Referencia_deposito": "16-12-21",
--     "status": "Activo",
--     "Cheque": "",
--     "checkNumber": null,
--     "Tipo_Movimiento": "Ingreso",
--     "movementType": 1,
--     "Egreso": "",
--     "Ingreso": "1000.0000",
--     "Concepto": "Posada V343",
--     "Metodo": "",
--     "paymentMethod": null,
--     "Movimiento": 29,
--     "statusValue": 1,
--     "customerAssociated": 216,
--     "saldo": 0,
--     "importe": {
--         "number": 1000,
--         "text": "$1,000.00"
--     },
--     "residue": {
--         "number": 0,
--         "text": "$0.00"
--     },
--     "asociado": {
--         "number": 1000,
--         "text": "$1,000.00"
--     }
-- }
--             { ... } , { ... } , { ... } , { ... } , 
--         ]
--     ]
-- }

-- ===============================================================================================================================
CREATE PROCEDURE sp_GetMovementsV2(
    @account INT,
    @pageRequested INT,
    @beginDate DATE,
    @endDate DATE,
    @status INT
)

AS
BEGIN

    -- Number of registers founded
    DECLARE @noRegisters INT;

    -- Since which register start searching the information
    DECLARE @offsetValue INT;

    -- Total pages founded on the query
    DECLARE @totalPages DECIMAL;

    -- LIMIT of registers that can be returned per query
    DECLARE @rowsPerPage INT = 10;

    IF OBJECT_ID(N'tempdb..#tempMovement') IS NOT NULL
        BEGIN
            DROP TABLE #tempMovement
        END

    CREATE TABLE #tempMovement (
        id INT PRIMARY KEY NOT NULL,
        [date] DATETIME NOT NULL,
        reference NVARCHAR(30),
        statusDescription NVARCHAR(256),
        [status] INT,
        checkNumber NVARCHAR(50),
        movementTypeDescription NVARCHAR(256),
        movementType INT,
        concept NVARCHAR(256),
        paymentMethod INT,
        customerAssociated INT,
        residue DECIMAL(14,2),
        asociated DECIMAL(14,2),
        typeAssocitionDescription NVARCHAR(256),
        typeAssociationId INT,
        noMovement INT,
        bankAccount INT,
        amount DECIMAL(14,2),
        currentResidue DECIMAL(14,2)

    )

    INSERT INTO #tempMovement (
        id,
        [date],
        reference,
        statusDescription,
        [status],
        checkNumber,
        movementTypeDescription,
        movementType,
        concept,
        paymentMethod,
        customerAssociated,
        residue,
        asociated,
        typeAssocitionDescription,
        typeAssociationId,
        noMovement,
        bankAccount,
        amount,
        currentResidue
    )

    SELECT 
        movement.MovementID,
        dbo.FormatDateYYYMMDD(movement.movementDate),
        movement.reference,
        movementTypes.[description],
        movement.[status],
        CASE 
            WHEN movement.checkNumber IS NULL THEN ''
            ELSE movement.checkNumber
        END,
        CASE
            WHEN movement.movementType = 1 THEN 'Ingreso'
            ELSE 'Egreso'
        END,
        movement.movementType,
        movement.concept,
        movement.paymentMethod,
        movement.customerAssociated,
        movement.saldo,
        movement.acreditedAmountCalculated,
        movementAssociatios.description,
        movement.movementTypeNumber,
        movement.noMovement,
        movement.bankAccount,
        movement.amount,
        CASE 
            WHEN movement.movementType=1
                THEN 
                    movement.amount + LAG(currentBankResidue,1,account.initialAmount) OVER (ORDER BY movement.noMovement ASC)
            ELSE
                LAG(currentBankResidue,1,account.initialAmount) OVER (ORDER BY movement.noMovement ASC) - movement.amount 
        END AS currentResidue
    FROM Movements AS movement
    LEFT JOIN MovementTypes AS movementTypes ON movementTypes.movementID= movement.[status]
    LEFT JOIN MovementTypeAssociation AS movementAssociatios ON movementAssociatios.id= movement.movementTypeNumber
    LEFT JOIN BankAccounts AS account ON account.bankAccountID=movement.bankAccount
    WHERE movement.[status]!=5 AND movement.bankAccount=@account
    ORDER BY movement.noMovement ASC


    INSERT INTO #tempMovement (
        id,
        [date],
        reference,
        statusDescription,
        [status],
        checkNumber,
        movementTypeDescription,
        movementType,
        concept,
        paymentMethod,
        customerAssociated,
        residue,
        asociated,
        typeAssocitionDescription,
        typeAssociationId,
        noMovement,
        bankAccount,
        amount,
        currentResidue
    )

    SELECT 
        movement.MovementID,
        dbo.FormatDateYYYMMDD(movement.movementDate),
        movement.reference,
        movementTypes.[description],
        movement.[status],
        CASE 
            WHEN movement.checkNumber IS NULL THEN ''
            ELSE movement.checkNumber
        END,
        CASE
            WHEN movement.movementType = 1 THEN 'Ingreso'
            ELSE 'Egreso'
        END,
        movement.movementType,
        movement.concept,
        movement.paymentMethod,
        movement.customerAssociated,
        movement.saldo,
        movement.acreditedAmountCalculated,
        movementAssociatios.description,
        movement.movementTypeNumber,
        movement.noMovement,
        movement.bankAccount,
        movement.amount,
        0 AS currentResidue
    FROM Movements AS movement
    LEFT JOIN MovementTypes AS movementTypes ON movementTypes.movementID= movement.[status]
    LEFT JOIN MovementTypeAssociation AS movementAssociatios ON movementAssociatios.id= movement.movementTypeNumber
    LEFT JOIN BankAccounts AS account ON account.bankAccountID=movement.bankAccount
    WHERE movement.[status]=5 AND movement.bankAccount=@account
    ORDER BY movement.noMovement ASC

    SELECT @noRegisters = COUNT(*)
    FROM #tempMovement
    WHERE
    ([date] >= @beginDate AND  [date] <=@endDate) AND
    bankAccount = @account AND
        (status = @status OR @status IS NULL);
    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;
    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);
    SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters;



    SELECT 
        [date] AS Fecha,
        reference AS Referencia_deposito,
        movementTypeDescription AS [status],
        checkNumber AS Cheque,
        checkNumber AS checkNumber,
        movementTypeDescription AS Tipo_Movimiento,
        movementType AS movementType,
        CASE 
            WHEN movementType = 1 THEN ''
            ELSE dbo.fn_FormatCurrency(amount)
        END AS Egreso,
        CASE 
            WHEN movementType = 0 THEN ''
            ELSE dbo.fn_FormatCurrency(amount)
        END AS Ingreso,
        concept AS Concepto,
        CASE 
            WHEN paymentMethod = NULL THEN CONVERT(NVARCHAR(10),paymentMethod)
            ELSE  ''
        END AS Metodo,
        paymentMethod AS paymentMethod,
        id AS Movimiento,
        FORMAT(noMovement,'0000000') AS Folio,
        status AS statusValue,
        customerAssociated,
        residue AS saldo,
        dbo.fn_RoundDecimals(amount,2) AS [importe.number],
        dbo.fn_FormatCurrency(dbo.fn_RoundDecimals(amount,2)) AS [importe.text],
        dbo.fn_RoundDecimals(residue,2) AS [residue.number],
        dbo.fn_FormatCurrency(dbo.fn_RoundDecimals(residue,2)) AS [residue.text],
        dbo.fn_RoundDecimals(asociated,2) AS [asociado.number],
        dbo.fn_FormatCurrency(dbo.fn_RoundDecimals(asociated,2)) AS [asociado.text],
        typeAssocitionDescription AS [typeAssociation.description],
        typeAssociationId AS [typeAssociation.id]

    FROM #tempMovement

    WHERE 
        bankAccount = @account AND
            ([date]>= @beginDate AND [date]<= @endDate) AND
            ([status] = @status OR @status IS NULL)

        ORDER BY [date] ASC
        OFFSET @offsetValue ROWS
        FETCH NEXT @rowsPerPage ROWS ONLY

        FOR JSON PATH, ROOT('movements'), INCLUDE_NULL_VALUES

    IF OBJECT_ID(N'tempdb..#tempMovement') IS NOT NULL
            BEGIN
                DROP TABLE #tempMovement
            END

    END