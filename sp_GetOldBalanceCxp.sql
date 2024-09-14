-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-11-2023
-- Description: Get the old balances from de cxp
-- STORED PROCEDURE NAME:	sp_GetOldBalanceCxp
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
--	2023-09-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/11/2023
-- Description: sp_GetOldBalanceCxp - Get the old balances from de cxp
CREATE PROCEDURE sp_GetOldBalanceCxp(
    @currencyToUse NVARCHAR(3),
    @currencyToReport NVARCHAR(3),
    @tc DECIMAL (14,2)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    EXEC sp_GetOldBalancesProviders @currencyToUse, @currencyToReport,@tc
    EXEC sp_GetOldBalanceVoucher @currencyToUse, @currencyToReport,@tc

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------