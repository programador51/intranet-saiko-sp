-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-15-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetReportControl
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
--	2024-02-15		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetReportControl')
    BEGIN 

        DROP PROCEDURE sp_GetReportControl;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/15/2024
-- Description: sp_GetReportControl - Some Notes
CREATE PROCEDURE sp_GetReportControl(
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

    DECLARE @beginDate DATE =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0);
    DECLARE @endDate DATE =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1);

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
    WHERE 
        cxc.idTypeDocument=@idCxcType
        AND cxc.idStatus IN (16,17)
        AND CAST(cxc.createdDate AS DATE) >=@beginDate
        AND CAST(cxc.createdDate AS DATE) <=@endDate

    SELECT 
        @cxcTotal=
            CASE 
                WHEN @currency='MXN' THEN @cxcMxn + (@cxcUsd*@tc)
                WHEN @currency='USD' THEN @cxcUsd + (@cxcMxn/@tc)
            END

    SELECT 
    @orderCxcMxn = SUM (
        CASE 
            WHEN orden.idCurrency=1 THEN orden.totalAmount
            ELSE 0
        END
    ),
    @orderCxcUsd = SUM (
        CASE 
            WHEN orden.idCurrency=2 THEN orden.totalAmount
            ELSE 0
        END
    )
    FROM Documents AS orden
    WHERE 
        orden.idTypeDocument=@idOrderType
        AND orden.idStatus =@idOrderStatus
        AND CAST(orden.createdDate AS DATE) >=@beginDate
        AND CAST(orden.createdDate AS DATE) <=@endDate

    SELECT 
        @orderCxcTotal=
            CASE 
                WHEN @currency='MXN' THEN @orderCxcMxn + (@orderCxcUsd*@tc)
                WHEN @currency='USD' THEN @orderCxcUsd + (@orderCxcMxn/@tc)
            END
        
    SELECT 
        @cxcTotalMxn= @orderCxcMxn+@cxcMxn,
        @cxcTotalUsd= @orderCxcUsd+@cxcUsd,
        @cxcTotalReport = @orderCxcTotal + @cxcTotal;

    SELECT 
        @cxcMxn AS [cxc.mxn],
        @cxcUsd AS [cxc.usd],
        @cxcTotal AS [cxc.report],
        @orderCxcMxn AS [orden.mxn],
        @orderCxcUsd AS [orden.usd],
        @orderCxcTotal AS [orden.report],
        @cxcTotalReport AS [total.report]
    FOR JSON PATH, ROOT('incomes')
    --!-----------------------------------------------------------------------


    --!-----------------------------------------------------------------------
    SELECT 
    @cxpMxn = SUM (
        CASE 
            WHEN cxc.idCurrency=1 THEN cxc.amountToPay
            ELSE 0
        END
    ),
    @cxpUsd = SUM (
        CASE 
            WHEN cxc.idCurrency=2 THEN cxc.amountToPay
            ELSE 0
        END
    )
    FROM Documents AS cxc
    WHERE 
        cxc.idTypeDocument=@idCxpType
        AND cxc.idStatus IN (20,21)
        AND CAST(cxc.createdDate AS DATE) >=@beginDate
        AND CAST(cxc.createdDate AS DATE) <=@endDate

    SELECT 
        @cxpTotal=
            CASE 
                WHEN @currency='MXN' THEN @cxpMxn + (@cxpUsd*@tc)
                WHEN @currency='USD' THEN @cxpUsd + (@cxpMxn/@tc)
            END

    SELECT 
    @odcCxpMxn = SUM (
        CASE 
            WHEN odc.idCurrency=1 THEN odc.totalAmount
            ELSE 0
        END
    ),
    @odcCxpUsd = SUM (
        CASE 
            WHEN odc.idCurrency=2 THEN odc.totalAmount
            ELSE 0
        END
    )
    FROM Documents AS odc
    WHERE 
        odc.idTypeDocument=@idOdcType
        AND odc.idStatus =@idOdcStatus
        AND CAST(odc.createdDate AS DATE) >=@beginDate
        AND CAST(odc.createdDate AS DATE) <=@endDate

    SELECT 
        @odcCxpTotal=
            CASE 
                WHEN @currency='MXN' THEN @odcCxpMxn + (@odcCxpUsd*@tc)
                WHEN @currency='USD' THEN @odcCxpUsd + (@odcCxpMxn/@tc)
            END
        
    SELECT 
        @cxpTotalMxn= @odcCxpMxn+@cxpMxn,
        @cxpTotalUsd= @odcCxpUsd+@cxpUsd,
        @cxpTotalReport = @odcCxpTotal + @cxpTotal;

    SELECT 
        @cxpMxn AS [cxp.mxn],
        @cxpUsd AS [cxp.usd],
        @cxpTotal AS [cxp.report],
        @odcCxpMxn AS [odc.mxn],
        @odcCxpUsd AS [odc.usd],
        @odcCxpTotal AS [odc.report],
        @cxpTotalReport AS [total.report]
    FOR JSON PATH,  ROOT('outcomes')
    --!-----------------------------------------------------------------------

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------