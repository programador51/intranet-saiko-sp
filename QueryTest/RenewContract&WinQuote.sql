DECLARE @idContract INT =2980;

SELECT * FROM ContractQuotes WHERE idContract=@idContract
SELECT 
    idDocument,
    documentNumber,
    idQuotation,
    idInvoice,
    idOC,
    idCurrency,
    idCustomer,
    idStatus,
    ivaAmount,
    protected,
    subTotalAmount,
    totalAmount,
    reminderDate,
    expirationDate
 FROM Documents WHERE idDocument= @idContract
SELECT * FROM DocumentItems WHERE document= @idContract



-- SELECT * FROM ContractQuotes