-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: This will fetch the list of banks. It's used
-- on many screens to associate a bank 

-- STORED PROCEDURE NAME:	sp_GetSelectBank
-- STORED PROCEDURE OLD NAME: sp_SelectBank

-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetSelectBank

AS BEGIN

SELECT 
	shortName AS label,
	bankID AS value,
	socialReason AS social_reason,
	commercialName AS commercial_name
    
	FROM Banks
    ORDER BY shortName

END