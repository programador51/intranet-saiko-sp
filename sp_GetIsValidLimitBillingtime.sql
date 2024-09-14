-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-29-2022
-- Description: Valid if the invoice deadline is valid
-- STORED PROCEDURE NAME:	sp_GetIsValidLimitBillingtime
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: the document Id
-- @isValidlimitBillingTime BIT OUTPUT: return
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @isValidlimitBillingTime 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-06-29		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/29/2022
-- Description: sp_GetIsValidLimitBillingtime - Valid if the invoice deadline is valid
CREATE PROCEDURE sp_GetIsValidLimitBillingtime(
    @documentId INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @isValidlimitBillingTime BIT
    SELECT 
        @isValidlimitBillingTime =
            CASE
                WHEN limitBillingTime IS NULL THEN 1
                WHEN limitBillingTime <GETUTCDATE() THEN 1
                ELSE 0
            END
    FROM Documents WHERE idDocument= @documentId
    RETURN @isValidlimitBillingTime
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------