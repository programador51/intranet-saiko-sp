-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 01-29-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetCashFlowV2
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
--	2024-01-29		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCashFlowV2')
    BEGIN 

        DROP PROCEDURE sp_GetCashFlowV2;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 01/29/2024
-- Description: sp_GetCashFlowV2 - Some Notes
CREATE PROCEDURE sp_GetCashFlowV2(
    @currencyIWant NVARCHAR(3),
    @currencyToShow NVARCHAR(3),
    @tc DECIMAL (14,4)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    EXEC sp_GetBankResiduePrediction @currencyIWant, @currencyToShow, @tc
    EXEC sp_GetCxcPrediction @currencyIWant, @currencyToShow, @tc
    EXEC sp_GetCxpCashFlowV2 @currencyIWant, @currencyToShow, @tc

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------