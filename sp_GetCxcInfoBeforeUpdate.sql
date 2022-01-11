-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 20-12-2021
-- Description: Get the information of the CxC before update the information (in case something fails for the next updates)
-- STORED PROCEDURE NAME:	sp_GetCxcInfoBeforeUpdate
-- ===============================================================================================================================
-- PARAMETERS:
-- @idCxc: Id of the CxC to retrieve the info
-- ===============================================================================================================================
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ===============================================================================================================================
--	08-10-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************
CREATE PROCEDURE sp_GetCxcInfoBeforeUpdate(
    @idCxc INT
)

AS
BEGIN
    SELECT
        totalAcreditedAmount AS oldAcreditedAmount ,
        idStatus AS oldIdStatus,
        amountToPay AS oldAmountToPay,
        idDocument AS idCxc
    FROM Documents
    WHERE idDocument = @idCxc
END