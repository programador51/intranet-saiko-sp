CREATE PROCEDURE sp_postCustomer(
	@number int,
	@socialReason nvarchar(100),
	@commercialName nvarchar(100),
	@shortName nvarchar(100),
	@phoneNumber nvarchar(20),
	@cellNumber nvarchar(20),
	@customerType int,
	@status tinyint,
	@createdBy varchar(30),
	@today datetime,
	@lastUpdatedBy varchar(30)
)

AS
BEGIN

	INSERT INTO Customers 
        (
            number,socialReason,commercialName,
            shortName,phoneNumber,cellNumber,
            customerType,status,createdBy,
            createdDate,lastUpdatedBy,lastUpdatedDate
        )
        
        values

        (
            @number,@socialReason,@commercialName,
            @shortName,@phoneNumber,@cellNumber,
            @customerType,@status,@createdBy,
            @today,@lastUpdatedBy,@today
        )

END
GO

------------------- EXAMPLE 2 -------------------------------
CREATE PROCEDURE sp_FilterDirectory_Case0(
	@type INT,
	@status INT,
	@executive INT,
	@orderingColumn VARCHAR,
	@orderingCriterian VARCHAR,
	@rangeBegin INT,
	@noRegisters INT
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
            Customer_Executive.executiveID = @executive AND
            Customers.status = @status AND
            Customers.customerType = @type
            
	ORDER BY
		CASE @orderingColumn
			WHEN 'customerID' THEN Customers.customerID
			WHEN 'socialReason' THEN socialReason
			WHEN 'commercialName' THEN commercialName
			WHEN 'shortName' THEN shortName
			WHEN 'executive' THEN Users.firstName
			WHEN 'phoneNumber' THEN phone
			WHEN 'cellNumber' THEN movil
		END DESC
            
	OFFSET @rangeBegin ROWS 
	FETCH NEXT @noRegisters ROWS ONLY 
END
GO