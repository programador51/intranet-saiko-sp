-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Get the number of rows when filtering the directory and looking
-- for an specific text in order to calculate the number of pages for the directory

-- STORED PROCEDURE NAME:	sp_GetFilterDirectorySearchWithPagination
-- STORED PROCEDURE OLD NAME: sp_FilterDirectorySearch_Pagination

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @type: ID of the type of customer to fetch
-- @status: 1 active and 0 inactive customer
-- @executive: ID of the executive that attends the customer
-- @search: Text input that the user is looking for
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_GetFilterDirectorySearchWithPagination](

	@type INT,
	@status TINYINT,
	@executive INT,
	@search VARCHAR (50)

)

AS BEGIN

	SELECT
        Customers.customerID AS Cliente_id,
        Customers.socialReason AS Razon_social,
        Customers.commercialName AS Nombre_comercial,
        Customers.shortName AS Nombre_corto,
        Customers.phone AS Telefono_sin_lada,
        Customers.ladaPhone AS Lada_telefono,
        Customers.movil AS Movil_sin_lada,
        Customers.ladaMovil AS Lada_movil,
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
        (Customer_Executive.executiveID = @executive OR @executive IS NULL) AND
        (Customers.customerType = @type OR @type IS NULL)

END