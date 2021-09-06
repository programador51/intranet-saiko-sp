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
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetDocumentItems(
    @idDocument INT
)

AS BEGIN

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
    DocumentItems.iva,
    DocumentItems.unit_cost AS sellPrice,
    DocumentItems.status AS logicalDelete,
    DocumentItems.idCatalogue,
    Catalogue.id_Code AS catalogue_idCatalogue,
    Catalogue.id_Code AS value,
    Catalogue.description,
    Catalogue.description AS label,
    Catalogue.SATCODE AS satCode,
    Catalogue.SATUM AS satUm,
    Catalogue.uen AS catalogue_idUen, 
    Catalogue.sku,
    UEN.UENID AS idUen,
    UEN.description AS uenDescription,
    CONVERT(BIT,0) AS isNewItem 
    
FROM Games 

JOIN Catalogue ON Games.idCatalogue = Catalogue.id_Code
JOIN UEN ON Catalogue.uen = UEN.UENID

WHERE 
    document = @idDocument AND
    Games.status = 1
    
ORDER BY Games.[order] ASC

END