-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 11-10-2021
-- Description: Update the customest
-- STORED PROCEDURE NAME:	sp_UpdateCustomer
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @socialReason: The social reason 
-- @commercialName: The commertial name
-- @shortName: The short name
-- @typeCustomer: The customer type
-- @value_statusCustomer: Indicates if is active or inactive
-- @createdBy: The user how update the record
-- @customerRFC: The customer RFC
-- @addressCustomer: Customer adress
-- @streetCustomer: Customer street
-- @exteriorNumber: Exterior number
-- @insideNumber: Inside number
-- @customerColony: Colony
-- @customerCity: City
-- @customerState: State
-- @postalCode: Postal Code
-- @customerCountry: Country
-- @lada_phone: Lada phone
-- @number_phone: Number phone
-- @lada_movil: Lada movil
-- @number_movil: Movil number
-- @emailCustomer: Customer email
-- @creditDays: Creadit days
-- @iva: IVA
-- @referenceDeposit: repository reference
-- @corporative: The corporative
-- @executiveAttends: The excuteve how attneds the customer
-- @mnBank: The MXN bank id
-- @mnNumberAccount: The number account
-- @mnNumberKeyCode: The key code
-- @mnNoAgreement: Agreement
-- @usdBank: The USD bank id
-- @usdNumberAccount: The USD number account
-- @usNumberKeyCode:The USD key code
-- @usdNoAgreement: The USD number agreement
-- @idCorporative: The corporative ID
-- @statusCustomer: The status of the customer
-- @customerID: The customer id
-- =============================================
-- VARIABLES:

-- ===================================================================================================================================
-- Returns:
-- @message: The result message of the operation
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-07-13		Jose Luis Perez   			1.0.0.0			Initial Revision
--	2021-12-02		Adrian Alardin   			1.0.0.1			Added the auditory records
-- *****************************************************************************************************************************

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
		email = @emailCustomer,

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
		lastUpdateBy=@createdBy,
		lastUpdateDate=GETDATE(),

        status = @value_statusCustomer,

        iva = @iva

        WHERE customerID = @customerID

END