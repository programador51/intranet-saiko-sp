-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 22-12-2021
-- Description: Update the movement status
-- STORED PROCEDURE NAME:	sp_UpdateMovementStatus
-- ===============================================================================================================================
-- PARAMETERS:
-- @idMovement: Id of the movement to update
-- @idStatus: Id of the new status to set on the movement
-- ===============================================================================================================================
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ===============================================================================================================================
--	22-12-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

-- ================================== FOLLOWING RESULT ===========================================================================

CREATE PROCEDURE sp_UpdateMovementStatus(
    @idMovement INT,
    @idStatus INT
)

AS
BEGIN

    SELECT status AS oldStatus
    FROM Movements
    WHERE MovementID = @idMovement;
    UPDATE Movements SET status = @idStatus WHERE MovementID = @idMovement;

END