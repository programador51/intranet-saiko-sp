-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-27-2021

-- Description: Get the information of an specific movement

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @movId: Concept of the movement created

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  2021-07-27      Jose Luis Perez             1.0.0.0         Creation of query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetMovement(
    @movId INT
)

AS BEGIN

SELECT 
        
    CONVERT(VARCHAR(10),Movements.movementDate,105) AS registerDate,
    Movements.movementType,
    Movements.movementTypeNumber,
    Movements.reference,
    Movements.checkNumber,
    Movements.concept,
    Movements.amount,
    Movements.status,
    Movements.customerAssociated,
    Movements.MovementID,
    Movements.paymentMethod
        
FROM Movements WHERE MovementID = @movId

END