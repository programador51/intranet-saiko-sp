DECLARE @tempCommentsIdTable TABLE (tempId INT IDENTITY(1,1),idComment INT);
DECLARE @tempItemsIdTable TABLE (tempId INT IDENTITY(1,1),idCatalogue INT);

DECLARE @temCommnetTable TABLE (tempId INT, content NVARCHAR(256),[order] INT,idTypeComment INT)
DECLARE @tempCopiedTable TABLE (tempId INT, commentId INT,documentType INT)

-- DECLARE @TESTING_TABLE TABLE( id INT PRIMARY KEY IDENTITY(1,1), someContent NVARCHAR (30),secondId INT)
-- DECLARE @TESTING_TABLE2 TABLE( id INT PRIMARY KEY IDENTITY(1,1), someContent NVARCHAR (30),secondId INT)
-- DECLARE @TESTING_TABLE_ID TABLE( id INT PRIMARY KEY IDENTITY(1,1), tempId INT, secondId INT)


DECLARE @temDocItemTable TABLE (
    idCatalogue INT,
    tempId INT,
    document INT,
    unit_price DECIMAL(14,4),
    unit_cost DECIMAL(14,4),
    quantity INT,
    discount DECIMAL(14,4),
    totalImport DECIMAL(14,4),
    [order] INT,
    createdBy NVARCHAR(30),
    createdDate DATETIME,
    ivaPercentage DECIMAL(5,2),
    [status] TINYINT,
    iva DECIMAL(14,4),
    subTotal DECIMAL(14,4),
    unitSellingPrice DECIMAL(14,4),
    unitPriceBeforeExchange DECIMAL(14,4),
    unitCostBeforeExchange DECIMAL(14,4),
    ivaBeforeExchange DECIMAL(14,4),
    subTotalBeforeExchange DECIMAL(14,4),
    unitSellingPriceBeforeExchange DECIMAL(14,4),
    calculationCostDiscount DECIMAL(14,4),
    calculationCostImport DECIMAL(14,4),
    calculationCostIva DECIMAL(14,4),
    calculationCostSell DECIMAL(14,4),
    calculationCostSubtotal DECIMAL(14,4),
    calculationCostUnitary DECIMAL(14,4),
    calculationPriceDiscount DECIMAL(14,4),
    calculationPriceImport DECIMAL(14,4),
    calculationPriceIva DECIMAL(14,4),
    calculationPriceSell DECIMAL(14,4),
    calculationPriceSubtotal DECIMAL(14,4),
    calculationPriceUnitary DECIMAL(14,4),
    discountPercentage DECIMAL(14,4),
    utility DECIMAL(14,4)
)

DECLARE @temItemTable TABLE (
    tempId INT,
    [description] NVARCHAR(100) ,
    unit_price DECIMAL(14,4),
    unit_cost DECIMAL(14,4),
    SATCODE NVARCHAR(20),
    SATUM NVARCHAR(20),
    iva DECIMAL(4,2),
    uen INT,
    [status] TINYINT,
    createdBy NVARCHAR(30),
    createdDate DATETIME,
    sku NVARCHAR(25),
    currency INT
)

DECLARE @isNewContact BIT
DECLARE @name NVARCHAR(30)
DECLARE @middleName NVARCHAR(30)
DECLARE @lastName1 NVARCHAR(30)
DECLARE @lastName2 NVARCHAR(30)
DECLARE @ladaPhoen NVARCHAR(3)
DECLARE @phone NVARCHAR(30)
DECLARE @ladaCel NVARCHAR(3)
DECLARE @cel NVARCHAR (330)
DECLARE @email NVARCHAR(50)
DECLARE @position NVARCHAR(100)
DECLARE @active TINYINT
DECLARE @idContact INT
DECLARE @idCurrency INT
DECLARE @tc DECIMAL(14,2)
DECLARE @expirationDate DATETIME
DECLARE @reminderDate DATETIME
DECLARE @idProbability INT
DECLARE @creditDays INT
DECLARE @subtotal DECIMAL(14,4)
DECLARE @iva DECIMAL(14,4)
DECLARE @totalAmount DECIMAL(14,4)
DECLARE @createdBy NVARCHAR(30)
DECLARE @idCustomer INT
DECLARE @idExecutive INT
DECLARE @autorizationFlag INT
DECLARE @idPeriocityType INT
DECLARE @periocityValue INT
DECLARE @startDate DATETIME
DECLARE @endDate DATETIME

-- Se inserta los comentarios que esten en la tabla temporal con todos los comentarios
-- se guarda el id de los comentarios insertados en la tabla temporal que relaciona el temporal id y el id
-- actualiza la tabla temporal que tiene los tipos de documentos en donde se repite el id del comentario 
INSERT INTO DocumentsComments(
    documentId,
    comment,
    commentType,
    createdBy,
    lastUpdateBy,
    [order]
)
OUTPUT inserted.id INTO @tempCommentsIdTable(idComment)
SELECT 247,
content,
idTypeComment,
'Adrian Alardin Iracheta',
'Adrian Alardin Iracheta',
[order] FROM @temCommnetTable


UPDATE CopiedComments 
    SET CopiedComments.commentId = temComment.idComment
        FROM @tempCopiedTable AS CopiedComments 
        INNER JOIN @tempCommentsIdTable AS temComment ON CopiedComments.tempId = temComment.tempId

-- UPDATE 

INSERT INTO Catalogue (
    [description],
    unit_price,
    unit_cost,
    SATCODE,
    SATUM,
    iva,
    uen,
    [status],
    createdBy,
    createdDate,
    sku,
    currency
)
OUTPUT inserted.id_code INTO @tempItemsIdTable(idCatalogue)

-- INSERT INTO @TESTING_TABLE2 (
--     someContent,
--     secondId
-- )
-- VALUES 
-- ('hola',7),
-- ('hola',8),
-- ('hola',9),
-- ('hola',10),
-- ('hola',11),
-- ('hola',12),
-- ('hola',13),
-- ('hola',14) 

-- INSERT INTO @TESTING_TABLE (
--     someContent,
--     secondId
-- )
-- OUTPUT inserted.id,inserted.secondId INTO @TESTING_TABLE_ID
-- SELECT someContent,secondId FROM @TESTING_TABLE2

-- SELECT * FROM @TESTING_TABLE_ID


-- USER define table type