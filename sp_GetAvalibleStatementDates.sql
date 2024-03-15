-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 11-10-2023
-- Description: Get the avalible dates for download the bank statement
-- STORED PROCEDURE NAME:	sp_GetAvalibleStatementDates
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
--	2023-11-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 11/10/2023
-- Description: sp_GetAvalibleStatementDates - Get the avalible dates for download the bank statement
CREATE PROCEDURE sp_GetAvalibleStatementDates(
    @idBankAccount INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    SELECT 
        YEAR(movementDate) AS año,
        MONTH(movementDate) AS mes,
        CONCAT(YEAR(movementDate),'-',MONTH(movementDate)) AS yearMonth
    FROM Movements
    WHERE 
        [status]!= 0 AND
        bankAccount= @idBankAccount
    GROUP BY 
        YEAR(movementDate),
        MONTH(movementDate)
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------