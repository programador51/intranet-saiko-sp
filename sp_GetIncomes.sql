-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-22-2021
-- Description: Gets the incomes
-- STORED PROCEDURE NAME:	sp_GetIncomes
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: Gets the incomes
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-22		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/22/2022
-- Description: sp_GetIncomes Gets the incomes
-- =============================================
CREATE PROCEDURE sp_GetIncomes 

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
   SELECT 
        Incomes.id,
        Incomes.[description] AS incomeDescription,
        IncomesTypes.[description] AS incomeType
    FROM InformativeIncomes AS Incomes 
    LEFT JOIN TypeInformativeIncomes AS IncomesTypes ON Incomes.idTypeInformativeIncomes=IncomesTypes.id
    WHERE Incomes.[status]=1
   
END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------