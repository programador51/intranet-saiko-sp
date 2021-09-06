-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Fetch the type documents existing on the system.
-- It's use for the select to chose a type document

-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  2021-07-26      Jose Luis Perez             1.0.0.1         Creation of query for revision		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetTypeDocuments

AS BEGIN

SELECT 
    documentTypeID,
    description

FROM DocumentTypes

END