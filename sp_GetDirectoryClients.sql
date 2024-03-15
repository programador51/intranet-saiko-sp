-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 01-10-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetDirectoryClients
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
--	2024-01-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetDirectoryClients')
    BEGIN 

        DROP PROCEDURE sp_GetDirectoryClients;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 01/10/2024
-- Description: sp_GetDirectoryClients - Some Notes
CREATE PROCEDURE sp_GetDirectoryClients(
    @type INT,
	@status TINYINT,
	@orderingColumn NVARCHAR,
	@orderingCriterian NVARCHAR,
	@rangeBegin INT,
	@noRegisters INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE  @WHERE_CLAUSE NVARCHAR (MAX);
DECLARE  @SELECT_CLAUSE NVARCHAR (MAX);
DECLARE  @FROM_CLAUSE NVARCHAR (MAX);
DECLARE  @JOIN_CLAUSE NVARCHAR (MAX);
DECLARE  @SP_STATEMENT NVARCHAR (MAX);
DECLARE @PARAMS NVARCHAR (MAX);


-- We declare the variables
SET @PARAMS= '@type INT,@status TINYINT,@rangeBegin INT,@noRegisters INT'

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
		
		CONCAT(''+'',Customers.ladaPhone,'' '',Customers.phone) AS Telefono,
		CONCAT(''+'',Customers.ladaMovil,'' '',Customers.movil) AS Movil,
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
		(Customers.customerType = @type) ORDER BY Customers.customerID DESC OFFSET @rangeBegin ROWS  FETCH NEXT @noRegisters ROWS ONLY ';
		
	END
	ELSE IF (@type IS NULL)
		-- ALL TYPES
		BEGIN
				SET @WHERE_CLAUSE= 'WHERE
				(Customers.status = @status OR @status IS NULL) AND
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
		
EXEC SP_EXECUTESQL @SP_STATEMENT,@PARAMS, @type, @status, @rangeBegin, @noRegisters
GO

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------