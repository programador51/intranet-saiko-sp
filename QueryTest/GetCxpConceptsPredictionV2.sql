DECLARE @currencyIWant NVARCHAR(3) =NULL;
DECLARE @currencyToShow NVARCHAR(3)='MXN';
DECLARE @tc DECIMAL (14,4)=18.5;

-- cxpFullReport.currencyCode LIKE ISNULL(@currencyIWant,'')+'%'

DECLARE @todayAsDate DATE;
DECLARE @yesterdayAsDate DATE;
DECLARE @nextDayAsDate DATE;
DECLARE @next7AsDate DATE;
DECLARE @next14AsDate DATE;
DECLARE @idInvoiceCancel INT = 5;
DECLARE @idInvoiceCharged INT = 2;

SELECT 
    @todayAsDate= CAST(GETUTCDATE() AS DATE),
    @yesterdayAsDate= CAST(DATEADD(DAY,-1,GETUTCDATE())  AS DATE),
    @nextDayAsDate=CAST(DATEADD(DAY,1,GETUTCDATE())  AS DATE),
    @next7AsDate=CAST(DATEADD(DAY,7,GETUTCDATE())  AS DATE),
    @next14AsDate=CAST(DATEADD(DAY,14,GETUTCDATE())  AS DATE);

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

--* Declaracion de la tabla para las cxp antes de hoy
DECLARE @yesterdayTable TABLE (
    id INT NOT NULL IDENTITY(1,1),
    socialReason NVARCHAR(256),
    residue DECIMAL(14,4)
)

--* Declaracion de la tabla para las cxp de hoy
DECLARE @todayTable TABLE (
    id INT NOT NULL IDENTITY(1,1),
    socialReason NVARCHAR(256),
    residue DECIMAL(14,4)
)

--* Declaracion de la tabla para las cxp despues de hoy y menos de 7 dias
DECLARE @next7Table TABLE (
    id INT NOT NULL IDENTITY(1,1),
    socialReason NVARCHAR(256),
    residue DECIMAL(14,4)
)

--* Declaracion de la tabla para las cxp despues de 7 dias y menos de 14 dias
DECLARE @less14Table TABLE (
    id INT NOT NULL IDENTITY(1,1),
    socialReason NVARCHAR(256),
    residue DECIMAL(14,4)
)

--* Declaracion de la tabla para las cxp despues de 14 dias
DECLARE @more14Table TABLE (
    id INT NOT NULL IDENTITY(1,1),
    socialReason NVARCHAR(256),
    residue DECIMAL(14,4)
)


--* Declaracion de la tabla para almacenar las razones sociales
DECLARE @tempSocialreason TABLE (
    id INT NOT NULL IDENTITY(1,1),
    socialReason NVARCHAR(256)
)

------------------! INSERCIONES DE RAZON SOCIAL Y SALDOS ---------------------


--* Insercion de todas las cxp antes de hoy en su tabla [@yesterdayTable]
INSERT INTO @yesterdayTable (
    socialReason,
    residue
)

SELECT 
    socialReason,
        SUM(
            CASE 
            WHEN currencyCode = @currencyToShow THEN residue
            WHEN @currencyToShow = 'MXN' AND @currencyToShow!=currencyCode THEN residue *@tc
            WHEN @currencyToShow = 'USD' AND @currencyToShow!=currencyCode THEN residue /@tc
        END
        )
FROM LegalDocuments
WHERE 
    idTypeLegalDocument=1
    AND idLegalDocumentStatus NOT IN (@idInvoiceCancel,@idInvoiceCharged)
    AND idConcept IS NOT NULL
    AND expirationDate <=@yesterdayAsDate
    AND currencyCode LIKE ISNULL(@currencyIWant,'')+'%'
GROUP BY socialReason


--* Insercion de todas las cxp de hoy en su tabla [@todayTable]
INSERT INTO @todayTable (
    socialReason,
    residue
)

SELECT 
    socialReason,
        SUM(
            CASE 
            WHEN currencyCode = @currencyToShow THEN residue
            WHEN @currencyToShow = 'MXN' AND @currencyToShow!=currencyCode THEN residue *@tc
            WHEN @currencyToShow = 'USD' AND @currencyToShow!=currencyCode THEN residue /@tc
        END
        )
FROM LegalDocuments
WHERE 
    idTypeLegalDocument=1
    AND idLegalDocumentStatus NOT IN (@idInvoiceCancel,@idInvoiceCharged)
    AND idConcept IS NOT NULL
    AND expirationDate =@todayAsDate
    AND currencyCode LIKE ISNULL(@currencyIWant,'')+'%'
GROUP BY socialReason

--* Insercion de todas las cxp despues de hoy y antes de 7 dias en su tabla [@next7Table]
INSERT INTO @next7Table (
    socialReason,
    residue
)

SELECT 
    socialReason,
        SUM(
            CASE 
            WHEN currencyCode = @currencyToShow THEN residue
            WHEN @currencyToShow = 'MXN' AND @currencyToShow!=currencyCode THEN residue *@tc
            WHEN @currencyToShow = 'USD' AND @currencyToShow!=currencyCode THEN residue /@tc
        END
        )
