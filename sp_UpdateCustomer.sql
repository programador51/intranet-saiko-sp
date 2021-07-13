CREATE PROCEDURE sp_UpdateCustomer(

	@socialReason NVARCHAR(100),
	@commercialName NVARCHAR(100),
	@shortName NVARCHAR(50),
	@typeCustomer INT,
	@value_statusCustomer TINYINT,
	@createdBy NVARCHAR(30),
	@customerRFC NVARCHAR(30),
	@addressCustomer NVARCHAR(50),
	@streetCustomer NVARCHAR(50),
	@exteriorNumber INT,
	@insideNumber INT,
	@customerColony NVARCHAR(25),
	@customerCity NVARCHAR(25),
	@customerState NVARCHAR(30),
	@postalCode INT,
	@customerCountry NVARCHAR(2),
	@lada_phone NVARCHAR(10),
	@number_phone NVARCHAR(30),
	@lada_movil NVARCHAR(10),
	@number_movil NVARCHAR(30),
	@emailCustomer NVARCHAR(30),
	@creditDays INT,
	@iva FLOAT,
	@referenceDeposit NVARCHAR(30),
	@corporative INT,
	@executiveAttends INT,

	@mnBank NVARCHAR(30),
	@mnNumberAccount NVARCHAR(30),
	@mnNumberKeyCode NVARCHAR(18),
	@mnNoAgreement NVARCHAR(30),

	@usdBank NVARCHAR(30),
	@usdNumberAccount NVARCHAR(30),
	@usNumberKeyCode NVARCHAR(18),
	@usdNoAgreement NVARCHAR(30),

	@idCorporative INT,
	@statusCustomer TINYINT,
	@customerID INT

)

AS BEGIN

UPDATE Customers SET
        socialReason = @socialReason,
        commercialName = @commercialName,
        shortName = @shortName,
        customerType = @typeCustomer,
        rfc = @customerRFC,
        address = @addressCustomer,
        street = @streetCustomer,
        exteriorNumber = @exteriorNumber,
        interiorNumber = @insideNumber,
        suburb = @customerColony,
        city = @customerCity,
        polity = @customerState,
        cp = @postalCode,
        country = @customerCountry,

        ladaPhone = @lada_phone,
        phone = @number_phone,

        ladaMovil = @lada_movil,
        movil = @number_movil,

        creditDays = @creditDays,
        depositReference = @referenceDeposit,

        bankMN = @mnBank,
        accountMN = @mnNumberAccount,
        keyCodeMN = @mnNumberKeyCode,
        noAgreementMN = @mnNoAgreement,

        bankUSD = @usdBank,
        accountUS = @usdNumberAccount,
        keyCodeUS = @usNumberKeyCode,
        noAgreementUS = @usdNoAgreement,

        corporative = @idCorporative,

        status = @value_statusCustomer,

        iva = @iva

        WHERE customerID = @customerID

END