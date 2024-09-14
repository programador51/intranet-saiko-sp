-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 20-12-2021
-- Description: Update the amounts of the movements when an association was made
-- STORED PROCEDURE NAME:	sp_UpdateMovementAmounts
-- ===============================================================================================================================
-- PARAMETERS:
-- @idCustomer: Id of the customer which will be associated that movement
-- @idMovement: Id of the movement
-- @status: Status will have the movement
-- @residue: "Saldo" remaining to keep doing more "associations"
-- ===============================================================================================================================
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ===============================================================================================================================
--	20-12-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_UpdateMovementAmounts(
    @idCustomer INT,
    @idMovement INT,
    @status TINYINT,
    @residue DECIMAL(14,4)
)

AS
BEGIN

    UPDATE Movements SET
    customerAssociated = @idCustomer,
    saldo = @residue,
    status = @status
    WHERE MovementID = @idMovement

END