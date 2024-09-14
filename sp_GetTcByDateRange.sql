-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-02-2023
-- Description: Get the tc by range of dates
-- STORED PROCEDURE NAME:	sp_GetTcByDateRange
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
--	2023-08-02		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/02/2023
-- Description: sp_GetTcByDateRange - Some Notes
-- DROP PROCEDURE sp_Nsp_GetTcByDatesame
CREATE PROCEDURE sp_GetTcByDateRange(
    @beginDate DATETIME,
    @endDate DATETIME
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    SELECT     
    createdBy AS createdBy,
          dbo.FormatDate(date) AS [date.formated],
          dbo.FormatDateYYYMMDD(date) AS [date.yyyymmdd],
          date AS [date.full],
          dbo.fn_FormatCurrency(fix) AS [fix.text],
          fix AS [fix.number],
          dof AS [dof.number],
          dbo.fn_FormatCurrency(dof) AS [dof.text],
          pays AS [pays.number],
          dbo.fn_FormatCurrency(pays) AS [pays.text],
          purchase AS [purchase.number],
          dbo.fn_FormatCurrency(purchase) AS [purchase.text],
          sales AS [sales.number],
          dbo.fn_FormatCurrency(sales) AS [sales.text],
          saiko AS [enterprise.number],
          dbo.fn_FormatCurrency(saiko) AS [enterprise.text]
  
    
     FROM TCP
   WHERE 
    CAST([date] AS Date)>= CAST(@beginDate AS DATE) AND
    CAST([date] AS Date)<= CAST(@endDate AS DATE)
   ORDER BY id DESC
   FOR JSON PATH, ROOT('documents');

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------