-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-23-2022
-- Description: Get all the informative incomes
-- STORED PROCEDURE NAME:	sp_GetInformativeIncomes
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
--	2022-03-23		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/23/2022
-- Description: sp_GetInformativeIncomes - Get all the informative incomes
CREATE PROCEDURE sp_GetInformativeIncomes AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
    InformativeIncomes.id AS [id],
    InformativeIncomes.[description],
    Currencies.code AS [currency.code],
    Currencies.symbol AS [currency.symbol],
    Currencies.[description] AS [currency.description],
    TypeInformativeIncomes.[description] AS [type.description],
    TypeInformativeIncomes.[id] AS [type.id],
    '$0.00' AS [applied.text],
    0 AS [applied.number],
    '$0.00' AS [importe.text],
    0 AS [importe.number],
    '$0.00' AS [tc.text],
    0 AS [tc.number]


 FROM InformativeIncomes
 LEFT JOIN Currencies ON  Currencies.currencyID=InformativeIncomes.currency
 LEFT JOIN TypeInformativeIncomes ON TypeInformativeIncomes.id=InformativeIncomes.idTypeInformativeIncomes


FOR JSON PATH, ROOT('InformativeIncomes')

END