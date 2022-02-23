SELECT 
    Incomes.id,
    Incomes.[description] AS incomeDescription,
    IncomesTypes.[description] AS incomeType
FROM InformativeIncomes AS Incomes 
LEFT JOIN TypeInformativeIncomes AS IncomesTypes ON Incomes.idTypeInformativeIncomes=IncomesTypes.id
WHERE Incomes.[status]=1