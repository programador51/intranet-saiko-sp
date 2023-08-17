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


    SELECT @noRegisters = COUNT(*)
    FROM Movements
    WHERE
    (movementDate >= @beginDate AND  movementDate <=@endDate) AND
    bankAccount = @account AND
        (status = @status OR @status IS NULL);
    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;
    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);
    SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters;



    SELECT 
        dbo.FormatDateYYYMMDD(movement.movementDate) AS Fecha,
        movement.reference AS Referencia_deposito,
        movementTypes.[description] AS [status],
        movement.checkNumber AS Cheque,
        movement.checkNumber AS checkNumber,
        movementTypes.[description] AS Tipo_Movimiento,
        movement.movementType AS movementType,
        CASE 
            WHEN movement.movementType = 1 THEN ''
            ELSE dbo.fn_FormatCurrency(ABS(amount))
        END AS Egreso,
        CASE 
            WHEN movement.movementType = 0 THEN ''
            ELSE dbo.fn_FormatCurrency(ABS(amount))
        END AS Ingreso,
        concept AS Concepto,
        CASE 
            WHEN movement.paymentMethod = NULL THEN CONVERT(NVARCHAR(10),movement.paymentMethod)
            ELSE  ''
        END AS Metodo,
        movement.paymentMethod AS paymentMethod,
        movement.MovementID Movimiento,
        FORMAT(movement.noMovement,'0000000') AS Folio,
        movement.[status] AS statusValue,
        movement.customerAssociated,
        movement.saldo AS saldo,
        dbo.fn_RoundDecimals(ABS(amount),2) AS [importe.number],
        dbo.fn_FormatCurrency(dbo.fn_RoundDecimals(ABS(amount),2)) AS [importe.text],
        dbo.fn_RoundDecimals(movement.saldo,2) AS [residue.number],
        dbo.fn_FormatCurrency(dbo.fn_RoundDecimals(movement.saldo,2)) AS [residue.text],
        dbo.fn_RoundDecimals(movement.acreditedAmountCalculated,2) AS [asociado.number],
        dbo.fn_FormatCurrency(dbo.fn_RoundDecimals(movement.acreditedAmountCalculated,2)) AS [asociado.text],
        movementAssociatios.description AS [typeAssociation.description],
        movementAssociatios.id AS [typeAssociation.id]
        -- currentResidue AS [bank.residue.number],
        -- dbo.fn_FormatCurrency(currentResidue) AS [bank.residue.text]

    FROM Movements AS movement
    LEFT JOIN MovementTypes AS movementTypes ON movementTypes.movementID= movement.[status]
    LEFT JOIN MovementTypeAssociation AS movementAssociatios ON movementAssociatios.id= movement.movementTypeNumber
    LEFT JOIN BankAccounts AS account ON account.bankAccountID=movement.bankAccount

    WHERE 
        bankAccount = @account AND
            (movement.movementDate>= @beginDate AND movement.movementDate<= @endDate) AND
            (movement.[status] = @status OR @status IS NULL)

        ORDER BY movement.movementDate ASC
        OFFSET @offsetValue ROWS
        FETCH NEXT @rowsPerPage ROWS ONLY

        FOR JSON PATH, ROOT('movements'), INCLUDE_NULL_VALUES


    END
