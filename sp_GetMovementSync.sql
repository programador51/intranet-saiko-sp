-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 20-12-2021
-- Description: Check if the information of the movement it's sync before perform the querys
-- STORED PROCEDURE NAME: sp_GetMovementSync
-- ===============================================================================================================================
-- PARAMETERS:
-- @reduce: "Saldo" remaining when trying to insert the information
-- @idMovement:  Id of the movement to check
-- ===============================================================================================================================
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ===============================================================================================================================
--	20-12-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_GetMovementSync(
    @reduce DECIMAL(14,2),
    @idMovement INT
)

AS
BEGIN
    DECLARE @saldo DECIMAL(14,2);
    SELECT @saldo = saldo
    FROM Movements
    WHERE MovementID = @idMovement;

    SELECT
        CASE WHEN @saldo != @reduce THEN CONVERT(BIT,0)

    ELSE CONVERT(BIT,1) END AS isSyncReduce,
        @saldo AS saldo;
END