SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/15/2024
-- Description: sp_GetReportControl - Some Notes
ALTER PROCEDURE [dbo].[sp_GetReportControl](
    @currency NVARCHAR(3),
    @tc DECIMAL (14,4)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @idCxcType INT =5;
    DECLARE @idOrderType INT =2;
    DECLARE @idOrderStatus INT =4;

    DECLARE @idCxpType INT =4;
    DECLARE @idOdcType INT =3;
    DECLARE @idOdcStatus INT =11;

    -- DECLARE @beginDate DATE =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0);
    -- DECLARE @endDate DATE =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1);

    DECLARE @mxnTotal DECIMAL(14,4);
    DECLARE @usdTotal DECIMAL(14,4);
    DECLARE @total DECIMAL(14,4);

    DECLARE @cxcMxn DECIMAL(14,4);
    DECLARE @cxcUsd DECIMAL(14,4);
    DECLARE @cxcTotal DECIMAL(14,4);

    DECLARE @orderCxcMxn DECIMAL(14,4);
    DECLARE @orderCxcUsd DECIMAL(14,4);
    DECLARE @orderCxcTotal DECIMAL(14,4);

    DECLARE @cxcTotalReport DECIMAL(14,4);
    DECLARE @cxcTotalMxn DECIMAL (14,4);
    DECLARE @cxcTotalUsd DECIMAL (14,4);

    DECLARE @cxpMxn DECIMAL(14,4);
    DECLARE @cxpUsd DECIMAL(14,4);
    DECLARE @cxpTotal DECIMAL(14,4);

    DECLARE @odcCxpMxn DECIMAL(14,4);
    DECLARE @odcCxpUsd DECIMAL(14,4);
    DECLARE @odcCxpTotal DECIMAL(14,4);

    DECLARE @cxpTotalReport DECIMAL(14,4);
    DECLARE @cxpTotalMxn DECIMAL (14,4);
    DECLARE @cxpTotalUsd DECIMAL (14,4);

    DECLARE @monthAgo DATE;
    SELECT @monthAgo = CAST(DATEADD(MONTH, -1, GETUTCDATE()) AS DATE);

    IF(@tc IS NULL) 
        BEGIN
            SELECT TOP(1) @tc= saiko  FROM TCP ORDER BY id DESC;
        
        END

    IF(@currency IS NULL)
        BEGIN
            SELECT @currency='MXN';
        END

    SELECT 
        @mxnTotal= SUM(
            CASE 
                WHEN currency='MXN' THEN currentBalance
                ELSE 0
            END
        ),
        @usdTotal=SUM(
            CASE 
                WHEN currency='USD' THEN currentBalance
                ELSE 0
            END
        )
    FROM BankAccountsV2
    WHERE [status]=1


    SELECT 
        @total = 
            CASE 
                WHEN @currency='MXN' THEN @mxnTotal + (@usdTotal*@tc)
                ELSE @usdTotal + (@mxnTotal/@tc)
            END;


    SELECT
        account.bank AS [bank.id],
        bank.shortName AS [bank.name],
        account.currentBalance AS [bank.banlace],
        account.currency AS [bank.currency],
        CASE 
            WHEN @currency='MXN' AND account.currency=@currency THEN account.currentBalance
            WHEN @currency='USD' AND account.currency=@currency THEN account.currentBalance
            WHEN @currency='MXN' AND account.currency!=@currency THEN account.currentBalance*@tc
            WHEN @currency='USD' AND account.currency!=@currency THEN account.currentBalance/@tc
        END AS [bank.currencyReportBalance] ,
        @mxnTotal AS [bank.total.mxn],
        @usdTotal AS [bank.total.usd],
        @total AS [bank.total.report]
    FROM BankAccountsV2 AS account
    LEFT JOIN Banks AS bank ON bank.bankID=account.bank
    WHERE account.[status]=1
    ORDER BY currency
    FOR JSON PATH,ROOT('bankAccounts')


    --!-----------------------------------------------------------------------
    SELECT 
    @cxcMxn = SUM (
        CASE 
            WHEN cxc.idCurrency=1 THEN cxc.amountToPay
            ELSE 0
        END
    ),
    @cxcUsd = SUM (
        CASE 
            WHEN cxc.idCurrency=2 THEN cxc.amountToPay
            ELSE 0
        END
    )
    FROM Documents AS cxc
    LEFT JOIN LegalDocuments AS invoice ON invoice.uuid = cxc.uuid
    WHERE 
        cxc.idTypeDocument=@idCxcType
        AND cxc.idStatus IN (16,17)
        AND invoice.idLegalDocumentStatus IN (7,9)
        -- AND CAST(cxc.createdDate AS DATE) >=@beginDate
        -- AND CAST(cxc.createdDate AS DATE) <=@endDate

    SELECT 
        @cxcTotal=
            CASE 
                WHEN @currency='MXN' THEN ISNULL(@cxcMxn,0) + (ISNULL(@cxcUsd,0)*@tc)
                WHEN @currency='USD' THEN ISNULL(@cxcUsd,0) + (ISNULL(@cxcMxn,0)/@tc)
            END

    SELECT 
    @orderCxcMxn = SUM (
        CASE 
            WHEN orden.idCurrency=1 THEN ISNULL(orden.totalAmount,0)
            ELSE 0
        END
    ),
    @orderCxcUsd = SUM (
        CASE 
            WHEN orden.idCurrency=2 THEN ISNULL(orden.totalAmount,0)
            ELSE 0
        END
    )
    FROM Documents AS orden
    WHERE 
        orden.idTypeDocument= @idOrderType
        AND orden.idStatus = @idOrderStatus
        -- AND CAST(orden.createdDate AS DATE) >=@beginDate
        -- AND CAST(orden.createdDate AS DATE) <=@endDate

    SELECT 
        @orderCxcTotal=
            CASE 
                WHEN @currency='MXN' THEN ISNULL(@orderCxcMxn,0) + (ISNULL(@orderCxcUsd,0)*@tc)
                WHEN @currency='USD' THEN ISNULL(@orderCxcUsd,0) + (ISNULL(@orderCxcMxn,0)/@tc)
            END
        
    SELECT 
        @cxcTotalMxn= ISNULL(@orderCxcMxn,0) + ISNULL(@cxcMxn,0),
        @cxcTotalUsd= ISNULL(@orderCxcUsd,0) + ISNULL(@cxcUsd,0),
        @cxcTotalReport = ISNULL(@orderCxcTotal,0) + ISNULL(@cxcTotal,0);

    SELECT 
        ISNULL(@cxcMxn,0) AS [cxc.mxn],
        ISNULL(@cxcUsd,0) AS [cxc.usd],
        ISNULL(@cxcTotal,0) AS [cxc.report],
        ISNULL(@orderCxcMxn,0) AS [orden.mxn],
        ISNULL(@orderCxcUsd,0) AS [orden.usd],
        ISNULL(@orderCxcTotal,0) AS [orden.report],
        ISNULL(@cxcTotalMxn,0) AS [total.mxn],
        ISNULL(@cxcTotalUsd,0) AS [total.usd],
        ISNULL(@cxcTotalReport,0) AS [total.report],
        ISNULL(
            (
            SELECT 
                customer.socialReason AS socialReason,
                SUM(orden.totalAmount) AS [total],
                SUM(dbo.fn_currencyConvertion(currency.code,@currency,orden.totalAmount,@tc)) AS [report]
            FROM Documents AS orden 
            LEFT JOIN Customers AS customer ON customer.customerID= orden.idCustomer
            LEFT JOIN Currencies AS currency ON currency.currencyID = orden.idCurrency
            WHERE 
                orden.idTypeDocument= @idOrderType
                AND orden.idStatus= @idOrderStatus
                AND CAST(orden.createdDate AS date) >= @monthAgo
                AND currency.code='MXN'
            GROUP BY customer.socialReason
            ORDER BY customer.socialReason
            FOR JSON PATH
        ),
        '[]'
        ) AS [lessThan1.mxn],
        ISNULL(
            (
            SELECT 
                customer.socialReason,
                SUM(orden.totalAmount) AS [total],
                SUM(dbo.fn_currencyConvertion(currency.code,@currency,orden.totalAmount,@tc)) AS [report]
            FROM Documents AS orden 
            LEFT JOIN Customers AS customer ON customer.customerID= orden.idCustomer
            LEFT JOIN Currencies AS currency ON currency.currencyID = orden.idCurrency
            WHERE 
                orden.idTypeDocument= @idOrderType
                AND orden.idStatus= @idOrderStatus
                AND CAST(orden.createdDate AS date) >= @monthAgo
                AND currency.code='USD'
            GROUP BY customer.socialReason
            ORDER BY customer.socialReason
            FOR JSON PATH
        ),
        '[]'
        ) AS [lessThan1.usd],
        ISNULL(
            (
            SELECT 
                customer.socialReason,
               SUM(orden.totalAmount) AS [total],
               SUM(dbo.fn_currencyConvertion(currency.code,@currency,orden.totalAmount,@tc)) AS [report]
            FROM Documents AS orden 
            LEFT JOIN Customers AS customer ON customer.customerID= orden.idCustomer
            LEFT JOIN Currencies AS currency ON currency.currencyID = orden.idCurrency
            WHERE 
                orden.idTypeDocument= @idOrderType
                AND orden.idStatus= @idOrderStatus
                AND CAST(orden.createdDate AS date) < @monthAgo
                AND currency.code='MXN'
            GROUP BY customer.socialReason
            ORDER BY customer.socialReason
            FOR JSON PATH
        ),
        '[]'
        ) AS [moreThan1.mxn],
        ISNULL(
            (
            SELECT 
                customer.socialReason,
                SUM(orden.totalAmount) AS [total],
                SUM(dbo.fn_currencyConvertion(currency.code,@currency,orden.totalAmount,@tc)) AS [report]
            FROM Documents AS orden 
            LEFT JOIN Customers AS customer ON customer.customerID= orden.idCustomer
            LEFT JOIN Currencies AS currency ON currency.currencyID = orden.idCurrency
            WHERE 
                orden.idTypeDocument= @idOrderType
                AND orden.idStatus= @idOrderStatus
                AND CAST(orden.createdDate AS date) < @monthAgo
                AND currency.code='USD'
            GROUP BY customer.socialReason
            ORDER BY customer.socialReason
            FOR JSON PATH
        ),
        '[]'
        ) AS [moreThan1.usd]
    FOR JSON PATH, ROOT('incomes'), INCLUDE_NULL_VALUES
    --!-----------------------------------------------------------------------


    --!-----------------------------------------------------------------------
    SELECT 
    @cxpMxn = SUM (
        CASE 
            WHEN cxp.idCurrency=1 THEN ISNULL(cxp.amountToPay,0)
            ELSE 0
        END
    ),
    @cxpUsd = SUM (
        CASE 
            WHEN cxp.idCurrency=2 THEN ISNULL(cxp.amountToPay,0)
            ELSE 0
        END
    )
    FROM Documents AS cxp
    LEFT JOIN LegalDocuments AS invoce ON invoce.uuid= cxp.uuid
    WHERE 
        cxp.idTypeDocument=@idCxpType
        AND cxp.idStatus IN (20,21)
        AND invoce.idLegalDocumentStatus IN (1,11)
        AND invoce.idConcept IS NULL
        -- AND CAST(cxc.createdDate AS DATE) >=@beginDate
        -- AND CAST(cxc.createdDate AS DATE) <=@endDate
    SELECT 
    @cxpMxn = @cxpMxn+  SUM (
        CASE 
            WHEN invoice.currencyCode='MXN' THEN ISNULL(invoice.residue,0)
            ELSE 0
        END
    ),
    @cxpUsd = @cxpUsd+ SUM (
        CASE 
            WHEN invoice.currencyCode='USD' THEN ISNULL(invoice.residue,0)
            ELSE 0
        END
    )
    FROM LegalDocuments AS invoice
    WHERE 
        invoice.idLegalDocumentStatus IN (1,11)
        AND invoice.idConcept IS NOT NULL
        -- AND CAST(cxc.createdDate AS DATE) >=@beginDate
        -- AND CAST(cxc.createdDate AS DATE) <=@endDate

    

    SELECT 
        @cxpTotal=
            CASE 
                WHEN @currency='MXN' THEN ISNULL(@cxpMxn,0) + (ISNULL(@cxpUsd,0)*@tc)
                WHEN @currency='USD' THEN ISNULL(@cxpUsd,0) + (ISNULL(@cxpMxn,0)/@tc)
            END

    SELECT 
    @odcCxpMxn = SUM (
        CASE 
            WHEN odc.idCurrency=1 THEN ISNULL(odc.totalAmount,0)
            ELSE 0
        END
    ),
    @odcCxpUsd = SUM (
        CASE 
            WHEN odc.idCurrency=2 THEN ISNULL(odc.totalAmount,0)
            ELSE 0
        END
    )
    FROM Documents AS odc
    WHERE 
        odc.idTypeDocument=@idOdcType
        AND odc.idStatus =@idOdcStatus
        -- AND CAST(odc.createdDate AS DATE) >=@beginDate
        -- AND CAST(odc.createdDate AS DATE) <=@endDate

    SELECT 
        @odcCxpTotal=
            CASE 
                WHEN @currency='MXN' THEN ISNULL(@odcCxpMxn,0) + (ISNULL(@odcCxpUsd,0)*@tc)
                WHEN @currency='USD' THEN ISNULL(@odcCxpUsd,0) + (ISNULL(@odcCxpMxn,0)/@tc)
            END
        
    SELECT 
        @cxpTotalMxn= ISNULL(@odcCxpMxn,0) + ISNULL(@cxpMxn,0),
        @cxpTotalUsd= ISNULL(@odcCxpUsd,0) + ISNULL(@cxpUsd,0),
        @cxpTotalReport = ISNULL(@odcCxpTotal,0) + ISNULL(@cxpTotal,0);

    SELECT 
        ISNULL(@cxpMxn,0) AS [cxp.mxn],
        ISNULL(@cxpUsd,0) AS [cxp.usd],
        ISNULL(@cxpTotal,0) AS [cxp.report],
        ISNULL(@odcCxpMxn,0) AS [odc.mxn],
        ISNULL(@odcCxpUsd,0) AS [odc.usd],
        ISNULL(@odcCxpTotal,0) AS [odc.report],
        ISNULL(@cxpTotalMxn,0) AS [total.mxn],
        ISNULL(@cxpTotalUsd,0) AS [total.usd],
        ISNULL(@cxpTotalReport,0) AS [total.report],
        ISNULL(
            (
            SELECT 
                customer.socialReason,
                SUM(odc.totalAmount) AS [total],
                SUM(dbo.fn_currencyConvertion(currency.code,@currency,odc.totalAmount,@tc)) AS [report]
            FROM Documents AS odc
            LEFT JOIN Customers AS customer ON customer.customerID= odc.idCustomer
            LEFT JOIN Currencies AS currency ON currency.currencyID = odc.idCurrency
            WHERE 
                odc.idTypeDocument=@idOdcType
                AND odc.idStatus =@idOdcStatus
                AND CAST(odc.createdDate AS date) >= @monthAgo
                AND currency.code='MXN'
            GROUP BY customer.socialReason
            ORDER BY customer.socialReason
            FOR JSON PATH
        ),
        '[]'
        ) AS [lessThan1.mxn],
        ISNULL(
            (
            SELECT 
                customer.socialReason,
                SUM(odc.totalAmount) AS [total],
                SUM(dbo.fn_currencyConvertion(currency.code,@currency,odc.totalAmount,@tc)) AS [report]
            FROM Documents AS odc
            LEFT JOIN Customers AS customer ON customer.customerID= odc.idCustomer
            LEFT JOIN Currencies AS currency ON currency.currencyID = odc.idCurrency
            WHERE 
                odc.idTypeDocument=@idOdcType
                AND odc.idStatus =@idOdcStatus
                AND CAST(odc.createdDate AS date) >= @monthAgo
                AND currency.code='USD'
            GROUP BY customer.socialReason
            ORDER BY customer.socialReason
            FOR JSON PATH
        ),
        '[]'
        ) AS [lessThan1.usd],
        ISNULL(
            (
            SELECT 
                customer.socialReason,
                SUM(odc.totalAmount) AS [total],
                SUM(dbo.fn_currencyConvertion(currency.code,@currency,odc.totalAmount,@tc)) AS [report]
            FROM Documents AS odc
            LEFT JOIN Customers AS customer ON customer.customerID= odc.idCustomer
            LEFT JOIN Currencies AS currency ON currency.currencyID = odc.idCurrency
            WHERE 
                odc.idTypeDocument=@idOdcType
                AND odc.idStatus =@idOdcStatus
                AND CAST(odc.createdDate AS date) < @monthAgo
                AND currency.code='MXN'
            GROUP BY customer.socialReason
            ORDER BY customer.socialReason
            FOR JSON PATH
        ),
        '[]'
        ) AS [moreThan1.mxn],
        ISNULL(
            (
            SELECT 
                customer.socialReason,
                SUM(odc.totalAmount) AS [total],
                SUM(dbo.fn_currencyConvertion(currency.code,@currency,odc.totalAmount,@tc)) AS [report]
            FROM Documents AS odc
            LEFT JOIN Customers AS customer ON customer.customerID= odc.idCustomer
            LEFT JOIN Currencies AS currency ON currency.currencyID = odc.idCurrency
            WHERE 
                odc.idTypeDocument=@idOdcType
                AND odc.idStatus =@idOdcStatus
                AND CAST(odc.createdDate AS date) < @monthAgo
                AND currency.code='USD'
            GROUP BY customer.socialReason
            ORDER BY customer.socialReason
            FOR JSON PATH
        ),
        '[]'
        ) AS [moreThan1.usd]
    FOR JSON PATH,  ROOT('outcomes'), INCLUDE_NULL_VALUES
    --!-----------------------------------------------------------------------

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
GO
