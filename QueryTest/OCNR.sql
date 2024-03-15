
DECLARE @beginDate DATE;
DECLARE @endDate DATE;
DECLARE @odcStatus INT= 10;
DECLARE @tc DECIMAL(14,4)= 20.15;

DECLARE @subTotalMxn DECIMAL(14,4);
DECLARE @subTotalUsd DECIMAL(14,4);

SELECT 
    @beginDate = DATEADD(DAY, 1, EOMONTH(GETUTCDATE(), -1)),
    @endDate= CAST(EOMONTH(GETUTCDATE()) AS DATE)


SELECT 
    @subTotalUsd=SUM(calculationCostSubtotal)
FROM DocumentItems
WHERE 
    currency='USD' AND
    document IN (
        SELECT 
            idDocument
        FROM Documents 
        WHERE 
            idTypeDocument= 3 AND
            idStatus= @odcStatus AND
            (createdDate >= @beginDate AND createdDate <= @endDate)
    )
SELECT 
    @subTotalMxn=SUM(calculationCostImport + calculationCostIva)
FROM DocumentItems
WHERE 
    currency='MXN' AND
    document IN (
        SELECT 
            idDocument
        FROM Documents 
        WHERE 
            idTypeDocument= 3 AND
            idStatus= @odcStatus AND
            (createdDate >= @beginDate AND createdDate <= @endDate)
    )

SELECT DISTINCT
    CAST(GETUTCDATE() AS DATE) AS recordDate,
    ISNULL(@subTotalMxn,0) AS totalMxn,
    ISNULL(@subTotalUsd,0) AS subtotalUsd,
    @tc AS tc
FROM Documents 
WHERE 
    idTypeDocument= 3 AND
    idStatus= @odcStatus AND
    (createdDate >= @beginDate AND createdDate <= @endDate)
