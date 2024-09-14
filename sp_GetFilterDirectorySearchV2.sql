-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Fetch the directory according to the filters and text typed
-- that the user it's requesting by

-- STORED PROCEDURE NAME:	sp_GetFilterDirectorySearch
-- STORED PROCEDURE OLD NAME: sp_FilterDirectorySearch

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @type: ID of the type of customer to fetch
-- @status: 1 active and 0 inactive customer
-- @executive: ID of the executive that attends the customer
-- @orderingColumn: 'pk' at level code in order to know which column use to order the data
-- @orderingCriterian: DESC or ASC ordering
-- @rangeBegin: Since which row start bringing the data
-- @noRegisters: How many rows select since the "rangeBegin"
-- @search: Text that the user it's looking for
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
--  2021-12-28      Adran Alardin Iracheta      2.0.0.0         Fixed: Get all the suppliers clients/suppliers			
-- *****************************************************************************************************************************


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetFilterDirectorySearch (

	@type INT,
	@status TINYINT,
	@executive INT,
	@orderingColumn NVARCHAR,
	@orderingCriterian NVARCHAR,
	@rangeBegin INT,
	@noRegisters INT,
	@search VARCHAR (50)

)

AS BEGIN

IF(@type=1)
	BEGIN
		SELECT
			Customers.customerID AS Cliente_id,
			Customers.socialReason AS Razon_social,
			Customers.commercialName AS Nombre_comercial,
			Customers.shortName AS Nombre_corto,
			Customers.movil AS Movil_sin_lada,
			Customers.rfc AS RFC,
			Customers.email AS Correo,
			Customers.creditDays AS Dias_credito,
			Customers.phone AS Telefono_sin_lada,
			Customers.ladaPhone AS Lada_telefono,
			Customers.ladaMovil AS Lada_movil,
			Customers.corporative AS Corporativo,

			CONCAT(SUBSTRING(Users.firstName,0,2),SUBSTRING(Users.lastName1,0,2),SUBSTRING(Users.lastName2,0,2)) AS Ejecutivo_Abreviado,

			CASE WHEN
				Customers.status = 1 THEN 'Activo'
				ELSE 'Inactivo'
			END AS Estatus_Descripcion,

			CONCAT(ladaPhone,' ',phone) AS Telefono,
			CONCAT(ladaMovil,' ',movil) AS Movil,
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
			JOIN CustomerTypes on Customers.customerType = CustomerTypes.customerTypeID

			WHERE

			((Customers.socialReason LIKE '%' + @search + '%') OR
			(Customers.commercialName LIKE '%' + @search + '%') OR
			(Customers.shortName LIKE '%' + @search + '%') OR
			(Users.firstName LIKE '%' + @search + '%') OR
			(Users.middleName LIKE '%' + @search + '%') OR
			(Users.lastName1 LIKE '%' + @search + '%') OR
			(Users.lastName2 LIKE '%' + @search + '%') OR
			(Customers.movil LIKE '%' + @search + '%') OR
			(Customers.phone LIKE '%' + @search + '%')) AND
			(Customers.status = @status OR @status IS NULL) AND
			(Customer_Executive.executiveID = @executive) AND
			(Customers.customerType = @type)
						

			ORDER BY Customers.customerID DESC
		
		OFFSET @rangeBegin ROWS 
		FETCH NEXT @noRegisters ROWS ONLY

	END
	ELSE IF (@type IS NULL)
	BEGIN
		SELECT
			Customers.customerID AS Cliente_id,
			Customers.socialReason AS Razon_social,
			Customers.commercialName AS Nombre_comercial,
			Customers.shortName AS Nombre_corto,
			Customers.movil AS Movil_sin_lada,
			Customers.rfc AS RFC,
			Customers.email AS Correo,
			Customers.creditDays AS Dias_credito,
			Customers.phone AS Telefono_sin_lada,
			Customers.ladaPhone AS Lada_telefono,
			Customers.ladaMovil AS Lada_movil,
			Customers.corporative AS Corporativo,

			CONCAT(SUBSTRING(Users.firstName,0,2),SUBSTRING(Users.lastName1,0,2),SUBSTRING(Users.lastName2,0,2)) AS Ejecutivo_Abreviado,

			CASE WHEN
				Customers.status = 1 THEN 'Activo'
				ELSE 'Inactivo'
			END AS Estatus_Descripcion,

			CONCAT(ladaPhone,' ',phone) AS Telefono,
			CONCAT(ladaMovil,' ',movil) AS Movil,
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
			JOIN CustomerTypes on Customers.customerType = CustomerTypes.customerTypeID

			WHERE

			((Customers.socialReason LIKE '%' + @search + '%') OR
			(Customers.commercialName LIKE '%' + @search + '%') OR
			(Customers.shortName LIKE '%' + @search + '%') OR
			(Users.firstName LIKE '%' + @search + '%') OR
			(Users.middleName LIKE '%' + @search + '%') OR
			(Users.lastName1 LIKE '%' + @search + '%') OR
			(Users.lastName2 LIKE '%' + @search + '%') OR
			(Customers.movil LIKE '%' + @search + '%') OR
			(Customers.phone LIKE '%' + @search + '%')) AND
			(Customers.status = @status OR @status IS NULL) AND
				(Customer_Executive.executiveID = @executive) OR
				(Customers.customerType = 2 OR Customers.customerType = 5)
		                
				ORDER BY Customers.customerType, Customer_Executive.executiveID DESC
				
				OFFSET @rangeBegin ROWS 
				FETCH NEXT @noRegisters ROWS ONLY
		END
		ELSE
		BEGIN
		SELECT
			Customers.customerID AS Cliente_id,
			Customers.socialReason AS Razon_social,
			Customers.commercialName AS Nombre_comercial,
			Customers.shortName AS Nombre_corto,
			Customers.movil AS Movil_sin_lada,
			Customers.rfc AS RFC,
			Customers.email AS Correo,
			Customers.creditDays AS Dias_credito,
			Customers.phone AS Telefono_sin_lada,
			Customers.ladaPhone AS Lada_telefono,
			Customers.ladaMovil AS Lada_movil,
			Customers.corporative AS Corporativo,

			CONCAT(SUBSTRING(Users.firstName,0,2),SUBSTRING(Users.lastName1,0,2),SUBSTRING(Users.lastName2,0,2)) AS Ejecutivo_Abreviado,

			CASE WHEN
				Customers.status = 1 THEN 'Activo'
				ELSE 'Inactivo'
			END AS Estatus_Descripcion,

			CONCAT(ladaPhone,' ',phone) AS Telefono,
			CONCAT(ladaMovil,' ',movil) AS Movil,
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
			JOIN CustomerTypes on Customers.customerType = CustomerTypes.customerTypeID

			WHERE

			((Customers.socialReason LIKE '%' + @search + '%') OR
			(Customers.commercialName LIKE '%' + @search + '%') OR
			(Customers.shortName LIKE '%' + @search + '%') OR
			(Users.firstName LIKE '%' + @search + '%') OR
			(Users.middleName LIKE '%' + @search + '%') OR
			(Users.lastName1 LIKE '%' + @search + '%') OR
			(Users.lastName2 LIKE '%' + @search + '%') OR
			(Customers.movil LIKE '%' + @search + '%') OR
			(Customers.phone LIKE '%' + @search + '%')) AND
			(Customers.status = @status OR @status IS NULL) AND
			(Customers.customerType = @type)
		              
		ORDER BY Customers.customerID  DESC
		
		OFFSET @rangeBegin ROWS 
		FETCH NEXT @noRegisters ROWS ONLY
		END

	END
