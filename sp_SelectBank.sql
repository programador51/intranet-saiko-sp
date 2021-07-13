CREATE PROCEDURE sp_SelectBank

AS BEGIN

SELECT 
	shortName AS label,
	bankID AS value,
	socialReason AS social_reason,
	commercialName AS commercial_name
    
	FROM Banks
    ORDER BY shortName

END