-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-30-2022
-- Description: obtains the minimum exchange rate allowed and the partial payments allowed
-- STORED PROCEDURE NAME:	sp_GetMinTcAndPartialitiesAllowed
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- minTc
-- currentTc
-- tcRate
-- partialitiesAllowed
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-06-30		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/30/2022
-- Description: sp_GetMinTcAndPartialitiesAllowed Obtains the minimum exchange rate allowed and the partial payments allowed
CREATE PROCEDURE sp_GetMinTcAndPartialitiesAllowed AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @currentTc DECIMAL (14,2);
    DECLARE @tcRate DECIMAL (14,2);

    DECLARE @minTCAllowed DECIMAL (14,2);
    DECLARE @partialitiesAllowed INT;

    SELECT TOP 1 @currentTc=saiko FROM TCP ORDER BY id DESC 

    SELECT 
        @tcRate= CAST([value] AS DECIMAL (14,2))
    FROM Parameters WHERE parameter= 23

    SELECT @minTCAllowed = @currentTc - @tcRate

    SELECT @partialitiesAllowed=CAST ([value] AS INT) FROM Parameters WHERE parameter= 22

    SELECT @minTCAllowed AS minTc, @currentTc AS currentTc, @tcRate AS tcRate, @partialitiesAllowed AS partialitiesAllowed


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------