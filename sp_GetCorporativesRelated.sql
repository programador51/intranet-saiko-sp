-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 01-10-2021

-- Description: The all the users from the Directory that have the same corporative associated
-- with an id as argument

-- ===================================================================================================================================
-- PARAMETERS:
-- @idCorporative: Id of the corporative

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  01-10-2021    Jose Luis Perez             1.0.0.0         Documentation and query			
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetCorporativesRelated(
    @idCorporative INT
)

AS BEGIN

    SET LANGUAGE Spanish;

    SELECT 

    Customers.customerID AS id,
    Customers.creditDays AS creditDays,
    Customers.customerType AS [type.id],
    CustomerTypes.description AS [type.description],
    
    Customers.email AS [contact.email],
    Customers.ladaMovil AS [contact.movil.lada],
    Customers.movil AS [contact.movil.number],
    CONCAT(Customers.ladaMovil,Customers.movil) AS [contact.movil.fullNumber],
    CONCAT('+',Customers.ladaMovil,Customers.movil) AS [contact.movil.parsed],

    Customers.ladaPhone AS [contact.phone.lada],
    Customers.phone AS [contact.phone.number],
    CONCAT(Customers.ladaPhone,Customers.phone) AS [contact.phone.fullNumber],
    CONCAT('+',Customers.ladaPhone,Customers.phone) AS [contact.phone.parsed],

    CONVERT(INT,Customers.bankMN) AS [mnBank.id],
    Customers.accountMN AS [mnBank.account],
    Customers.keyCodeMN AS [mnBank.code],
    Customers.noAgreementMN AS [mnBank.agreement],
    MN.shortName AS [mnBank.shortName],
    MN.socialReason AS [mnBank.socialReason],
    
    CONVERT(INT,Customers.bankUSD) AS [usdBank.id],
    Customers.accountUS AS [usdBank.account],
    Customers.keyCodeUS AS [usdBank.code],
    Customers.noAgreementMN AS [usdBank.agreement],
    USD.shortName AS [usdBank.shortName],
    USD.socialReason AS [usdBank.socialReason],

    Customers.city AS [adress.city],
    Customers.suburb AS [adress.colony],
    Customers.street AS [adress.street],
    Customers.exteriorNumber AS [adress.extNumber],
    Customers.interiorNumber AS [adress.intNumber],
    Customers.country AS [adress.country],
    Customers.polity AS [adress.state],
    Customers.cp AS [adress.cp],

    Customers.iva AS iva,

    Customers.commercialName AS [name.commercial],
    Customers.shortName AS [name.short],
    Customers.socialReason AS socialReason,
    Customers.rfc AS rfc,

    CASE
        WHEN 
            Customers.status = 1
            THEN CONVERT(BIT,1)

        ELSE
            CONVERT(BIT,0) END AS [status.isActive],


    CASE
        WHEN
            Customers.status = 1
            THEN 'Activo'

        ELSE
            'Inactivo' END AS [status.parsed],

    Customers.createdBy AS [created.by],
    FORMAT(Customers.createdDate,'yyyy-MM-dd') AS [created.date.yyyymmdd],
    REPLACE(CONVERT(VARCHAR(10),Customers.createdDate,6),' ','/') AS [created.date.parsed],

    Customers.lastUpdatedBy AS [updated.by],
    FORMAT(Customers.lastUpdatedDate,'yyyy-MM-dd') AS [updated.date.yyyymmdd],
    REPLACE(CONVERT(VARCHAR(10),Customers.lastUpdatedDate,6),' ','/') AS [updated.date.parsed],

    Customers.corporative AS [corporative.id]

    FROM Customers
    
    INNER JOIN CustomerTypes ON Customers.customerType = CustomerTypes.customerTypeID
    LEFT JOIN Banks USD ON Customers.bankUSD = USD.bankID
    LEFT JOIN Banks MN ON Customers.bankMN = MN.bankID

    WHERE Customers.corporative = @idCorporative

    
    FOR JSON PATH, ROOT('corporatives'), INCLUDE_NULL_VALUES;

END

-- SAMPLE IN CASE THERE WAS A RESULT

-- "corporatives": [
--     {
--         "id": 64,
--         "creditDays": 30,
--         "type": {
--             "id": 1,
--             "description": "Cliente"
--         },
--         "contact": {
--             "email": "aalardin177@gmail.com",
--             "movil": {
--                 "lada": "52",
--                 "number": " 812 196 6517",
--                 "fullNumber": "52 812 196 6517",
--                 "parsed": "+52 812 196 6517"
--             },
--             "phone": {
--                 "lada": "52",
--                 "number": " 812 459 0664",
--                 "fullNumber": "52 812 459 0664",
--                 "parsed": "+52 812 459 0664"
--             }
--         },
--         "mnBank": {
--             "id": null,
--             "account": null,
--             "code": null,
--             "agreement": null,
--             "shortName": null,
--             "socialReason": null
--         },
--         "usdBank": {
--             "id": null,
--             "account": null,
--             "code": null,
--             "agreement": null,
--             "shortName": null,
--             "socialReason": null
--         },
--         "adress": {
--             "city": "GUADALUPE",
--             "colony": "Azteca",
--             "street": "Los cedros",
--             "extNumber": "642       ",
--             "intNumber": null,
--             "country": "Mexico",
--             "state": "NUEVO LEON",
--             "cp": 67150
--         },
--         "iva": 16,
--         "name": {
--             "commercial": "A-SocialTest-B",
--             "short": "A-RST-B"
--         },
--         "socialReason": "A-Razon Social Test-B",
--         "rfc": "XAXX010101000",
--         "status": {
--             "isActive": true,
--             "parsed": "Activo"
--         },
--         "created": {
--             "by": "Adrian   Alardin Iracheta",
--             "date": {
--                 "yyyymmdd": "2021-09-30",
--                 "parsed": "30/Sep/21"
--             }
--         },
--         "updated": {
--             "by": "Adrian   Alardin Iracheta",
--             "date": {
--                 "yyyymmdd": "2021-09-30",
--                 "parsed": "30/Sep/21"
--             }
--         },
--         "corporative": {
--             "id": 63
--         }
--     },
--     { ... },
--     { ....}
-- ]