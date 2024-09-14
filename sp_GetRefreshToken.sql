-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 14-12-2021
-- Description: Get a true or false if the refresh token was founded
-- STORED PROCEDURE NAME:	sp_GetRefreshToken
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @refreshToken: Refresh token to search
-- *******************************************************************************************************************************
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	14-12-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_GetRefreshToken(
    @refreshToken NVARCHAR(300)
)

AS
BEGIN

    SELECT CONVERT(BIT,COUNT(*))
    FROM RefreshTokens
    WHERE refreshToken = @refreshToken;
END