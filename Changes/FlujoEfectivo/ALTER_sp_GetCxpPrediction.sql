SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/11/2023
-- Description: sp_GetCxpPrediction - Some Notes
ALTER PROCEDURE [dbo].[sp_GetCxpPrediction](
    @currencyIWant NVARCHAR(3),
    @currencyToShow NVARCHAR(3),
    @tc DECIMAL (14,4)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    IF OBJECT_ID(N'tempdb..#Clients') IS NOT NULL 
        BEGIN
            DROP TABLE #Clients
        END
    IF OBJECT_ID(N'tempdb..#ClientsWithCxc') IS NOT NULL 
        BEGIN
            DROP TABLE #ClientsWithCxc
        END

    DECLARE @todayAsDate DATE;
    DECLARE @yesterdayAsDate DATE;
    DECLARE @nextDayAsDate DATE;
    DECLARE @next7AsDate DATE;
    DECLARE @next14AsDate DATE;

    DECLARE @idCustomerType INT =2;
    DECLARE @idPaidStatus INT =2;
    -- DECLARE @documentNoStatus INT =23;
    -- DECLARE @idDocumentType INT =4;

    SELECT 
        @todayAsDate= CAST(GETUTCDATE() AS DATE),
        @yesterdayAsDate= CAST(DATEADD(DAY,-1,GETUTCDATE())  AS DATE),
        @nextDayAsDate=CAST(DATEADD(DAY,1,GETUTCDATE())  AS DATE),
        @next7AsDate=CAST(DATEADD(DAY,7,GETUTCDATE())  AS DATE),
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
            yesterdayCxc DECIMAL(14,2),
            todayCxc DECIMAL (14,2),
            nextDay DECIMAL(14,2), -- Estara en la moneda en la que quieren visualizar
            next7Days DECIMAL(14,2),-- Estara en la moneda en la que quieren visualizar
            next14Days DECIMAL(14,2)-- Estara en la moneda en la que quieren visualizar
        )

        INSERT INTO #Clients (
            idCustomer,
            socialReason
        )
        SELECT 
            -- client.customerID,
            -1,
            client.socialReason
        FROM Customers AS client
            WHERE 
                client.customerType=@idCustomerType AND
                client.customerID IN (
                    SELECT DISTINCT
                        customer.customerID 
                    FROM CxpFullReport AS cxpFullReport
                    LEFT JOIN Customers AS customer ON customer.socialReason=cxpFullReport.socialReason 
                    WHERE 
                        -- cxpFullReport.residue>0
                        cxpFullReport.idLegalDocumentStatus != @idPaidStatus -- ! NUEVO
                        AND customer.customerType=@idCustomerType
                )


        INSERT INTO #ClientsWithCxc (
            idCustomer,
            socialReason,
            yesterdayCxc,
            todayCxc,
            nextDay,
            next7Days,
            next14Days
        )
        SELECT DISTINCT
            -- client.idCustomer,
            -1,
            client.socialReason,
            ISNULL(
                (SELECT
                SUM(
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN cxpFullReport.currency='MXN' THEN cxpFullReport.residue
                                ELSE cxpFullReport.residue * @tc
                            END
                        )
                        WHEN @currencyToShow ='USD' THEN (
                            CASE 
                                WHEN cxpFullReport.currency='USD' THEN cxpFullReport.residue
                                ELSE cxpFullReport.residue / @tc
                            END
                        )
                    END
                )
            FROM CxpFullReport AS cxpFullReport
            LEFT JOIN Customers AS customer ON customer.socialReason=cxpFullReport.socialReason
            WHERE 
                -- cxpFullReport.residue>0 AND
                cxpFullReport.idLegalDocumentStatus != @idPaidStatus AND -- ! NUEVO
                CAST(cxpFullReport.expiration AS DATE) < @todayAsDate AND
                cxpFullReport.socialReason=client.socialReason AND
                customer.customerType=@idCustomerType AND
                cxpFullReport.currency LIKE ISNULL(@currencyIWant,'')+'%'
                ),
                0
            ),
            ISNULL(
                (SELECT
                SUM(
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN cxpFullReport.currency='MXN' THEN cxpFullReport.residue
                                ELSE cxpFullReport.residue * @tc
                            END
                        )
                        WHEN @currencyToShow ='USD' THEN (
                            CASE 
                                WHEN cxpFullReport.currency='USD' THEN cxpFullReport.residue
                                ELSE cxpFullReport.residue / @tc
                            END
                        )
                    END
                )
            FROM CxpFullReport AS cxpFullReport
            LEFT JOIN Customers AS customer ON customer.socialReason=cxpFullReport.socialReason
            WHERE 
                -- cxpFullReport.residue>0 AND
                cxpFullReport.idLegalDocumentStatus != @idPaidStatus AND -- ! NUEVO
                CAST(cxpFullReport.expiration AS DATE) = @todayAsDate AND
                cxpFullReport.socialReason=client.socialReason AND
                customer.customerType=@idCustomerType AND
                cxpFullReport.currency LIKE ISNULL(@currencyIWant,'')+'%'
                ),
                0
            ),
            ISNULL(
                (SELECT
                SUM(
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN cxpFullReport.currency='MXN' THEN cxpFullReport.residue
                                ELSE cxpFullReport.residue * @tc
                            END
                        )
                        WHEN @currencyToShow ='USD' THEN (
                            CASE 
                                WHEN cxpFullReport.currency='USD' THEN cxpFullReport.residue
                                ELSE cxpFullReport.residue / @tc
                            END
                        )
                    END
                )
            FROM CxpFullReport AS cxpFullReport
            LEFT JOIN Customers AS customer ON customer.socialReason=cxpFullReport.socialReason
            WHERE 
                cxpFullReport.residue>0 AND
                (
                    CAST(cxpFullReport.expiration AS DATE) >= @nextDayAsDate AND
                    CAST(cxpFullReport.expiration AS DATE) <= @next7AsDate
                ) AND
                cxpFullReport.socialReason=client.socialReason AND
                customer.customerType=@idCustomerType AND
                cxpFullReport.currency LIKE ISNULL(@currencyIWant,'')+'%'
                ),
                0
            ),
            ISNULL(
                (SELECT
                SUM(
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN cxpFullReport.currency='MXN' THEN cxpFullReport.residue
                                ELSE cxpFullReport.residue * @tc
                            END
                        )
                        WHEN @currencyToShow ='USD' THEN (
                            CASE 
                                WHEN cxpFullReport.currency='USD' THEN cxpFullReport.residue
                                ELSE cxpFullReport.residue / @tc
                            END
                        )
                    END
                )
            FROM CxpFullReport AS cxpFullReport
            LEFT JOIN Customers AS customer ON customer.socialReason=cxpFullReport.socialReason
            WHERE 
                -- cxpFullReport.residue>0 AND
                cxpFullReport.idLegalDocumentStatus != @idPaidStatus AND -- ! NUEVO
                (
                    CAST(cxpFullReport.expiration AS DATE) > @next7AsDate AND
                    CAST(cxpFullReport.expiration AS DATE) <= @next14AsDate
                ) AND
                cxpFullReport.socialReason=client.socialReason AND
                customer.customerType=@idCustomerType AND
                cxpFullReport.currency LIKE ISNULL(@currencyIWant,'')+'%'
                ),
                0
            ),
             ISNULL(
                (SELECT
                SUM(
                    CASE 
                        WHEN @currencyToShow ='MXN' THEN (
                            CASE 
                                WHEN cxpFullReport.currency='MXN' THEN cxpFullReport.residue
                                ELSE cxpFullReport.residue * @tc
                            END
                        )
                        WHEN @currencyToShow ='USD' THEN (
                            CASE 
                                WHEN cxpFullReport.currency='USD' THEN cxpFullReport.residue
                                ELSE cxpFullReport.residue / @tc
                            END
                        )
                    END
                )
            FROM CxpFullReport AS cxpFullReport
            LEFT JOIN Customers AS customer ON customer.socialReason=cxpFullReport.socialReason
            WHERE 
                -- cxpFullReport.residue>0 AND
                cxpFullReport.idLegalDocumentStatus != @idPaidStatus AND -- ! NUEVO
                CAST(cxpFullReport.expiration AS DATE) > @next14AsDate AND
                cxpFullReport.socialReason=client.socialReason AND
                customer.customerType=@idCustomerType AND
                cxpFullReport.currency LIKE ISNULL(@currencyIWant,'')+'%'
                ),
                0
            )
        FROM CxpFullReport AS client
        WHERE 
            client.idLegalDocumentStatus != @idPaidStatus

    SELECT 
    id,
    idCustomer,
    TRIM(CHAR(9) from socialReason) AS socialReason,
    yesterdayCxc,
    todayCxc,
    nextDay,
    next7Days,
    next14Days,
    (yesterdayCxc+todayCxc+ nextDay+ next7Days+ next14Days) AS total

    FROM #ClientsWithCxc
    ORDER BY 
        CASE 
            WHEN yesterdayCxc > 0 THEN 1
            WHEN todayCxc > 0 THEN 2
            WHEN nextDay > 0 THEN 3
            WHEN next7Days > 0 THEN 4
            WHEN next14Days > 0 THEN 5
            ELSE 6
        END,
        socialReason
        ASC
     FOR JSON PATH, ROOT('cxp')



    IF OBJECT_ID(N'tempdb..#Clients') IS NOT NULL 
        BEGIN
            DROP TABLE #Clients
        END
    IF OBJECT_ID(N'tempdb..#ClientsWithCxc') IS NOT NULL 
        BEGIN
            DROP TABLE #ClientsWithCxc
        END

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
GO
