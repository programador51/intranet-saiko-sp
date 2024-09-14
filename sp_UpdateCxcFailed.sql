-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 20-12-2021
-- Description: Update the amounts of the CxC in case the association of the movement was failed
-- STORED PROCEDURE NAME:	sp_UpdateCxcFailed
-- ===============================================================================================================================
-- PARAMETERS:
-- @totalAcreditedAmount: Old acredited amount before the update
-- @idStatus: Old id status before the update
-- @amountToPay: Old amount to pay before the update
-- @idDocument: Id of the CxC to "reverse"
-- ===============================================================================================================================
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ===============================================================================================================================
--	20-12-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************
CREATE PROCEDURE sp_UpdateCxcFailed(
    @totalAcreditedAmount DECIMAL(14,4),
    @idStatus INT,
    @amountToPay DECIMAL(14,4),
    @idDocument INT
)

AS
BEGIN

    UPDATE Documents SET 
        totalAcreditedAmount = @totalAcreditedAmount , 
        idStatus = @idStatus,
        amountToPay = @amountToPay

        WHERE idDocument = @idDocument

END
