
DECLARE @currencyIWant NVARCHAR(3)= NULL
DECLARE @currencyToShow NVARCHAR(3)= 'MXN'
DECLARE @tc DECIMAL (14,2)= 20.00



DECLARE @todayAsDate DATE;
    DECLARE @tomorrowAsDate DATE;
    DECLARE @next2AsDate DATE;
    DECLARE @next8AsDate DATE;
    DECLARE @next14AsDate DATE;

    DECLARE @documentNoStatus INT =19;
    DECLARE @idCustomerType INT =1;
    DECLARE @idDocumentType INT =5;

    SELECT 
        @todayAsDate= CAST(GETUTCDATE() AS DATE),
        @tomorrowAsDate= CAST(DATEADD(DAY,1,GETUTCDATE())  AS DATE),
        @next2AsDate=CAST(DATEADD(DAY,2,GETUTCDATE())  AS DATE),
        @next8AsDate=CAST(DATEADD(DAY,8,GETUTCDATE())  AS DATE),
        @next14AsDate=CAST(DATEADD(DAY,14,GETUTCDATE())  AS DATE);
        
        CREATE TABLE #Clients
        (
            id INT NOT NULL IDENTITY(1,1),
            idCustomer INT, 
            socialReason NVARCHAR(256)
        )
        CREATE TABLE #ClientsWithCxc
        (
            id INT NOT NULL IDENTITY(1,1),
            idCustomer INT, 
            socialReason NVARCHAR(256),
            todayCxc DECIMAL (14,2),
            tomorrowCxc DECIMAL(14,2),
            next2Days DECIMAL(14,2), -- Estara en la moneda en la que quieren visualizar
            next8Days DECIMAL(14,2),-- Estara en la moneda en la que quieren visualizar
            next14Days DECIMAL(14,2)-- Estara en la moneda en la que quieren visualizar
        )

        INSERT INTO #Clients (
            idCustomer,
            socialReason
        )
        SELECT 
            client.customerID,
            client.socialReason
        FROM Customers AS client
            WHERE 
                client.customerType=@idCustomerType AND
                client.customerID IN (
                    SELECT DISTINCT
                        idCustomer 
                    FROM Documents 
                    WHERE 
                        idTypeDocument=@idDocumentType AND 
                        amountToPay>0 AND 
                        idStatus!=@documentNoStatus
                )



        INSERT INTO #ClientsWithCxc (
            idCustomer,
            socialReason,
            todayCxc,
            tomorrowCxc,
            next2Days,
            next8Days,
            next14Days
        )
        SELECT 
            client.idCustomer,
            client.socialReason,
            ISNULL(
                (SELECT
                SUM(
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN currency.code='MXN' THEN amountToPay
                                ELSE amountToPay * @tc
                            END
                        )
                        WHEN @currencyToShow ='USD' THEN (
                            CASE 
                                WHEN currency.code='USD' THEN amountToPay
                                ELSE amountToPay / @tc
                            END
                        )
                    END
                )
            FROM Documents AS cxc
            LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
            WHERE 
                cxc.idTypeDocument=@idDocumentType AND
                cxc.idStatus!=@documentNoStatus AND
                cxc.amountToPay>0 AND
                CAST(cxc.expirationDate AS DATE) <= @todayAsDate AND
                cxc.idCustomer=client.idCustomer AND
                currency.code LIKE ISNULL(@currencyIWant,'')+'%'
                ),
                0
            ),
            ISNULL(
                (SELECT
                SUM(
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN currency.code='MXN' THEN amountToPay
                                ELSE amountToPay * @tc
                            END
                        )
                        WHEN @currencyToShow ='USD' THEN (
                            CASE 
                                WHEN currency.code='USD' THEN amountToPay
                                ELSE amountToPay / @tc
                            END
                        )
                    END
                )
            FROM Documents AS cxc
            LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
            WHERE 
                cxc.idTypeDocument=@idDocumentType AND
                cxc.idStatus!=@documentNoStatus AND
                cxc.amountToPay>0 AND
                CAST(cxc.expirationDate AS DATE) = @tomorrowAsDate AND
                cxc.idCustomer=client.idCustomer AND
                currency.code LIKE ISNULL(@currencyIWant,'')+'%'
                ),
                0
            ),
            ISNULL(
                (SELECT
                SUM(
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN currency.code='MXN' THEN amountToPay
                                ELSE amountToPay * @tc
                            END
                        )
                        WHEN @currencyToShow ='USD' THEN (
                            CASE 
                                WHEN currency.code='USD' THEN amountToPay
                                ELSE amountToPay / @tc
                            END
                        )
                    END
                )
            FROM Documents AS cxc
            LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
            WHERE 
                cxc.idTypeDocument=@idDocumentType AND
                cxc.idStatus!=@documentNoStatus AND
                cxc.amountToPay>0 AND
                (
                    CAST(cxc.expirationDate AS DATE) >= @next2AsDate AND
                    CAST(cxc.expirationDate AS DATE) <= @next8AsDate
                ) AND
                cxc.idCustomer=client.idCustomer AND
                currency.code LIKE ISNULL(@currencyIWant,'')+'%'
                ),
                0
            ),
            ISNULL(
                (SELECT
                SUM(
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN currency.code='MXN' THEN amountToPay
                                ELSE amountToPay * @tc
                            END
                        )
                        WHEN @currencyToShow ='USD' THEN (
                            CASE 
                                WHEN currency.code='USD' THEN amountToPay
                                ELSE amountToPay / @tc
                            END
                        )
                    END
                )
            FROM Documents AS cxc
            LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
            WHERE 
                cxc.idTypeDocument=@idDocumentType AND
                cxc.idStatus!=@documentNoStatus AND
                cxc.amountToPay>0 AND
                (
                    CAST(cxc.expirationDate AS DATE) > @next8AsDate AND
                    CAST(cxc.expirationDate AS DATE) <= @next14AsDate
                ) AND
                cxc.idCustomer=client.idCustomer AND
                currency.code LIKE ISNULL(@currencyIWant,'')+'%'
                ),
                0
            ),
            
            ISNULL(
                (SELECT
                SUM(
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN currency.code='MXN' THEN amountToPay
                                ELSE amountToPay * @tc
                            END
                        )
                        WHEN @currencyToShow ='USD' THEN (
                            CASE 
                                WHEN currency.code='USD' THEN amountToPay
                                ELSE amountToPay / @tc
                            END
                        )
                    END
                )
            FROM Documents AS cxc
            LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
            WHERE 
                cxc.idTypeDocument=@idDocumentType AND
                cxc.idStatus!=@documentNoStatus AND
                cxc.amountToPay>0 AND
                CAST(cxc.expirationDate AS DATE) > @next14AsDate AND
                cxc.idCustomer=client.idCustomer AND
                currency.code LIKE ISNULL(@currencyIWant,'')+'%'
                ),
                0
            )
        FROM #Clients AS client

    SELECT 
    id,
    idCustomer,
    socialReason,
    todayCxc,
    tomorrowCxc,
    next2Days,
    next8Days,
    next14Days,
    (todayCxc+ tomorrowCxc+ next2Days+ next8Days+ next14Days) AS total

    FROM #ClientsWithCxc
    ORDER BY 
        todayCxc,
        tomorrowCxc,
        next2Days,
        next8Days,
        next14Days,
        socialReason
        ASC
    FOR JSON PATH, ROOT('cxc')



    IF OBJECT_ID(N'tempdb..#Clients') IS NOT NULL 
        BEGIN
            DROP TABLE #Clients
        END
    IF OBJECT_ID(N'tempdb..#ClientsWithCxc') IS NOT NULL 
        BEGIN
            DROP TABLE #ClientsWithCxc
        END



-- SELECT 
--     idCustomer,
--     idCurrency,
--     amountToPay,
--     CAST(expirationDate AS DATE) AS expirationDate
-- FROM Documents
-- WHERE 
--     idTypeDocument=5 AND
--     idStatus!=19 AND 
--     amountToPay>0  
-- ORDER BY idCustomer,idCurrency

--435