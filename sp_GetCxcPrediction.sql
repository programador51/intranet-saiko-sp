-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-11-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetCxcPrediction
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2023-07-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/11/2023
-- Description: sp_GetCxcPrediction - Some Notes
CREATE PROCEDURE sp_GetCxcPrediction(
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

    DECLARE @documentNoStatus INT =19;
    DECLARE @idCustomerType INT =1;
    DECLARE @idDocumentType INT =5;

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
            yesterdayCxc,
            todayCxc,
            nextDay,
            next7Days,
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
                CAST(cxc.expirationDate AS DATE) <= @yesterdayAsDate AND
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
                CAST(cxc.expirationDate AS DATE) = @todayAsDate AND
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
                    CAST(cxc.expirationDate AS DATE) >= @nextDayAsDate AND
                    CAST(cxc.expirationDate AS DATE) <= @next7AsDate
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
                    CAST(cxc.expirationDate AS DATE) > @next7AsDate AND
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
    FOR JSON PATH, ROOT('cxc')


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