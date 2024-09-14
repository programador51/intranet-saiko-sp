-- Tabla donde esta toda la informacion del producto que va al documento.
DECLARE @itemsToDocuments TABLE (
    id INT PRIMARY KEY NOT NULL IDENTITY (1,1),
    itemId INT, 
    temporalId NVARCHAR (100)
)


-- Tabla que simula la insercion de los productos en el catalogo
DECLARE @simulateCatalogue TABLE (
    id INT PRIMARY KEY NOT NULL IDENTITY (1,1),
    [description] NVARCHAR (100) NOT NULL
)

-- Tabla que almacena los id insertados en la tabla de catalogo
DECLARE @itemsInsertedCatalgue TABLE (
    id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    itemId INT NOT NULL -- ID insertado
)
-- Esta tabla se utlizara para guardar los productos que se necesitan crear.
-- El id de esta tabla se utilizara para actualizar el itemId
-- Una vez actualizada esta tabla, se utilizara para actualizar la tabla de @itemsToDocuments
-- Una vez actualizada @itemsToDocuments se inserta relacionada al documento.
DECLARE @referenceTableToCatalogue TABLE (
    id INT PRIMARY KEY NOT NULL IDENTITY (1,1),
    itemsToDocumentsId INT NOT NULL,
    itemId INT
)

-- Se llena la tabla de los items de documento (esto vendra de parametros)
INSERT INTO @itemsToDocuments (
    itemId,
    temporalId
)
    VALUES
        (
            58,
            NULL
        ),
        (
            NULL,
            'ABCD'
        ),
        (
            60,
            NULL
        ),
        (
            NULL,
            'UIOP'
        )

-- Accion que guarda los id de los items insertados en el catalogo
INSERT INTO @simulateCatalogue (
    [description]
)
OUTPUT inserted.id INTO @itemsInsertedCatalgue(itemId)

SELECT temporalId FROM @itemsToDocuments WHERE itemId IS NULL

-- Accion que guarda los itmes que necesitan ser craedos en una tabla aparte 
INSERT INTO @referenceTableToCatalogue (
    itemsToDocumentsId
)
SELECT id FROM @itemsToDocuments WHERE itemId IS NULL


SELECT * FROM @itemsToDocuments
SELECT * FROM @referenceTableToCatalogue
SELECT * FROM @itemsInsertedCatalgue

UPDATE referensTable SET
    referensTable.itemId = insertedItems.itemId
    FROM @referenceTableToCatalogue AS referensTable
    INNER JOIN @itemsInsertedCatalgue AS insertedItems
    ON referensTable.id= insertedItems.id

UPDATE itemsToDocuments SET
    itemsToDocuments.itemId = referensTable.itemId
    FROM @itemsToDocuments AS itemsToDocuments
    INNER JOIN @referenceTableToCatalogue AS referensTable
    ON itemsToDocuments.id= referensTable.itemsToDocumentsId

SELECT * FROM @referenceTableToCatalogue
SELECT * FROM @itemsToDocuments

