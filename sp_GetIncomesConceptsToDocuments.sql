-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-22-2023
-- Description: Get the concepts for the documents type incomes
-- STORED PROCEDURE NAME:	sp_GetIncomesConceptsToDocuments
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
-- Description: sp_GetIncomesConceptsToDocuments - Get the concepts for the documents type incomes
CREATE PROCEDURE sp_GetIncomesConceptsToDocuments AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        incomes.id,
        CONCAT(infoType.[description],' ',incomes.[description]) AS [description],
        incomes.defaultToDocument
    FROM InformativeIncomes AS incomes
    LEFT JOIN TypeInformativeIncomes AS infoType ON infoType.id=incomes.idTypeInformativeIncomes
    WHERE isForDocuments=1

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------