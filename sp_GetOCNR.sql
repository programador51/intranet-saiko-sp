-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 13-10-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetOCNR
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
--	2023-13-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 13/10/2023
-- Description: sp_GetOCNR - Some Notes
CREATE PROCEDURE sp_GetOCNR(
    @year INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        MONTH(ocnr.recordDate) AS recordMonth,
        ocnr.mxnTotal,
        ocnr.usdTotal,
        ocnr.tc,
        ocnr.total,
        accounted.accounted
    FROM SummaryOCNR AS ocnr
    LEFT JOIN Accounted AS accounted ON accounted.idRecord=ocnr.id
    WHERE 
        accounted.idFrom= 3 AND
        YEAR(recordDate)=@year

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------