DECLARE @uuid NVARCHAR(256)='7838072D-4694-466D-8EC9-2C5B5936CE78';

SELECT 
    Doc.idDocument AS id,
    Doc.documentNumber,
    Doc.idCurrency,
    Currencies.code,
    CONCAT(Doc.currectFaction,'/',Doc.partialitiesRequested) AS partialities,
    dbo.fn_FormatCurrency(Doc.subTotalAmount)AS import,
    dbo.fn_FormatCurrency(Doc.totalAmount) AS total,
    dbo.fn_FormatCurrency(Doc.amountToPay) AS residue,
    dbo.fn_FormatCurrency(Doc.totalAcreditedAmount) AS acredited
FROM Documents AS Doc
LEFT JOIN Currencies ON Doc.idCurrency=Currencies.currencyID
WHERE Doc.uuid=@uuid AND Doc.idTypeDocument=4 AND Doc.idStatus!=23 ORDER BY Doc.createdDate DESC