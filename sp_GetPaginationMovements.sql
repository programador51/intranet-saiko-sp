-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-27-2021

-- Description: Counts how many rows contain the table Movements
-- to calculate the "number of pages" that are on movements, according
-- to the range filter.

-- **************************************************************************************************************************************************

-- =============================================
-- PARAMETERS:
-- @bankAccount (PK): ID of the bank account interested of fetch the movements
-- @noRegisters: How many register bring since the "rangeBegin". For instnace, bring the next 20 registers
-- @search: Text search that must be like the rows to fetch
-- =============================================

--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  2021-07-27      Jose Luis Perez             1.0.0.0         Creation of query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetPaginationMovements(
    @bankAccount INT,
    @beginDate NVARCHAR(15),
    @endDate NVARCHAR(15)
)

AS BEGIN

SELECT COUNT(*) 
            
FROM Movements

WHERE 
    bankAccount = @bankAccount AND
    CONVERT(DATETIME,@beginDate,102)  <= movementDate AND
    CONVERT(DATETIME,@endDate,102) >= (movementDate-1)     

END