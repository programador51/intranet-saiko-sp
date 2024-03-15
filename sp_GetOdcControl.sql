-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-12-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetOdcControl
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
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
--	2023-08-12		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetOdcControl')
    BEGIN 

        DROP PROCEDURE sp_GetOdcControl;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/12/2023
-- Description: sp_GetOdcControl - Some Notes
CREATE PROCEDURE sp_GetOdcControl(
    @notSended BIT,
    @notConfirmed BIT,
    @notCfSingned BIT,
    @notCotnractSigned BIT,
    @notLicences BIT,
    @notInvoiced BIT,
    @idClient INT,
    @idSupplier INT,
    @beginDate DATE,
    @endDate DATE
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @filterdOdc TABLE (
    id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    idOdc INT NOT NULL
)
    DECLARE @odComments TABLE (
    id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    idOdc INT NOT NULL
)

    DECLARE @ValidCustomers TABLE (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        idCustomer INT NOT NULL
    )
    IF(@idSupplier IS NOT NULL AND @idClient IS NULL)
        BEGIN
            INSERT INTO @ValidCustomers(
                idCustomer
            )
            VALUES(@idSupplier)
        END
    IF(@idClient IS NOT NULL AND @idSupplier IS NULL)
        BEGIN
            INSERT INTO @ValidCustomers(
                idCustomer
            )
            VALUES(@idClient)
        END
    IF(@idClient IS NULL AND @idSupplier IS NULL)
        BEGIN
            INSERT INTO @ValidCustomers(
                idCustomer
            )
            SELECT 
                customerID
            FROM Customers
            WHERE [status]=1
        END


    IF(@notSended =1)
        BEGIN
            INSERT INTO @filterdOdc (
                idOdc
            )
            SELECT 
                idDocument
            FROM Documents 
            WHERE 
                idTypeDocument = 3 AND
                idStatus != 12 AND
                wasSend = 0
        END
    IF(@notConfirmed =1)
        BEGIN
            INSERT INTO @filterdOdc (
                idOdc
            )
            SELECT DISTINCT
                odc.idDocument
            FROM Documents AS odc 
            LEFT JOIN DocumentItems AS items ON items.document = odc.idDocument
            LEFT JOIN Catalogue AS catalogue ON catalogue.id_code = items.idCatalogue
            LEFT JOIN UEN AS uen ON uen.UENID = catalogue.uen
            WHERE 
                odc.idTypeDocument = 3 AND
                odc.idStatus != 12 AND
                odc.confirmed IN (1,2) AND
                odc.wasSend = 1 AND
                items.status=1 AND
                uen.requierdConfirmation = 1
        END
    IF(@notCfSingned =1)
        BEGIN
            INSERT INTO @filterdOdc (
                idOdc
            )
            SELECT DISTINCT
                odc.idDocument
            FROM Documents AS odc 
            LEFT JOIN DocumentItems AS items ON items.document = odc.idDocument
            LEFT JOIN Catalogue AS catalogue ON catalogue.id_code = items.idCatalogue
            LEFT JOIN UEN AS uen ON uen.UENID = catalogue.uen
            WHERE 
                odc.idTypeDocument = 3 AND
                odc.idStatus != 12 AND
                odc.cfSing=0 AND
                odc.wasSend = 1 AND
                items.status=1 AND
                uen.requierdCFSign = 1
        END
    IF(@notCotnractSigned =1)
        BEGIN
            INSERT INTO @filterdOdc (
                idOdc
            )
            SELECT DISTINCT
                odc.idDocument
            FROM Documents AS odc 
            LEFT JOIN DocumentItems AS items ON items.document = odc.idDocument
            LEFT JOIN Catalogue AS catalogue ON catalogue.id_code = items.idCatalogue
            LEFT JOIN UEN AS uen ON uen.UENID = catalogue.uen
            WHERE 
                odc.idTypeDocument = 3 AND
                odc.idStatus != 12 AND
                odc.myContractSing =0 AND
                odc.wasSend = 1 AND
                items.status=1 AND
                uen.requierdContractSing = 1
        END
    IF(@notLicences =1)
        BEGIN
            INSERT INTO @filterdOdc (
                idOdc
            )
            SELECT DISTINCT
                odc.idDocument
            FROM Documents AS odc 
            LEFT JOIN DocumentItems AS items ON items.document = odc.idDocument
            LEFT JOIN Catalogue AS catalogue ON catalogue.id_code = items.idCatalogue
            LEFT JOIN UEN AS uen ON uen.UENID = catalogue.uen
            WHERE 
                odc.idTypeDocument = 3 AND
                odc.idStatus != 12 AND
                odc.licencesConfirmed=0 AND
                odc.wasSend = 1 AND
                items.status=1 AND
                uen.requierdLicences = 1
        END
    IF(@notInvoiced =1)
        BEGIN
            INSERT INTO @filterdOdc (
                idOdc
            )
            SELECT DISTINCT
                odc.idDocument
            FROM Documents AS odc 
            WHERE
                odc.idTypeDocument = 3 AND
                odc.idStatus != 12 AND
                odc.licencesConfirmed=0 AND
                odc.wasSend = 1 AND
                odc.idDocument NOT IN (SELECT idDocument FROM LegalDocumentsAssociations WHERE [status]=1)
        END

        IF(
            @notSended IS NULL AND
            @notConfirmed IS NULL AND
            @notCfSingned IS NULL AND
            @notCotnractSigned IS NULL AND
            @notLicences IS NULL AND
            @notInvoiced IS NULL 
        )
            BEGIN
                INSERT INTO @filterdOdc (
                idOdc
                    )
                    SELECT DISTINCT
                        odc.idDocument
                    FROM Documents AS odc 
                    WHERE
                        odc.idTypeDocument = 3 AND
                        odc.idStatus != 12
            END
        INSERT INTO @odComments(
            idOdc
        )

        SELECT DISTINCT
            idOdc
        FROM OdcControlComments AS comments


    SELECT
        odc.idDocument AS idOdc,
        odc.documentNumber AS documentNumber,
        currency.code AS odcCurrency,
        odc.subTotalAmount AS odcImport,
        odc.ivaAmount AS odcIva,
        odc.totalAmount AS odcTotal,
        odc.createdDate AS emitedDate,
        client.socialReason AS client,
        supplier.socialReason AS supplier,
        association.createdDate AS invoiceDate,
        odc.sentDate AS sendDate,
        odc.confirmed AS confirmed,
        odc.confirmedDate AS confirmationDate,
        odc.cfSing AS cfSing,
        odc.cfSingedDate AS cfSingedDate,
        odc.myContractSing AS myContractSing,
        odc.myContractSingedDate AS myContractSingedDate,
        odc.licencesConfirmed AS licencesConfirmed,
        odc.licencesConfirmedDate AS licencesConfirmedDate,
        executive.initials AS executive,
        (
            SELECT DISTINCT
                uen.[description]
            FROM DocumentItems AS items
            LEFT JOIN Catalogue AS catalogue ON catalogue.id_code= items.idCatalogue
            LEFT JOIN UEN AS uen ON uen.UENID = catalogue.uen
            WHERE
                items.[status]=1 AND
                items.document = filterOdc.idOdc
            FOR JSON PATH,INCLUDE_NULL_VALUES
        )AS uen,
        invoice.noDocument AS invoiceNumber,
        invoice.currencyCode AS invoiceCurrency,
        invoice.import AS invoiceImport,
        invoice.iva AS invoiceIva,
        invoice.total AS invoiceTotal,
        CAST(CASE 
            WHEN commetns.idOdc IS NULL THEN 0
            ELSE 1
        END  AS BIT) AS hasComment
        
    FROM @filterdOdc AS filterOdc
    LEFT JOIN Documents AS odc ON odc.idDocument= filterOdc.idOdc
    LEFT JOIN Documents AS quotes ON quotes.idDocument = odc.idQuotation
    LEFT JOIN Customers AS client ON client.customerID=quotes.idCustomer
    LEFT JOIN Customers AS supplier ON supplier.customerID= odc.idCustomer
    LEFT JOIN LegalDocumentsAssociations AS association ON association.idDocument=filterOdc.idOdc AND association.[status]=1
    LEFT JOIN LegalDocuments AS invoice ON invoice.id = association.idLegalDocuments
    LEFT JOIN Users AS executive ON executive.userID= odc.idCustomer
    LEFT JOIN Currencies AS currency ON currency.currencyID = odc.idCurrency
    LEFT JOIN @odComments AS commetns ON commetns.idOdc=filterOdc.idOdc
    WHERE
        (client.customerID IN (SELECT idCustomer FROM @ValidCustomers) OR
        supplier.customerID IN (SELECT idCustomer FROM @ValidCustomers)) 
        AND
        (CAST(odc.createdDate AS DATE)>=@beginDate AND CAST(odc.createdDate AS DATE)<= @endDate )
    FOR JSON PATH,ROOT('odcControl'), INCLUDE_NULL_VALUES
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------

