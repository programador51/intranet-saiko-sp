-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date:11-09-2022
-- Description: Get all the clients 
-- STORED PROCEDURE NAME:	sp_GetAllCustomerClients
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-11-09		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 11/09/2022
-- Description: sp_GetAllCustomerClients - Get all the clients
CREATE PROCEDURE sp_GetAllCustomerClients(
    @pageRequested INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    -- Number of registers founded
    DECLARE @noRegisters INT;

    -- Since which register start searching the information
    DECLARE @offsetValue INT;

    -- Total pages founded on the query
    DECLARE @totalPages DECIMAL;

    -- LIMIT of registers that can be returned per query
    DECLARE @rowsPerPage INT = 10;

    
    SELECT 
        @noRegisters = COUNT(*) 
    FROM Customers
    WHERE Customers.customerType IN(1,5) 

    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;

    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    SELECT
        @totalPages AS pages,
        @pageRequested AS actualPage,
        @noRegisters AS noRegisters;

    SELECT
		Customers.customerID AS Cliente_id,
		Customers.socialReason AS Razon_social,
		Customers.commercialName AS Nombre_comercial,
		Customers.shortName AS Nombre_corto,
		Customers.phone AS Telefono_sin_lada,
		Customers.ladaPhone AS Lada_telefono,
		Customers.movil AS Movil_sin_lada,
		Customers.rfc AS RFC,
		Customers.email AS Correo,
		Customers.creditDays AS Dias_credito,
		Customers.ladaMovil AS Lada_movil,
		Customers.corporative AS Corporativo,
		
		CONCAT(SUBSTRING(Users.firstName,0,2),SUBSTRING(Users.lastName1,0,2),SUBSTRING(Users.lastName2,0,2)) AS Ejecutivo_Abreviado,
		
		CASE WHEN
			Customers.status = 1 THEN 'Activo'
			ELSE 'Inactivo'
		END AS Estatus_Descripcion,
		
		CONCAT('+',Customers.ladaPhone,' ',Customers.phone) AS Telefono,
		CONCAT('+',Customers.ladaMovil,' ',Customers.movil) AS Movil,
		Customers.status AS Estatus_cliente,
		Customers.customerType AS Customers_Tipo_Cliente,
		Customer_Executive.customerID,
		Customer_Executive.executiveID,
		Customer_Executive.createdBy AS Asociado_por,
		Customer_Executive.createdDate  AS Asociado_el,
		Customer_Executive.lastUpdatedBy AS Actualizado_por,
		Customer_Executive.lastUpdatedDate AS Actualizado_el,
		Users.firstName,
		Users.middleName,
		Users.lastName1,
		Users.lastName2,
		CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS Ejecutivo,
		Users.userID AS ID_Ejecutivo,
		CustomerTypes.customerTypeID AS ID_tipo_cliente,
		CustomerTypes.description AS Tipo_cliente
    FROM Customers
    JOIN Customer_Executive ON Customers.customerID = Customer_Executive.customerID
    JOIN Users ON Customer_Executive.executiveID = Users.userID
    JOIN CustomerTypes ON Customers.customerType = CustomerTypes.customerTypeID
    WHERE Customers.customerType IN(1,5) 
    ORDER BY Customers.customerID DESC OFFSET @offsetValue ROWS  FETCH NEXT @rowsPerPage ROWS ONLY

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------