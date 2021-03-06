/****** Object:  StoredProcedure [dbo].[sp_FilterDirectorySearch_Pagination]    Script Date: 09/07/2021 09:07:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_FilterDirectorySearch_Pagination](

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