FROM LegalDocuments
WHERE 
    idTypeLegalDocument=1
    AND idLegalDocumentStatus NOT IN (@idInvoiceCancel,@idInvoiceCharged)
    AND idConcept IS NOT NULL
    AND (expirationDate >@todayAsDate AND expirationDate<=@next7AsDate)
    AND currencyCode LIKE ISNULL(@currencyIWant,'')+'%'
GROUP BY socialReason


--* Insercion de todas las cxp despues de 7 dias y menos de 14 dias [@less14Table]
INSERT INTO @less14Table (
    socialReason,
    residue
)

SELECT 
    socialReason,
        SUM(
            CASE 
            WHEN currencyCode = @currencyToShow THEN residue
            WHEN @currencyToShow = 'MXN' AND @currencyToShow!=currencyCode THEN residue *@tc
            WHEN @currencyToShow = 'USD' AND @currencyToShow!=currencyCode THEN residue /@tc
        END
        )
FROM LegalDocuments
WHERE 
    idTypeLegalDocument=1
    AND idLegalDocumentStatus NOT IN (@idInvoiceCancel,@idInvoiceCharged)
    AND idConcept IS NOT NULL
    AND (expirationDate >@next7AsDate AND expirationDate<=@next14AsDate)
    AND currencyCode LIKE ISNULL(@currencyIWant,'')+'%'
GROUP BY socialReason


--* Insercion de todas las cxp despues de 14 dias [@more14Table]
INSERT INTO @more14Table (
    socialReason,
    residue
)

SELECT 
    socialReason,
        SUM(
            CASE 
            WHEN currencyCode = @currencyToShow THEN residue
            WHEN @currencyToShow = 'MXN' AND @currencyToShow!=currencyCode THEN residue *@tc
            WHEN @currencyToShow = 'USD' AND @currencyToShow!=currencyCode THEN residue /@tc
        END
        )
FROM LegalDocuments
WHERE 
    idTypeLegalDocument=1
    AND idLegalDocumentStatus NOT IN (@idInvoiceCancel,@idInvoiceCharged)
    AND idConcept IS NOT NULL
    AND expirationDate >@next14AsDate
    AND currencyCode LIKE ISNULL(@currencyIWant,'')+'%'
GROUP BY socialReason


---------------------! INSERCION DE TODAS LAS RAZONES SOCIALE -----------------------

--* Insertar las razones sociales menores a hoy
INSERT INTO @tempSocialreason (
    socialReason
)
SELECT 
    socialReason
FROM @yesterdayTable
--
--
--* Insertar las razones sociales de hoy
INSERT INTO @tempSocialreason (
    socialReason
)
SELECT 
    socialReason
FROM @todayTable
--
--
--* Insertar las razones sociales despues de hoy pero menos de 7 dias
INSERT INTO @tempSocialreason (
    socialReason
)
SELECT 
    socialReason
FROM @next7Table
--
--
--* Insertar las razones sociales despues de 7 dias pero menos de 14 dias
INSERT INTO @tempSocialreason (
    socialReason
)
SELECT 
    socialReason
FROM @less14Table
--
--
--* Insertar las razones sociales despues de 14 dias
INSERT INTO @tempSocialreason (
    socialReason
)
SELECT 
    socialReason
FROM @more14Table

---------------------! ELIMINACION DE RAZONES SOCIALES REPETIDAS -----------------------

INSERT INTO @temTable (
    idCustomer,
    socialReason
)
SELECT DISTINCT
    -1,
    socialReason
FROM @tempSocialreason

---------------------! ACTUALIZACION DE SALDOS EN SUS RESPECTIVOS SEGMENTOS DE DIAS Y RAZONES SOCIALES -----------------------

--* Actualizacion de los saldos antes de hoy
UPDATE temporal SET
    temporal.yesterdayCxc= yesterday.residue
FROM @temTable AS temporal
INNER JOIN @yesterdayTable AS yesterday ON yesterday.socialReason = temporal.socialReason


--* Actualizacion de los saldos  de hoy
UPDATE temporal SET
    temporal.todayCxc= today.residue
FROM @temTable AS temporal
INNER JOIN @todayTable AS today ON today.socialReason = temporal.socialReason


--* Actualizacion de los saldos despues de hoy y menos de 7 dias
UPDATE temporal SET
    temporal.nextDay= next7.residue
FROM @temTable AS temporal
INNER JOIN @next7Table AS next7 ON next7.socialReason = temporal.socialReason


--* Actualizacion de los saldos despues de 7 dias y menos de 14 dias
UPDATE temporal SET
    temporal.next7Days= less14.residue
FROM @temTable AS temporal
INNER JOIN @less14Table AS less14 ON less14.socialReason = temporal.socialReason


--* Actualizacion de los saldos despues de 14 dias.
UPDATE temporal SET
    temporal.next14Days= more14.residue
FROM @temTable AS temporal
INNER JOIN @more14Table AS more14 ON more14.socialReason = temporal.socialReason


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

    FROM @temTable
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