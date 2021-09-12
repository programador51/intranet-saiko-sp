-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 12-09-2021

-- Description: Update the documents that are related with an specific document

-- ===================================================================================================================================
-- PARAMETERS:
-- @updatedBy: Fullname of the executive who won the quote

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  12-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateQuoteWon(
    @updatedBy NVARCHAR(30)
)

AS BEGIN

UPDATE Documents SET
    idStatus = 2,
    lastUpdatedBy = @updatedBy,
    lastUpdatedDate = GETDATE()
END