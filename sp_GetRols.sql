CREATE PROCEDURE sp_GetRols

AS BEGIN

	SELECT rolID,description FROM Roles ORDER BY description ASC

END