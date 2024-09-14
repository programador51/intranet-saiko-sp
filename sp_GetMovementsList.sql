-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-11-2022
-- Description: Obtains the list of the movements of a specific bank account depending on the status (associated, reconciled, etc)
-- STORED PROCEDURE NAME:	sp_GetMovementsList
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
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
--	2022-08-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/11/2022
-- Description: sp_GetMovementsList - Obtains the list of the movements of a specific bank account depending on the status (associated, reconciled, etc)
CREATE PROCEDURE sp_GetMovementsList(
    @bankId INT,
    @bankaccountId INT,
    @idMovementStatus INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
        SELECT  
        movement.MovementID AS [id],
        movement.acreditedAmountCalculated AS [associated.number],
        dbo.fn_FormatCurrency(movement.acreditedAmountCalculated) AS [associated.text],
        ISNULL(movement.checkNumber,'ND') AS [checkNumber],
        movement.concept AS [concept],
        dbo.FormatDate(movement.createdDate) AS [createdDate],
        movement.customerAssociated AS [customerAssociated],
        movement.amount AS [import.number],
        dbo.fn_FormatCurrency(movement.amount) AS [import.text],
        movement.paymentMethod AS [paymentMethod],
        movement.reference AS [reference],
        movement.saldo AS [residue.number],
        dbo.fn_FormatCurrency(movement.saldo) AS [residue.text],
        movement.[status] AS [status.id],
        movementStatus.[description] AS [status.description]
    FROM Movements AS movement
    LEFT JOIN MovementTypes AS movementStatus ON movementStatus.movementID= movement.[status]
    WHERE 
        movement.bankID=@bankId AND 
        movement.bankAccount= @bankaccountId AND 
        movement.[status]=@idMovementStatus
    FOR JSON PATH, ROOT('movement'), INCLUDE_NULL_VALUES;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------