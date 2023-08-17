SELECT 
    contract.documentNumber,
    customer.socialReason,
    (
        SELECT DISTINCT
            uen.[description]
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
            *
        FROM Documents AS quotes
    )AS history,
    documentStatus.[description] AS [status]

FROM Documents AS contract
LEFT JOIN Customers AS customer ON customer.customerID = contract.idCustomer
LEFT JOIN Currencies AS currency ON currency.currencyID=contract.idCurrency
LEFT JOIN Users AS executive ON executive.userID=contract.idExecutive
LEFT JOIN DocumentNewStatus AS documentStatus ON documentStatus.id=contract.idStatus
WHERE contract.idTypeDocument=6
FOR JSON PATH,INCLUDE_NULL_VALUES, ROOT('ContractHistory')


