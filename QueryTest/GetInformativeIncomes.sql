SELECT 
    InformativeIncomes.id AS [id],
    InformativeIncomes.[description],
    Currencies.code AS [currency.code],
    Currencies.symbol AS [currency.symbol],
    Currencies.[description] AS [currency.description],
    TypeInformativeIncomes.[description] AS [type.description],
    TypeInformativeIncomes.[id] AS [type.id],
    '$0.00' AS [applied.text],
    0 AS [applied.number],
    '$0.00' AS [importe.text],
    0 AS [importe.number],
    '$0.00' AS [tc.text],
    0 AS [tc.number]


 FROM InformativeIncomes
 LEFT JOIN Currencies ON  Currencies.currencyID=InformativeIncomes.currency
 LEFT JOIN TypeInformativeIncomes ON TypeInformativeIncomes.id=InformativeIncomes.idTypeInformativeIncomes


FOR JSON PATH, ROOT('InformativeIncomes')
