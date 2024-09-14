-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 12-10-2021
-- ************************************************************************************************************************
-- Description: Update the date reminder and expiration date of the quote
-- ************************************************************************************************************************
-- PARAMETERS:
-- @expiration: String date on format yyyy-mm-dd (Just numbers)
-- @reminder: String date on format yyyy-mm-dd (Just number)
-- @id: Id of the quote

-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
 -- ************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  12-10-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************

CREATE PROCEDURE sp_UpdateQuoteDates(
    @expiration DATETIME,
    @reminder DATETIME,
    @id INT
)

AS BEGIN

    UPDATE Documents

    SET
        expirationDate = @expiration,
        reminderDate = @reminder

    WHERE idDocument = @id

END