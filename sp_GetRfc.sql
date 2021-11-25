-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 15-09-2021

-- Description: Check if an specific rfc already exists. (Validate)

-- ===================================================================================================================================
-- PARAMETERS:
-- @rfcToCheck: RFC to find on the system to check if it's repeated

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  15-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
--  25-11-2021     Jose Luis Perez             1.0.0.1         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetRfc(
    @rfcToCheck NVARCHAR(30)
)

AS BEGIN

    -- SELECT
	--     rfc 

    -- FROM Customers

    -- WHERE
    --     rfc = @rfc AND
    --     rfc != 'XAXX010101000';

    DECLARE @rfcFounded NVARCHAR(30);

    SELECT
        @rfcFounded = rfc 

    FROM Customers

    WHERE
        rfc = @rfcToCheck AND
        rfc != 'XAXX010101000';

    SET @rfcFounded = ISNULL(DATALENGTH(@rfcFounded) - DATALENGTH(@rfcFounded) + 1,0);

    SELECT CONVERT(BIT,@rfcFounded) AS rfcRepeated;

END