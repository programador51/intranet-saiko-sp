-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--
--	STORED PROCEDURE NAME:	sp_AddCustomer 
--
--	DESCRIPTION:			This SP adds a new customer into the customer's table
--
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-10-06		Iván Díaz   				1.0.0.0			Initial Revision		
-- **************************************************************************************************************************************************


CREATE PROCEDURE sp_AddCustomer(

	@commercialName NVARCHAR(100),
	@corporative INT,
	@createdBy NVARCHAR(30),
	@creditDays INT,
	@customerCity NVARCHAR(25),
	@customerColony NVARCHAR(25),
	@customerCountry NVARCHAR(100),
	@customerRFC NVARCHAR(30),
	@customerState NVARCHAR(30),
	@emailCustomer NVARCHAR(30),
	@executiveAttends INT,
	@exteriorNumber INT,
	@idCorporative INT
	@insideNumber INT,
	@iva FLOAT,
	@lada_movil NVARCHAR(10),
	@lada_phone NVARCHAR(10),
	@mnBank NVARCHAR(30),
	@mnNoAgreement NVARCHAR(30),
	@mnNumberAccount NVARCHAR(30),
	@mnNumberKeyCode NVARCHAR(18),
	@number_movil NVARCHAR(30),
	@number_phone NVARCHAR(30),
	@postalCode INT,
	@referenceDeposit NVARCHAR(30),
	@shortName NVARCHAR(50),
	@socialReason NVARCHAR(100),
	@status TINYINT,
	@streetCustomer NVARCHAR(50),
	@typeCustomer INT,
	@usdBank NVARCHAR(30),
	@usdNoAgreement NVARCHAR(30),
	@usdNumberAccount NVARCHAR(30),
	@usNumberKeyCode NVARCHAR(18),

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
