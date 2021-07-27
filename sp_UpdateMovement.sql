-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-27-2021

-- Description: Update the information of a movement

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @concept: Concept of the movement created
-- @check: Check id of the movement
-- @id_movement: ID of the movement to edit
-- @payMethod (FK): Pay method of the movement
-- @reference: Reference of the movement
-- @registerDate: Date it corresponds the movement, format YYYY-MM-DD
-- @modifiedBy: First name, middlename and lastName1

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  2021-07-27      Jose Luis Perez             1.0.0.0         Creation of query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateMovement(
    @concept NVARCHAR(256),
    @check NVARCHAR(50),
    @id_movement INT,
    @payMethod INT,
    @reference NVARCHAR(30),
    @registerDate NVARCHAR(15),
    @modifiedBy NVARCHAR(30)
)

AS BEGIN

UPDATE Movements
    SET
        concept = @concept,
        checkNumber = @check,
        paymentMethod = @payMethod,
        reference = @reference,
        movementDate = CONVERT(DATETIME,@registerDate,102),
        lastUpdatedDate = GETDATE(),
        lastUpdatedBy = @modifiedBy

    WHERE MovementID = @id_movement

END