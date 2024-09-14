-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-11-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetCashFlow
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
--	2023-07-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/11/2023
-- Description: sp_GetCashFlow - Some Notes
CREATE PROCEDURE sp_GetCashFlow(
    @currencyIWant NVARCHAR(3),
    @currencyToShow NVARCHAR(3),
    @tc DECIMAL (14,2)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    EXEC sp_GetBankResiduePrediction @currencyIWant, @currencyToShow, @tc
    EXEC sp_GetCxcPrediction @currencyIWant, @currencyToShow, @tc
    EXEC sp_GetCxpPrediction @currencyIWant, @currencyToShow, @tc

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------