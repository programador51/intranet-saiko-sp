DECLARE @totalMxn DECIMAL(14,2);    
DECLARE @totalUSD DECIMAL(14,2);
DECLARE @currencyIWant NVARCHAR(3)= 'MXN'
DECLARE @currencyToShow NVARCHAR(3)= 'MXN'
DECLARE @tc DECIMAL (14,2)= 20.00



DECLARE @todayAsDate DATE;
DECLARE @tomorrowAsDate DATE;
DECLARE @next2AsDate DATE;
DECLARE @next8AsDate DATE;
DECLARE @next14AsDate DATE;

SELECT 
    @todayAsDate= CAST(GETUTCDATE() AS DATE),
    @tomorrowAsDate= CAST(DATEADD(DAY,1,GETUTCDATE())  AS DATE),
    @next2AsDate=CAST(DATEADD(DAY,2,GETUTCDATE())  AS DATE),
    @next8AsDate=CAST(DATEADD(DAY,8,GETUTCDATE())  AS DATE),
    @next14AsDate=CAST(DATEADD(DAY,14,GETUTCDATE())  AS DATE);



IF OBJECT_ID(N'tempdb..#Clients') IS NOT NULL 
        BEGIN
        DROP TABLE #Clients
    END
IF OBJECT_ID(N'tempdb..#ClientsWithCxc') IS NOT NULL 
        BEGIN
        DROP TABLE #ClientsWithCxc
    END
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
            client.customerType=1 AND
            client.customerID IN (
                SELECT DISTINCT
                    idCustomer 
                FROM Documents 
                WHERE 
                    idTypeDocument=5 AND 
                    amountToPay>0 AND 
                    idStatus!=19
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
            cxc.idTypeDocument=5 AND
            cxc.idStatus!=19 AND
            cxc.amountToPay>0 AND
            CAST(cxc.expirationDate AS DATE) <= @todayAsDate AND
            cxc.idCustomer=client.idCustomer AND
            currency.code LIKE ISNULL(@currencyIWant,'')+'%'
            ),
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
            cxc.idTypeDocument=5 AND
            cxc.idStatus!=19 AND
            cxc.amountToPay>0 AND
            CAST(cxc.expirationDate AS DATE) = @tomorrowAsDate AND
            cxc.idCustomer=client.idCustomer AND
            currency.code LIKE ISNULL(@currencyIWant,'')+'%'
            ),
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
            cxc.idTypeDocument=5 AND
            cxc.idStatus!=19 AND
            cxc.amountToPay>0 AND
            (
                CAST(cxc.expirationDate AS DATE) >= @next2AsDate AND
                CAST(cxc.expirationDate AS DATE) <= @next8AsDate
            ) AND
            cxc.idCustomer=client.idCustomer AND
            currency.code LIKE ISNULL(@currencyIWant,'')+'%'
            ),
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
            cxc.idTypeDocument=5 AND
            cxc.idStatus!=19 AND
            cxc.amountToPay>0 AND
            (
                CAST(cxc.expirationDate AS DATE) >= @next8AsDate AND
                CAST(cxc.expirationDate AS DATE) <= @next14AsDate
            ) AND
            cxc.idCustomer=client.idCustomer AND
            currency.code LIKE ISNULL(@currencyIWant,'')+'%'
            ),
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
            cxc.idTypeDocument=5 AND
            cxc.idStatus!=19 AND
            cxc.amountToPay>0 AND
            CAST(cxc.expirationDate AS DATE) >= @next14AsDate AND
            cxc.idCustomer=client.idCustomer AND
            currency.code LIKE ISNULL(@currencyIWant,'')+'%'
            )
    FROM #Clients AS client

---------------------------------------------------------------------------------------------





SELECT 
    @totalMxn = SUM(
    CASE 
        WHEN currency.code='MXN' THEN bankAcount.currentAmount
        ELSE 0
    END
    ),
    @totalUSD = SUM(
    CASE 
        WHEN currency.code='USD' THEN bankAcount.currentAmount
        ELSE 0
    END
)
FROM BankAccounts AS bankAcount
LEFT JOIN Currencies AS currency ON currency.currencyID= bankAcount.currencyID


