SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 01/06/2022
-- Description: sp_GetDocumentData - Gets the document info
-- Added UEN for the sku on the invoice creation
ALTER PROCEDURE [dbo].[sp_GetDocumentData](
    @idDocument INT
) AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @contactID INT;
    DECLARE @isOcDocument BIT = 0;
    DECLARE @isContactFromClient BIT = 0;

    SELECT @isOcDocument =
           CASE
               WHEN documentInfo.idTypeDocument = 3 THEN 1
               ELSE 0
               END,
           @contactID = ISNULL(documentInfo.idContact, 0)
    FROM Documents AS documentInfo
    WHERE documentInfo.idDocument = @idDocument;

    IF (@contactID > 0)
        BEGIN
            SELECT @isContactFromClient =
                   CASE
                       WHEN customer.customerType = 1 THEN 1
                       ELSE 0
                       END
            FROM Contacts AS contact
                     LEFT JOIN Customers AS customer ON customer.customerID = contact.customerID
            WHERE contact.contactID = @contactID;
        END


    SELECT documentInfo.idDocument                            AS id,
           CONVERT(INT, documentInfo.documentNumber)          AS folio,
           documentInfo.idContractParent                      AS idContractParent,
           documentInfo.[contract]                            AS contractKey,
           documentInfo.idTypeDocument                        AS documentType,
           customer.customerID                                AS [customer.id],
           customer.commercialName                            AS [customer.comertialName],
           customer.shortName                                 AS [customer.shortName],
           customer.socialReason                              AS [customer.socialReason],
           customer.rfc                                       AS [customer.rfc],
           (SELECT comments.isEditable,
                   comments.isRemovable,
                   comments.commentType AS [type],
                   comments.comment
            FROM CommentsNotesAndConsiderations AS comments
            WHERE comments.idDocument = documentInfo.idDocument
            FOR JSON PATH,INCLUDE_NULL_VALUES)                AS [comments],

           JSON_QUERY(
                   (SELECT documentContact.birthDay            AS anniversary,
                           documentContact.email               AS email,
                           documentContact.contactID           AS id,
                           documentContact.isForColletion      AS isCollectionContact,
                           documentContact.isForPayments       AS isPaymentContact,
                           documentContact.lastName1           AS lastName1,
                           documentContact.lastName2           AS lastName2,
                           documentContact.firstName           AS [name],
                           documentContact.[position]          AS workTitle,
                           documentContact.middleName          AS middleName,
                           documentContact.cellNumberAreaCode  AS [cell.extention],
                           documentContact.cellNumber          AS [cell.numberPhone],
                           documentContact.phoneNumberAreaCode AS [phone.extention],
                           documentContact.phoneNumber         AS [phone.numberPhone]
                    FROM Contacts AS documentContact
                    WHERE documentContact.contactID =
                          CASE
                              WHEN @isContactFromClient = 1 AND @isOcDocument = 1 THEN -1
                              ELSE documentInfo.idContact
                              END
                    FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER)
           )                                                  AS [contact],

           (SELECT documentItem.quantity,
                   documentItem.idItem                                                                                AS [id],
                   documentItem.idItem                                                                                AS [value],

                   documentItem.discountPercentage                                                                    AS [clientDiscoount.number],
                   CONCAT(documentItem.discountPercentage, '%')                                                       AS [clientDiscoount.text],
                   -- documentItem.priceDiscount AS [clientDiscoount.number],
                   -- dbo.fn_FormatCurrency(documentItem.priceDiscount) AS [clientDiscoount.text],
                   documentItem.costDiscount                                                                          AS [providerDiscount.number],
                   dbo.fn_FormatCurrency(documentItem.costDiscount)                                                   AS [providerDiscount.text],
                   documentItem.[description],
                   documentItem.[description]                                                                         AS label,
                   documentItem.unitPriceBeforeExchange                                                               AS [pu.number],
                   dbo.fn_FormatCurrency(documentItem.unitPriceBeforeExchange)                                        AS [pu.text],
                   dbo.fn_CalculateDiscount(documentItem.discountPercentage,
                                            documentItem.unitPriceBeforeExchange)                                     AS [pu.withDiscount.number],
                   dbo.fn_FormatCurrency(dbo.fn_CalculateDiscount(documentItem.discountPercentage,
                                                                  documentItem.unitPriceBeforeExchange))              AS [pu.withDiscount.text],
                   documentItem.unitCostBeforeExchange                                                                AS [cuBeforeExchange.number],
                   documentItem.unitPriceBeforeExchange                                                               AS [puBeforeExchange.number],
                   documentItem.unit_cost                                                                             AS [cu.number],
                   dbo.fn_FormatCurrency(documentItem.unit_cost)                                                      AS [cu.text],
                   dbo.fn_CalculateDiscount(documentItem.costDiscount,
                                            documentItem.unit_cost)                                                   AS [cu.withDiscount.number],
                   dbo.fn_FormatCurrency(dbo.fn_CalculateDiscount(documentItem.costDiscount,
                                                                  documentItem.unit_cost))                            AS [cu.withDiscount.text],
                   documentItem.claveProductoServicio                                                                 AS [satCode],
                   documentItem.claveProductoServicioDescripcion                                                      AS [satCodeDescription],
                   documentItem.um                                                                                    AS [satUm],
                   documentItem.calculationPriceImport -
                   documentItem.calculationCostImport                                                                 AS [realMargin],
                   documentItem.umDescripcion                                                                         AS [satUmDescription],
                   documentItem.ivaPercentage                                                                         AS [iva.number],
                   CONCAT(documentItem.ivaPercentage, '%')                                                            AS [iva.text],
                   CASE
                       WHEN documentItem.ivaExcento IS NULL THEN 0
                       ELSE documentItem.[ivaExcento]
                       END                                                                                            AS [iva.exempt],
                   catalogue.sku,
                   uen.[description]                                                                                  AS [uen.description],
                   uen.family                                                                                         AS [uen.family],
                   uen.UENID                                                                                          AS [uen.id],
                   uen.marginRate                                                                                     AS [uen.marginRate],
                   currency.code                                                                                      AS [currency.code],
                   currency.symbol                                                                                    AS [currency.symbol],
                   currency.description                                                                               AS [currency.description],
                   catalogue.id_code                                                                                  AS [catalogue.id],
                   catalogue.[description]                                                                            AS [catalogue.description],
                   catalogue.unit_cost                                                                                AS [catalogue.cu],
                   catalogue.unit_price                                                                               AS [catalogue.pu],
                   catalogue.iva                                                                                      AS [catalogue.iva],
                   documentItem.[currency]                                                                            AS [catalogue.currency.code],
                   itemCurrency.[symbol]                                                                              AS [catalogue.currency.symbol],
                   itemCurrency.[description]                                                                         AS [catalogue.currency.description]
            FROM DocumentItems AS documentItem
                     LEFT JOIN Catalogue AS catalogue ON catalogue.id_code = documentItem.idCatalogue
                     LEFT JOIN Currencies AS itemCurrency ON itemCurrency.code = documentItem.currency
                     LEFT JOIN Currencies AS currency ON currency.currencyID = catalogue.currency
                     LEFT JOIN UEN AS uen ON uen.UENID = catalogue.uen
            WHERE documentItem.document = documentInfo.idDocument
            ORDER BY documentItem.[order] ASC

            FOR JSON PATH,INCLUDE_NULL_VALUES)                AS [items],

           documentInfo.UEN                                   AS [uen.id],
           UEN.description                                    AS [uen.description],

           documentInfo.initialDate                           AS [generateContract.beginDate],
           documentInfo.expirationDate                        AS [generateContract.endDate],
           documentInfo.reminderDate                          AS [generateContract.reminderDate],
           documentInfo.idCurrency                            AS [moneyInfo.currency.id],
           currency.code                                      AS [moneyInfo.currency.value],
           documentInfo.ivaAmount                             AS [moneyInfo.iva.number],
           dbo.fn_FormatCurrency(documentInfo.ivaAmount)      AS [moneyInfo.iva.text],
           documentInfo.subTotalAmount                        AS [moneyInfo.import.number],
           dbo.fn_FormatCurrency(documentInfo.subTotalAmount) AS [moneyInfo.import.text],
           documentInfo.totalAmount                           AS [moneyInfo.total.number],
           dbo.fn_FormatCurrency(documentInfo.totalAmount)    AS [moneyInfo.total.text],
           documentInfo.protected                             AS [moneyInfo.tc.number],
           dbo.fn_FormatCurrency(documentInfo.protected)      AS [moneyInfo.tc.text],
           documentInfo.idProgress                            AS [moneyInfo.probability.id],
           progress.[description]                             AS [moneyInfo.probability.value]


    FROM Documents AS documentInfo
             LEFT JOIN Currencies AS currency ON currency.currencyID = documentInfo.idCurrency
             LEFT JOIN DocumentProgress AS progress ON progress.documentProgressID = documentInfo.idProgress
             LEFT JOIN Customers AS customer ON customer.customerID = documentInfo.idCustomer
             LEFT JOIN UEN ON documentInfo.UEN = UEN.UENID

    WHERE idDocument = @idDocument
    FOR JSON PATH, INCLUDE_NULL_VALUES,ROOT('Document');

END
GO
