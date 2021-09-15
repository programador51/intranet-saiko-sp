-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-27-2021

-- Description: Fetch the list of movements from an "x" page requested.
-- filtering by a range date

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @bankAccount: Concept of the movement created
-- @beginDate: Date must be range begin in order to filter
-- @endDate: Date must be the range date in order to filter
-- @rangeBegin: Since which row start bringing the data
-- @noRegisters: How many rows select since the "rangeBegin"

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  2021-07-27      Jose Luis Perez             1.0.0.0         Creation of query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetMovements(
  @bankAccount INT,
  @beginDate NVARCHAR(15),
  @endDate NVARCHAR(15)
  @rangeBegin INT,
  @noRegisters INT
)

AS BEGIN

SELECT
            
    CONVERT(VARCHAR(10),Movements.movementDate,105) AS Fecha,

    CASE WHEN
        Movements.reference IS NULL THEN ''
        ELSE Movements.reference
    END AS Referencia_deposito,

    CASE WHEN
        Movements.status = 1 THEN 'Activo'
        ELSE 'Cancelado'
    END AS Estatus,

    CASE WHEN
        Movements.checkNumber IS NULL THEN ''
        ELSE Movements.checkNumber
    END AS Cheque,

    Movements.checkNumber,

    CASE WHEN
        Movements.movementType = 1 THEN 'Ingreso'
        ELSE 'Egreso'
    END AS Tipo_Movimiento,

    Movements.movementType,

    CASE WHEN
        Movements.movementType = 1 THEN ''
        ELSE CONVERT(NVARCHAR(100),Movements.amount)
    END AS Egreso,

    CASE WHEN 
        Movements.movementType = 0 THEN ''
        ELSE CONVERT(NVARCHAR(100),Movements.amount)
    END AS Ingreso,

    Movements.concept AS Concepto,

    CASE WHEN
        Movements.paymentMethod = NULL THEN CONVERT(NVARCHAR(10),Movements.paymentMethod)
        ELSE  ''
    END AS Metodo,

    Movements.paymentMethod,

    CONVERT(INT,Movements.MovementID) AS Movimiento,

    Movements.status AS statusValue,
    Movements.customerAssociated

FROM Movements

WHERE 
    bankAccount = @bankAccount AND
    CONVERT(DATETIME,@beginDate,102)  <= movementDate AND
    CONVERT(DATETIME,@endDate,102) >= (movementDate-1)

ORDER BY MovementID DESC

OFFSET @rangeBegin ROWS
FETCH NEXT @noRegisters ROWS ONLY

END