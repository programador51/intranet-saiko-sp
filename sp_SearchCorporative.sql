CREATE PROCEDURE sp_SearchCorporative(

	@rangeBegin INT,
	@noRegisters INT,
	@search NVARCHAR(100)

)

AS BEGIN

SELECT 

	socialReason AS Razon_social,
	rfc AS RFC,
	commercialName AS Nombre_comercial,
	shortName AS Nombre_corto,
	customerID AS ID_cliente

	FROM Customers

	WHERE 
		socialReason LIKE @search OR
		rfc LIKE @search OR
		commercialName LIKE @search OR
		shortName LIKE @search

	ORDER BY customerID

	OFFSET @rangeBegin ROWS 
	FETCH NEXT @noRegisters ROWS ONLY 

END