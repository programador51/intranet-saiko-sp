DECLARE @currencyIWant NVARCHAR(3) =NULL;
DECLARE @currencyToShow NVARCHAR(3)='MXN';
DECLARE @tc DECIMAL (14,4)=18.5;


--* Declaracion de la tabla temporal para almacenar los diferentes periodos de las cxp
DECLARE @temTable TABLE(
    id INT NOT NULL IDENTITY(1,1),
    idCustomer INT, 
    socialReason NVARCHAR(256),
    yesterdayCxc DECIMAL(14,2),
    todayCxc DECIMAL (14,2),
    nextDay DECIMAL(14,2), -- Estara en la moneda en la que quieren visualizar
    next7Days DECIMAL(14,2),-- Estara en la moneda en la que quieren visualizar
    next14Days DECIMAL(14,2) -- Estara en la moneda en la que quieren visualizar
);
INSERT INTO @temTable(
    idCustomer,
    socialReason,
    yesterdayCxc,
    todayCxc,
    nextDay,
    next7Days,
    next14Days
    )

EXEC sp_GetInvoiceCxpPredictionV2 @currencyIWant,@currencyToShow,@tc
INSERT INTO @temTable(
    idCustomer,
    socialReason,
    yesterdayCxc,
    todayCxc,
    nextDay,
    next7Days,
    next14Days
    )

EXEC sp_GetCxpConceptsPredictionV2 @currencyIWant,@currencyToShow,@tc
-- SELECT * FROM @temTable ORDER BY socialReason

DECLARE @temResultTable TABLE(
    id INT NOT NULL IDENTITY(1,1),
    idCustomer INT, 
    socialReason NVARCHAR(256),
    yesterdayCxc DECIMAL(14,2),
    todayCxc DECIMAL (14,2),
    nextDay DECIMAL(14,2), -- Estara en la moneda en la que quieren visualizar
    next7Days DECIMAL(14,2),-- Estara en la moneda en la que quieren visualizar
    next14Days DECIMAL(14,2) -- Estara en la moneda en la que quieren visualizar
);
INSERT INTO @temResultTable (
    idCustomer,
    socialReason,
    yesterdayCxc,
    todayCxc,
    nextDay,
    next7Days,
    next14Days
)
SELECT 
        idCustomer,
        TRIM(CHAR(9) from socialReason) AS socialReason,
        SUM(ISNULL(yesterdayCxc,0)) AS yesterdayCxc,
        SUM(ISNULL(todayCxc,0)) AS todayCxc,
        SUM(ISNULL(nextDay,0)) AS nextDay,
        SUM(ISNULL(next7Days,0)) AS next7Days,
        SUM(ISNULL(next14Days,0)) AS next14Days
    FROM @temTable
    GROUP BY
        socialReason,
        idCustomer;

SELECT 
        id,
        idCustomer,
        TRIM(CHAR(9) from socialReason) AS socialReason,
        ISNULL(yesterdayCxc,0) AS yesterdayCxc,
        ISNULL(todayCxc,0) AS todayCxc,
        ISNULL(nextDay,0) AS nextDay,
        ISNULL(next7Days,0) AS next7Days,
        ISNULL(next14Days,0) AS next14Days,
        (
        ISNULL(yesterdayCxc,0) +
        ISNULL(todayCxc,0) +
        ISNULL(nextDay,0) +
        ISNULL(next7Days,0) +
        ISNULL(next14Days,0)
        ) AS total

    FROM @temResultTable
    ORDER BY 
        CASE 
            WHEN ISNULL(yesterdayCxc,0) > 0 THEN 1
            WHEN ISNULL(todayCxc,0) > 0 THEN 2
            WHEN ISNULL(nextDay,0) > 0 THEN 3
            WHEN ISNULL(next7Days,0) > 0 THEN 4
            WHEN ISNULL(next14Days,0) > 0 THEN 5
            ELSE 6
        END,
        socialReason
        ASC
     FOR JSON PATH, ROOT('cxp')