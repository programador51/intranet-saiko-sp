-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 06-09-2021

-- Description: Get the document items (product/services) of an specific document with his ID

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  06-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
--  25-10-2021     Jose Luis Perez             1.0.1.0         Evaluate if the document it's a preinvoice or contract	
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetDocumentItems(
    @idDocument INT
)

AS BEGIN

    -------------------------------------------------------------------
    DECLARE @idTypeDocument INT;
    DECLARE @idQuote INT;
    -------------------------------------------------------------------
    -- Get the what type of document is the idDocument requested
    SET @idTypeDocument = (SELECT
        idTypeDocument AS idTypeDocument
    FROM Documents
    WHERE idDocument = @idDocument);
    -------------------------------------------------------------------
    -- Get the id of the quote related of the idDocument requested
    SET @idQuote = (SELECT
            idQuotation AS idQuote
    FROM Documents
    WHERE idDocument = @idDocument);
    -------------------------------------------------------------------
    -- If the document it's a pre-invoice (2) or contract (6) use the same
    -- document items of the quote because are the same for this ones
    IF @idTypeDocument = 2 OR @idTypeDocument = 6
    BEGIN
        SET @idDocument = @idQuote;
    END
    -------------------------------------------------------------------
    SELECT
    DocumentItems.idItem AS id,
    DocumentItems.idItem AS idFront,
    DocumentItems.unit_price AS unitPrice,
    DocumentItems.unit_price AS price,
    DocumentItems.unit_cost AS unitCost,
    DocumentItems.quantity,
    DocumentItems.discount,
    DocumentItems.totalImport,
    DocumentItems.[order] AS 'order',
    DocumentItems.ivaPercentage AS iva,
    DocumentItems.unit_cost AS sellPrice,
    DocumentItems.status AS logicalDelete,
    DocumentItems.idCatalogue,
    DocumentItems.iva AS ivaPrice,
    DocumentItems.subTotal,
    DocumentItems.unitSellingPrice AS puVenta,
    DocumentItems.unitPriceBeforeExchange AS [beforeExchange.price],
    DocumentItems.unitCostBeforeExchange AS [beforeExchange.sellPrice],
    DocumentItems.ivaBeforeExchange AS [beforeExchange.ivaPrice],
    DocumentItems.subTotalBeforeExchange AS [beforeExchange.subTotal],
    DocumentItems.unitSellingPriceBeforeExchange AS [beforeExchange.puVenta],
    FORMAT(DocumentItems.totalImport,'C','mx-MX') AS [parsedPrices.total],
    FORMAT(DocumentItems.subTotal,'C','mx-MX') AS [parsedPrices.subtotal],    
    FORMAT(DocumentItems.iva,'C','mx-MX') AS [parsedPrices.iva],
    FORMAT(DocumentItems.unit_price,'C','mx-MX') AS [parsedPrices.unitPrice],
    FORMAT(DocumentItems.unit_cost,'C','mx-MX') AS [parsedPrices.unitCost],   
    FORMAT(DocumentItems.discount,'C','mx-MX') AS [parsedPrices.discount], 
    Catalogue.id_Code AS catalogue_idCatalogue,
    Catalogue.id_Code AS value,
    Catalogue.description,
    Catalogue.description AS label,
    Catalogue.SATCODE AS satCode,
    Catalogue.SATUM AS satUm,
    Catalogue.uen AS catalogue_idUen, 
    Catalogue.sku AS code,
    UEN.UENID AS idUen,
    UEN.description AS uenDescription,
    CONVERT(BIT,0) AS isNewItem,
    Currencies.currencyID,
    Currencies.code AS currencyCode,
    Currencies.symbol,
    Currencies.description AS currencyDescription
    FROM DocumentItems 
    JOIN Catalogue ON DocumentItems.idCatalogue = Catalogue.id_Code
    JOIN UEN ON Catalogue.uen = UEN.UENID
    JOIN Currencies ON Catalogue.currency = Currencies.currencyID
    WHERE
        document = @idDocument AND
        DocumentItems.status = 1
    ORDER BY DocumentItems.[order] ASC
    FOR JSON PATH, ROOT('docItems')

END