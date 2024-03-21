
DECLARE @idExecutive INT = NULL;
DECLARE @idSector INT = NULL;
DECLARE @socialReason NVARCHAR(256) = NULL;
DECLARE @idUen INT=NULL;


DECLARE @idDocumentType INT = 6 
DECLARE @customerStatus TINYINT=1;

 IF OBJECT_ID(N'tempdb..#DocumentByUen') IS NOT NULL 
        BEGIN
        DROP TABLE #DocumentByUen
    END



CREATE TABLE #DocumentByUen (
    id INT NOT NULL IDENTITY(1,1),
    idDocument INT NOT NULL
)

INSERT INTO #DocumentByUen (
    idDocument
)
SELECT DISTINCT
    idDocument
FROM Documents AS contract
LEFT JOIN Customers AS customer ON customer.customerID = contract.idCustomer
LEFT JOIN Users AS executive ON executive.userID=contract.idExecutive
LEFT JOIN DocumentItems AS items ON items.document = contract.idDocument
LEFT JOIN Catalogue AS catalogue ON catalogue.id_code=items.idCatalogue
LEFT JOIN UEN AS uen ON uen.UENID = catalogue.uen
WHERE 
    contract.idTypeDocument=@idDocumentType AND
    customer.customerID IN (
        SELECT 
            CASE 
                WHEN @idExecutive IS NULL THEN wCustomer.customerID
                ELSE @idExecutive
            END
        FROM Customers AS wCustomer
        WHERE wCustomer.[status]=@customerStatus
    ) AND 
    customer.idTypeOfCustomer IN (
        SELECT 
            CASE 
                WHEN @idSector IS NULL THEN id
                ELSE @idSector
            END
        FROM TypeOfCustomer
    ) AND
    customer.socialReason LIKE ISNULL(@socialReason,'') + '%' AND
    uen.UENID IN (
        SELECT 
            CASE
                WHEN @idUen IS NULL THEN UENID
                ELSE @idUen 
            END
        FROM UEN

    )



SELECT 
    contract.documentNumber,
    customer.socialReason,
    (
        SELECT DISTINCT
            uen.[description],
            uen.UENID AS id
        FROM DocumentItems AS items
        LEFT JOIN Catalogue AS catalogue ON catalogue.id_code= items.idCatalogue
        LEFT JOIN UEN AS uen ON uen.UENID= catalogue.uen
        WHERE items.document=contract.idDocument
        FOR JSON PATH, INCLUDE_NULL_VALUES
    ) AS uen,
    --uen va a ser un arreglo de uens, en el servidor se corrige para que sea una concatenacion
    contract.initialDate AS beginDate,
    contract.expirationDate AS endDate,
    currency.code AS currency,
    contract.subTotalAmount AS subTotal,
    executive.initials AS executive,
    (
                SELECT
                    contractItems.quantity,
                    contractItems.[description]
                FROM DocumentItems AS contractItems
                WHERE contractItems.document = contract.idDocument
                FOR JSON PATH, INCLUDE_NULL_VALUES
            ) AS products,
    (
        SELECT 
            quotes.createdDate AS beginDate,
            quotes.expirationDate AS endDate,
            quotes.subTotalAmount AS subTotal,
            currency.code AS currency,
            quoteExecutive.initials AS executive,
            quoteStatus.[description] AS [status],
            (
                SELECT
                    quoteItems.quantity,
                    quoteItems.[description]
                FROM DocumentItems AS quoteItems
                WHERE quoteItems.document = quotes.idDocument
                FOR JSON PATH, INCLUDE_NULL_VALUES
            ) AS products




        FROM Documents AS quotes
        LEFT JOIN Currencies AS quoteCurrency ON quoteCurrency.currencyID = quotes.idCurrency
        LEFT JOIN Users AS quoteExecutive ON quoteExecutive.userID=quotes.idExecutive
        LEFT JOIN DocumentNewStatus AS quoteStatus ON quoteStatus.id=quotes.idStatus
        WHERE quotes.idContractParent = contract.idDocument
        FOR JSON PATH, INCLUDE_NULL_VALUES
    )AS history,
    documentStatus.[description] AS [status]

FROM Documents AS contract
LEFT JOIN Customers AS customer ON customer.customerID = contract.idCustomer
LEFT JOIN Currencies AS currency ON currency.currencyID=contract.idCurrency
LEFT JOIN Users AS executive ON executive.userID=contract.idExecutive
LEFT JOIN DocumentNewStatus AS documentStatus ON documentStatus.id=contract.idStatus
WHERE 
    contract.idTypeDocument=@idDocumentType AND
    customer.customerID IN (
        SELECT 
            CASE 
                WHEN @idExecutive IS NULL THEN wCustomer.customerID
                ELSE @idExecutive
            END
        FROM Customers AS wCustomer
        WHERE wCustomer.[status]=@customerStatus
    ) AND 
    customer.idTypeOfCustomer IN (
        SELECT 
            CASE 
                WHEN @idSector IS NULL THEN id
                ELSE @idSector
            END
        FROM TypeOfCustomer
    ) AND
    customer.socialReason LIKE ISNULL(@socialReason,'') + '%' AND
    contract.idDocument IN (
        SELECT idDocument FROM #DocumentByUen
    )
    --Filtrar por UEN lo haria demasiado lento.

FOR JSON PATH,INCLUDE_NULL_VALUES, ROOT('ContractHistory')


IF OBJECT_ID(N'tempdb..#DocumentByUen') IS NOT NULL 
        BEGIN
        DROP TABLE #DocumentByUen
    END