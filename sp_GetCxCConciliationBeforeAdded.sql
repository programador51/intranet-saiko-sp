-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-25-2022
-- Description: Obtains the reconciliation of the movements before they are updated
-- STORED PROCEDURE NAME:	GetCxCConciliationBeforeAdded
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-08-25		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/25/2022
-- Description: sp_GetCxCConciliationBeforeAdded - Obtains the reconciliation of the movements before they are updated
CREATE PROCEDURE sp_GetCxCConciliationBeforeAdded(
    @idMovement INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        conciliation.idCxC,
        conciliation.tcConcilation,
        conciliation.amountPaid,
        conciliation.totalAmount,
        conciliation.amountToPay,
        conciliation.newAmount,
        conciliation.amountAccumulated,
        conciliation.createdBy,
        conciliation.createdDate,
        conciliation.updatedBy,
        conciliation.updatedDate,
        conciliation.[status],
        conciliation.uuid,
        conciliation.idMovement,
        conciliation.amountApplied,
        cxc.idInvoice AS [invoice.id]
    FROM ConcilationCxC AS conciliation
    
    LEFT JOIN Documents AS cxc ON cxc.idDocument= conciliation.idCxC
    WHERE idMovement=@idMovement AND [status]=1
    FOR JSON PATH,ROOT('cxcBefore')

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------