-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 01-06-2022
-- Description: Gets the document info
-- STORED PROCEDURE NAME:	sp_GetDocumentData
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-01-06		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 01/06/2022
-- Description: sp_GetDocumentData - Gets the document info
CREATE PROCEDURE sp_GetDocumentData(
    @idDocument INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        documentInfo.idDocument AS id,
        documentInfo.[contract] AS contractKey,
        documentInfo.idTypeDocument AS documentType,
        (
            SELECT 
                comments.isEditable,
                comments.isRemovable,
                comments.commentType AS [type],
                comments.comment
            FROM CommentsNotesAndConsiderations AS comments
            WHERE comments.idDocument=documentInfo.idDocument
            FOR JSON PATH,INCLUDE_NULL_VALUES
        ) AS [comments],

        JSON_QUERY(
            (
                SELECT 
                    documentContact.birthDay AS anniversary,
                    documentContact.email AS email,
                    documentContact.contactID AS id,
                    documentContact.isForColletion AS isCollectionContact,
                    documentContact.isForPayments AS isPaymentContact,
                    documentContact.lastName1 AS lastName1,
                    documentContact.lastName2 AS lastName2,
                    documentContact.firstName AS [name],
                    documentContact.[position] AS workTitle,
                    documentContact.middleName AS middleName,
                    documentContact.cellNumberAreaCode AS [cell.extention],
                    documentContact.cellNumber AS [cell.numberPhone],
                    documentContact.phoneNumberAreaCode AS [phone.extention],
                    documentContact.phoneNumber AS [phone.numberPhone]

                FROM Contacts AS documentContact
                WHERE documentContact.contactID=documentInfo.idContact
                FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER 
            )
        ) AS [contact],

        (
            SELECT 
                documentItem.quantity,
                documentItem.idItem AS [id],
                documentItem.idItem AS [value],
                
                documentItem.priceDiscount AS [clientDiscoount.number],
                dbo.fn_FormatCurrency(documentItem.priceDiscount) AS [clientDiscoount.text],
                documentItem.costDiscount AS [providerDiscount.number],
                dbo.fn_FormatCurrency(documentItem.costDiscount) AS [providerDiscount.text],
                documentItem.[description],
                documentItem.[description] AS label,
                documentItem.unit_price AS [pu.number],
                dbo.fn_FormatCurrency(documentItem.unit_price) AS [pu.text],
                documentItem.unit_cost AS [cu.number],
                dbo.fn_FormatCurrency(documentItem.unit_cost) AS [cu.text],
                documentItem.claveProductoServicio AS [satCode],
                documentItem.claveProductoServicioDescripcion AS [satCodeDescription],
                documentItem.um AS [satUm],
                documentItem.umDescripcion AS [satUmDescription],
                documentItem.ivaPercentage AS [iva.number],
                CONCAT(documentItem.ivaPercentage,'%') AS [iva.text],
                documentItem.ivaExcento AS [iva.exempt],
                catalogue.sku,
                uen.[description] AS [uen.description],
                uen.family AS [uen.family],
                uen.UENID AS [uen.id],
                currency.code AS [currency.code], 
                currency.symbol AS [currency.symbol], 
                currency.description AS [currency.description],
                catalogue.id_code AS [catalogue.id],
                catalogue.[description] AS [catalogue.description],
                catalogue.unit_cost AS [catalogue.cu],
                catalogue.unit_price AS [catalogue.pu],
                catalogue.iva AS [catalogue.iva]

            FROM DocumentItems AS documentItem
            LEFT JOIN Catalogue AS catalogue ON catalogue.id_code=documentItem.idCatalogue
            LEFT JOIN UEN AS uen ON uen.UENID= catalogue.uen
            WHERE documentItem.document= documentInfo.idDocument
            
            FOR JSON PATH,INCLUDE_NULL_VALUES
        ) AS [items],

        

        documentInfo.initialDate AS [generateContract.beginDate],
        documentInfo.expirationDate AS [generateContract.endDate],
        documentInfo.reminderDate AS [generateContract.reminderDate],
        documentInfo.idCurrency AS [moneyInfo.currency.id],
        currency.code AS [moneyInfo.currency.value],
        documentInfo.ivaAmount AS [moneyInfo.iva.number],
        dbo.fn_FormatCurrency(documentInfo.ivaAmount)  AS [moneyInfo.iva.text],
        documentInfo.subTotalAmount AS [moneyInfo.import.number],
        dbo.fn_FormatCurrency(documentInfo.subTotalAmount)  AS [moneyInfo.import.text],
        documentInfo.totalAmount AS [moneyInfo.total.number],
        dbo.fn_FormatCurrency(documentInfo.totalAmount)  AS [moneyInfo.total.text],
        documentInfo.totalAmount AS [moneyInfo.total.number],
        dbo.fn_FormatCurrency(documentInfo.totalAmount)  AS [moneyInfo.total.text],
        documentInfo.protected AS [moneyInfo.tc.number],
        dbo.fn_FormatCurrency(documentInfo.protected)  AS [moneyInfo.tc.text],
        documentInfo.idProgress AS [moneyInfo.probability.id],
        progress.[description] AS [moneyInfo.probability.value]
        


    FROM Documents AS documentInfo
    LEFT JOIN Currencies AS currency ON currency.currencyID=documentInfo.idCurrency
    LEFT JOIN DocumentProgress AS progress ON progress.documentProgressID=documentInfo.idProgress
    WHERE idDocument= @idDocument
    FOR JSON PATH, INCLUDE_NULL_VALUES,ROOT('Document');

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------