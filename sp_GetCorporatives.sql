-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--
--	STORED PROCEDURE NAME:	sp_GetCorporatives 
--
--	DESCRIPTION:			This SP retrieves the Customers list with a given range and number of records
--
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ==================================================================================================================================================
--	2021-10-21		Iván Díaz   				1.0.0.0			Initial Revision		
-- **************************************************************************************************************************************************



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
