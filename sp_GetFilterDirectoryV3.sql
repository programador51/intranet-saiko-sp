-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Fetch the directory according to the filters
-- that the user it's requesting by

-- STORED PROCEDURE NAME:	sp_GetFilterDirectory
-- STORED PROCEDURE OLD NAME: sp_FilterDirectory


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
-- ===================================================================================================================================
-- VARIABLES:
-- @SELECT_CLAUSE NVARCHAR (MAX): This variable stores the SELECT statement. It is general, it does not matter the @type.
-- @WHERE_CLAUSE NVARCHAR (MAX): This variable saves the WHERE statement and changes depending on the type.
-- @FROM_CLAUSE NVARCHAR (MAX): This variable stores the FROM statement. It is general, it does not matter the @type
-- @JOIN_CLAUSE NVARCHAR (MAX): This variable stores the JOINS statement. It is general, it does not matter the @type
-- @PARAMS NVARCHAR (MAX): This variable makes the conjunction of @SELECT_CLAUSE,@WHERE_CLAUSE, @FROM_CLAUSE and @JOIN_CLAUSE
-- @SP_STATEMENT NVARCHAR (MAX): The variable @PARAMS declares all the variables that are needed to run the SP. They are basically the same as the parameters
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
--  2021-12-27      Adrian Alardin Iracheta     2.0.0.0         Fixed: Get all the suppliers clients/suppliers		
--  2022-01-06      Adrian Alardin Iracheta     3.0.0.0         Improvement: It is more maintainable		
-- *****************************************************************************************************************************

/****** Object:  StoredProcedure [dbo].[sp_FilterDirectory]    Script Date: 26/07/2021 09:03:06 p. m. ******/


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetFilterDirectory (

	@type INT,
	@status TINYINT,
	@executive INT,
	@orderingColumn NVARCHAR,
	@orderingCriterian NVARCHAR,
	@rangeBegin INT,
	@noRegisters INT

)

AS BEGIN

DECLARE  @WHERE_CLAUSE NVARCHAR (MAX);
DECLARE  @SELECT_CLAUSE NVARCHAR (MAX);
DECLARE  @FROM_CLAUSE NVARCHAR (MAX);
DECLARE  @JOIN_CLAUSE NVARCHAR (MAX);
DECLARE  @SP_STATEMENT NVARCHAR (MAX);
DECLARE @PARAMS NVARCHAR (MAX);


-- We declare the variables
SET @PARAMS= '@type INT,@status TINYINT,@executive INT,@rangeBegin INT,@noRegisters INT'

-- We save the generic SELECT
SET @SELECT_CLAUSE= 'SELECT
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
			Customers.status = 1 THEN ''Activo''
			ELSE ''Inactivo''
		END AS Estatus_Descripcion,
		
		CONCAT(''+'',ladaPhone,'' '',phone) AS Telefono,
		CONCAT(''+'',ladaMovil,'' '',movil) AS Movil,
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
		CONCAT(firstName,'' '',middleName,'' '',lastName1,'' '',lastName2) AS Ejecutivo,
		Users.userID AS ID_Ejecutivo,
		CustomerTypes.customerTypeID AS ID_tipo_cliente,
		CustomerTypes.description AS Tipo_cliente ';

-- We save the FROM statement
SET @FROM_CLAUSE = 'FROM Customers ';

-- We save the JOIN statement
SET @JOIN_CLAUSE='JOIN Customer_Executive ON Customers.customerID = Customer_Executive.customerID
JOIN Users ON Customer_Executive.executiveID = Users.userID
JOIN CustomerTypes ON Customers.customerType = CustomerTypes.customerTypeID ';
END
	                
-- Starts the evaluation of the filter by the Type
IF(@type=1)
-- CLIENT TYPE
	BEGIN
		SET @WHERE_CLAUSE= 'WHERE
		(Customers.status = @status OR @status IS NULL) AND
		(Customer_Executive.executiveID = @executive) AND
		(Customers.customerType = @type) ORDER BY Customers.customerID DESC OFFSET @rangeBegin ROWS  FETCH NEXT @noRegisters ROWS ONLY ';
		
	END
	ELSE IF (@type IS NULL)
		-- ALL TYPES
		BEGIN
				SET @WHERE_CLAUSE= 'WHERE
				(Customers.status = @status OR @status IS NULL) AND
				(Customer_Executive.executiveID = @executive) OR
				(Customers.customerType = 2 OR Customers.customerType = 5)
		                
				ORDER BY Customers.customerType, Customer_Executive.executiveID DESC
				
				OFFSET @rangeBegin ROWS 
				FETCH NEXT @noRegisters ROWS ONLY';
				
		END
	ELSE 
		-- SUPPLIER TYPE
        BEGIN
        SET @WHERE_CLAUSE='WHERE
		(Customers.status = @status OR @status IS NULL) AND
		(Customers.customerType = @type)
		              
		ORDER BY Customers.customerID  DESC 
		
		OFFSET @rangeBegin ROWS 
		FETCH NEXT @noRegisters ROWS ONLY';
        END

-- The complete statement is formed to execute the SP
SET @SP_STATEMENT= @SELECT_CLAUSE +@FROM_CLAUSE+@JOIN_CLAUSE+ @WHERE_CLAUSE;
		
EXEC SP_EXECUTESQL @SP_STATEMENT,@PARAMS, @type, @status, @executive, @rangeBegin, @noRegisters 
