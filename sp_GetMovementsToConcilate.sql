-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-21-2022
-- Description: Gets the movement to conciliate
-- STORED PROCEDURE NAME:	sp_GetMovementsToConcilate
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-09-21		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/21/2022
-- Description: sp_GetMovementsToConcilate - Gets the movement to conciliate


CREATE PROCEDURE sp_GetMovementsToConcilate(
    @monthDate DATETIME,
    @idAccount INT,
    @pageRequested INT,
    @orderAsc BIT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @beginDate DATETIME;
    DECLARE @endDate DATETIME;

    SELECT 
    @beginDate= DATEADD(DAY,1,EOMONTH(@monthDate,-1)),
    @endDate= EOMONTH(@monthDate);

    DECLARE @noRegisters INT;

    DECLARE @offsetValue INT;

    DECLARE @totalPages DECIMAL;

    DECLARE @rowsPerPage INT = 10;


    IF (@orderAsc=1)
        BEGIN
            SELECT @noRegisters = COUNT(*)
            FROM Movements
            WHERE
            (movementDate >= @beginDate AND  movementDate <=@endDate) AND
            bankAccount = @idAccount;
            SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;
            SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

            SELECT 
                movement.noMovement AS [noMovement],
                dbo.FormatDate(movement.movementDate) AS [movementDate],
                movement.reference AS [reference],
                movement.concept AS [concept],
                CASE 
                    WHEN movement.movementType = 1 THEN ''
                    ELSE dbo.fn_FormatCurrency(ABS(movement.amount))
                END AS [egress.text],
                CASE 
                    WHEN movement.movementType = 1 THEN NULL
                    ELSE ABS(movement.amount)
                END AS [egress.number],
                CASE 
                    WHEN movement.movementType = 0 THEN ''
                    ELSE dbo.fn_FormatCurrency(ABS(movement.amount))
                END AS [ingress.text],
                CASE 
                    WHEN movement.movementType = 0 THEN NULL
                    ELSE ABS(movement.amount)
                END AS [ingress.number],
                99999.99 AS [residue.number],
                '$9,999.99' AS [residue.text],
                movement.[status] AS [status.id],
                movementStatus.[description] AS [status.description]

            FROM  Movements AS movement
            LEFT JOIN MovementTypes AS movementStatus ON movementStatus.movementID =movement.[status]
            WHERE  
                (movementDate >= @beginDate AND  movementDate <=@endDate) AND
                bankAccount = @idAccount
            ORDER BY movement.movementDate ASC,movement.noMovement,movement.[status] ASC
            OFFSET @offsetValue ROWS
            FETCH NEXT @rowsPerPage ROWS ONLY
            FOR JSON PATH,ROOT('movements'), INCLUDE_NULL_VALUES

            
        END
        ELSE
            BEGIN
                SELECT @noRegisters = COUNT(*)
                FROM Movements
                WHERE
                (movementDate >= @beginDate AND  movementDate <=@endDate) AND
                bankAccount = @idAccount;
                SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;
                SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

                SELECT 
                    movement.noMovement AS [noMovement],
                    dbo.FormatDate(movement.movementDate) AS [movementDate],
                    movement.reference AS [reference],
                    movement.concept AS [concept],
                    CASE 
                        WHEN movement.movementType = 1 THEN ''
                        ELSE dbo.fn_FormatCurrency(ABS(movement.amount))
                    END AS [egress.text],
                    CASE 
                        WHEN movement.movementType = 1 THEN NULL
                        ELSE ABS(movement.amount)
                    END AS [egress.number],
                    CASE 
                        WHEN movement.movementType = 0 THEN ''
                        ELSE dbo.fn_FormatCurrency(ABS(movement.amount))
                    END AS [ingress.text],
                    CASE 
                        WHEN movement.movementType = 0 THEN NULL
                        ELSE ABS(movement.amount)
                    END AS [ingress.number],
                    99999.99 AS [residue.number],
                    '$9,999.99' AS [residue.text],
                    movement.[status] AS [status.id],
                    movementStatus.[description] AS [status.description]

                FROM  Movements AS movement
                LEFT JOIN MovementTypes AS movementStatus ON movementStatus.movementID =movement.[status]
                WHERE  
                    (movementDate >= @beginDate AND  movementDate <=@endDate) AND
                    bankAccount = @idAccount
                ORDER BY movement.movementDate DESC,movement.noMovement,movement.[status] DESC
                OFFSET @offsetValue ROWS
                FETCH NEXT @rowsPerPage ROWS ONLY
                FOR JSON PATH,ROOT('movements'), INCLUDE_NULL_VALUES

                
            END

            SELECT
                @totalPages AS pages,
                @pageRequested AS actualPage,
                @noRegisters AS noRegisters;

    -- SELECT TOP(1) amount AS initialAmount FROM MonthConsilation WHERE idAccount=@idAccount ORDER BY id DESC

    

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------