SELECT 
    @totalMxn AS totalMxn,
    @totalUSD AS totalUSD,
    (
    SELECT 
        ISNULL(bank.commercialName,'ND') AS [name],
        bankAcount.comments AS [description],
        CASE 
            WHEN @currencyToShow ='MXN' THEN (
                CASE 
                    WHEN currency.code='MXN' THEN bankAcount.currentAmount 
                    ELSE bankAcount.currentAmount * @tc
                END
            )
            ELSE (
                CASE 
                    WHEN currency.code='USD' THEN bankAcount.currentAmount 
                    ELSE bankAcount.currentAmount / @tc
                END
            )
        END,
        bankAcount.accountNumber AS account,
        currency.code AS currency,
        ISNULL(bankAcount.currentAmount ,0) AS amount

    FROM BankAccounts AS bankAcount
    LEFT JOIN Banks AS bank ON bank.bankID=bankAcount.bankID
    LEFT JOIN Currencies AS currency ON currency.currencyID= bankAcount.currencyID
    WHERE bankAcount.[status]=1 AND
    currency.code LIKE ISNULL(@currencyIWant,'') +'%'
    FOR JSON PATH
    ) AS banckAccounts,
    (
        SELECT 
            client.customerID AS id,
            client.socialReason AS socialReason,
            (
                SELECT 
                    cxc.idDocument,
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN currency.code='MXN' THEN cxc.amountToPay
                                ELSE cxc.amountToPay * @tc
                            END
                        )
                        ELSE (
                            CASE 
                                WHEN currency.code='USD' THEN cxc.amountToPay
                                ELSE cxc.amountToPay / @tc
                            END
                        )
                    END AS amountToPay
                FROM Documents AS cxc
                LEFT JOIN #Clients AS subClient ON subClient.idCustomer=cxc.idCustomer
                LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
                WHERE 
                    cxc.idTypeDocument=5 AND
                    cxc.amountToPay > 0 AND
                    cxc.idStatus != 19 AND
                    cast(cxc.expirationDate AS DATE) <= cast(GETUTCDATE() AS DATE) AND
                    client.customerID =subClient.idCustomer AND
                    currency.code LIKE ISNULL(@currencyIWant,'') +'%'
                FOR JSON PATH,INCLUDE_NULL_VALUES
            ) AS todayCxc,
            (
                SELECT 
                    cxc.idDocument,
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN currency.code='MXN' THEN cxc.amountToPay
                                ELSE cxc.amountToPay * @tc
                            END
                        )
                        ELSE (
                            CASE 
                                WHEN currency.code='USD' THEN cxc.amountToPay
                                ELSE cxc.amountToPay / @tc
                            END
                        )
                    END AS amountToPay
                FROM Documents AS cxc
                LEFT JOIN #Clients AS subClient ON subClient.idCustomer=cxc.idCustomer
                LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
                WHERE 
                    cxc.idTypeDocument=5 AND
                    cxc.amountToPay > 0 AND
                    cxc.idStatus != 19 AND
                    cast(cxc.expirationDate AS DATE) = cast(DATEADD(DAY,1,GETUTCDATE())  AS DATE) AND
                    client.customerID =subClient.idCustomer AND
                    currency.code LIKE ISNULL(@currencyIWant,'') +'%'
                FOR JSON PATH,INCLUDE_NULL_VALUES
            ) AS tomorrowCxc,
            (
                SELECT 
                    cxc.idDocument,
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN currency.code='MXN' THEN cxc.amountToPay
                                ELSE cxc.amountToPay * @tc
                            END
                        )
                        ELSE (
                            CASE 
                                WHEN currency.code='USD' THEN cxc.amountToPay
                                ELSE cxc.amountToPay / @tc
                            END
                        )
                    END AS amountToPay
                FROM Documents AS cxc
                LEFT JOIN #Clients AS subClient ON subClient.idCustomer=cxc.idCustomer
                LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
                WHERE 
                    cxc.idTypeDocument=5 AND
                    cxc.amountToPay > 0 AND
                    cxc.idStatus != 19 AND
                    (cast(cxc.expirationDate AS DATE) >= cast(DATEADD(DAY,2,GETUTCDATE()) AS DATE) AND 
                    cast(cxc.expirationDate AS DATE) <= cast(DATEADD(DAY,7,GETUTCDATE()) AS DATE)) AND
                    client.customerID =subClient.idCustomer AND
                    currency.code LIKE ISNULL(@currencyIWant,'') +'%'
                FOR JSON PATH,INCLUDE_NULL_VALUES
            ) AS next3Cxc,
            (
                SELECT 
                    cxc.idDocument,
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN currency.code='MXN' THEN cxc.amountToPay
                                ELSE cxc.amountToPay * @tc
                            END
                        )
                        ELSE (
                            CASE 
                                WHEN currency.code='USD' THEN cxc.amountToPay
                                ELSE cxc.amountToPay / @tc
                            END
                        )
                    END AS amountToPay
                FROM Documents AS cxc
                LEFT JOIN #Clients AS subClient ON subClient.idCustomer=cxc.idCustomer
                LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
                WHERE 
                    cxc.idTypeDocument=5 AND
                    cxc.amountToPay > 0 AND
                    cxc.idStatus != 19 AND
                    (cast(cxc.expirationDate AS DATE) >= cast(DATEADD(DAY,7,GETUTCDATE()) AS DATE) AND 
                    cast(cxc.expirationDate AS DATE) <= cast(DATEADD(DAY,14,GETUTCDATE()) AS DATE)) AND
                    client.customerID =subClient.idCustomer AND
                    currency.code LIKE ISNULL(@currencyIWant,'') +'%'
                FOR JSON PATH,INCLUDE_NULL_VALUES
            ) AS next7Cxc,
            (
                SELECT 
                    cxc.idDocument,
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN currency.code='MXN' THEN cxc.amountToPay
                                ELSE cxc.amountToPay * @tc
                            END
                        )
                        ELSE (
                            CASE 
                                WHEN currency.code='USD' THEN cxc.amountToPay
                                ELSE cxc.amountToPay / @tc
                            END
                        )
                    END AS amountToPay
                FROM Documents AS cxc
                LEFT JOIN #Clients AS subClient ON subClient.idCustomer=cxc.idCustomer
                LEFT JOIN Currencies AS currency ON currency.currencyID= cxc.idCurrency
                WHERE 
                    cxc.idTypeDocument=5 AND
                    cxc.amountToPay > 0 AND
                    cxc.idStatus != 19 AND
                    cast(cxc.expirationDate AS DATE) > cast(DATEADD(DAY,14,GETUTCDATE()) AS DATE) AND
                    client.customerID =subClient.idCustomer AND
                    currency.code LIKE ISNULL(@currencyIWant,'') +'%'
                FOR JSON PATH,INCLUDE_NULL_VALUES
            ) AS next14Cxc
        FROM Customers AS client
        WHERE 
            client.customerType=1 AND
            client.customerID IN (
                SELECT DISTINCT
                    idCustomer 
                FROM Documents 
                WHERE 
                    idTypeDocument=5 AND 
                    amountToPay>0 AND 
                    idStatus!=19
            )
        FOR JSON PATH,INCLUDE_NULL_VALUES
    ) AS clients
FOR JSON PATH , ROOT('report')
IF OBJECT_ID(N'tempdb..#Clients') IS NOT NULL 
        BEGIN
        DROP TABLE #Clients
    END
IF OBJECT_ID(N'tempdb..#ClientsWithCxc') IS NOT NULL 
        BEGIN
        DROP TABLE #ClientsWithCxc
    END


SELECT 
*
FROM Documents
WHERE
    idTypeDocument=5 AND 
    idStatus!=19 AND
    amountToPay >0 AND
    idCustomer=435