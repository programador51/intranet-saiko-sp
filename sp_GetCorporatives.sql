CREATE PROCEDURE sp_GetCorporatives(

	@rangeBegin INT,
	@noRegisters INT

)

AS BEGIN

SELECT 
        
        socialReason AS Razon_social,
        rfc AS RFC,
        commercialName AS Nombre_comercial,
        shortName AS Nombre_corto,
        customerID AS ID_cliente
        
        FROM Customers

        ORDER BY customerID

        OFFSET @rangeBegin ROWS 
        FETCH NEXT @noRegisters ROWS ONLY 

END