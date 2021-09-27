CREATE PROCEDURE sp_AddCustomer(

	@socialReason NVARCHAR(100),
	@commercialName NVARCHAR(100),
	@shortName NVARCHAR(50),
	@typeCustomer INT,
	@status TINYINT,
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
	@customerCountry NVARCHAR(100),
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

	@idCorporative INT

)

AS BEGIN


INSERT INTO Customers
        (
            socialReason,commercialName,shortName,
            customerType,status,createdBy,
            createdDate,lastUpdatedBy,lastUpdatedDate,
            rfc,address,street,
            exteriorNumber,interiorNumber,suburb,
            city,polity,cp,
            country,ladaPhone,phone,
            ladaMovil,movil,email,
            creditDays,iva,depositReference,
            corporative,

            bankMN,accountMN,keyCodeMN,
            noAgreementMN,

            bankUSD,accountUS,keyCodeUS,
            noAgreementUS

        )

        VALUES

        (
            @socialReason,@commercialName,@shortName,
            @typeCustomer,1,@createdBy,
            GETDATE(),@createdBy,GETDATE(),
            @customerRFC,@addressCustomer,@streetCustomer,
            @exteriorNumber,@insideNumber,@customerColony,
            @customerCity,@customerState,@postalCode,
            @customerCountry,@lada_phone,@number_phone,
            @lada_movil,@number_movil,@emailCustomer,
            @creditDays, @iva, @referenceDeposit,
            @idCorporative,

            @mnBank,@mnNumberAccount,@mnNumberKeyCode,
            @mnNoAgreement,

            @usdBank,@usdNumberAccount,@usNumberKeyCode,
            @usdNoAgreement
        )

        SELECT SCOPE_IDENTITY()

END