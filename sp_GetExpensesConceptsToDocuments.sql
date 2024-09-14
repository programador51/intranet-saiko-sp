-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-22-2023
-- Description: Get the concepts for the documents type expenses
-- STORED PROCEDURE NAME:	sp_GetExpensesConceptsToDocuments
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2023-02-22		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/22/2023
-- Description: sp_GetExpensesConceptsToDocuments - Get the concepts for the documents type expenses
CREATE PROCEDURE sp_GetExpensesConceptsToDocuments
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT
        expenses.id,
        CONCAT(infoType.[description],' ',expenses.[description]) AS [description],
        expenses.defaultToDocument
    FROM InformativeExpenses AS expenses
        LEFT JOIN InformativeExpenses AS infoType ON infoType.id=expenses.idTypeInformativeExpenses
    WHERE expenses.isForDocuments=1

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------