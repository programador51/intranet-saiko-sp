/****** Object:  StoredProcedure [dbo].[sp_GetCustomer]    Script Date: 09/07/2021 03:06:40 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_GetCustomer](

	@idCustomer INT

)

AS BEGIN

(SELECT 
            Customers.accountMN,
            Customers.accountUS,
            Customers.address,
            Customers.bankMN,
            Customers.bankUSD,
            Customers.city,
            Customers.commercialName,
            Customers.corporative,
            Customers.country,
            Customers.cp,
            Customers.createdBy,
            Customers.createdDate,
            Customers.creditDays,
            Customers.customerID,
            Customers.customerType,
            Customers.depositReference,
            Customers.email,
            Customers.exteriorNumber,
            Customers.interiorNumber,
            Customers.iva,
            Customers.keyCodeMN,
            Customers.keyCodeUS,
            Customers.ladaMovil,
            Customers.ladaPhone,
            Customers.lastUpdatedBy,
            Customers.lastUpdatedDate,
            Customers.movil,
            Customers.noAgreementMN,
            Customers.noAgreementUS,
            Customers.phone,
            Customers.polity,
            Customers.rfc,
            Customers.shortName,
            Customers.socialReason,
            Customers.status,
            Customers.street,
            Customers.suburb,
            CONCAT(Customers.ladaPhone,' ',Customers.phone) AS Telefono,
            CONCAT(Customers.ladaMovil,' ',Customers.movil) AS Movil,
			Customer_Executive.customerID AS FK_Customer_To_Executive,
			Customer_Executive.executiveID AS Id_Ejecutivo,
            Customer_Executive.customerExecutiveID AS FK_Customer_Executive_Customer,

            USD.bankID AS usd_banco_id,
            USD.shortName AS usd_nombre_corto,
            USD.socialReason AS usd_razon_social,
    
            MN.bankID AS mn_banco_id,
            MN.shortName AS mn_nombre_corto,
            MN.socialReason AS mn_razon_social
    
            FROM Customers
            
            INNER JOIN Customer_Executive ON Customer_Executive.customerID = @idCustomer
            LEFT JOIN Banks USD ON Customers.bankUSD = USD.bankID
            LEFT JOIN Banks MN ON Customers.bankMN = MN.bankID
    
            WHERE Customers.customerID = @idCustomer)   

END
