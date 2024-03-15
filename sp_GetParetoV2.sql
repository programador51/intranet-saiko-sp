-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-09-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetParetoV2
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
--	2024-02-09		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetParetoV2')
    BEGIN 

        DROP PROCEDURE sp_GetParetoV2;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/09/2024
-- Description: sp_GetParetoV2 - Some Notes
CREATE PROCEDURE sp_GetParetoV2(
    @reportCurrency NVARCHAR(3),
    @reportType TINYINT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    -- Los documentos de tipo pedido
    DECLARE @idDocumentType INT = 2
    -- Los documentos con estatus facturado
    DECLARE @idDocumentStatus INT =5

    DECLARE @reportTotalSell DECIMAL(14,4);
    DECLARE @reportTotalCost DECIMAL(14,4);
    DECLARE @reportTotalMargin DECIMAL(14,4);
    DECLARE @reportTotalInvoiced DECIMAL(14,4);


    -- Total de todas las facturas en MXN
    DECLARE @mxnTotalSell DECIMAL(14,4);

    -- Total de todas las facturas en USD
    DECLARE @usdTotalSell DECIMAL (14,4);

    -- Total de todas de los costos en MXN
    DECLARE @mxnTotalCost DECIMAL(14,4);

    -- Total de todas de los costos en USD
    DECLARE @usdTotalCost DECIMAL (14,4);

    -- Total del margen en MXN
    DECLARE @mxnTotalMargin DECIMAL(14,4)

    -- Total del margen en USD
    DECLARE @usdTotalMargin DECIMAL(14,4)

    SELECT
        @mxnTotalSell = SUM(
            CASE 
                WHEN invoice.idCurrency = 1 THEN items.calculationPriceUnitary * items.quantity
                ELSE 0
            END
        ),
        @usdTotalSell = SUM(
            CASE 
                WHEN invoice.idCurrency = 2 THEN items.calculationPriceUnitary * items.quantity
                ELSE 0
            END
        ),
        @mxnTotalCost = SUM(
            CASE 
                WHEN invoice.idCurrency = 1 THEN items.calculationCostUnitary * items.quantity
                ELSE 0
            END
        ),
        @usdTotalCost = SUM(
            CASE 
                WHEN invoice.idCurrency = 2 THEN items.calculationCostUnitary * items.quantity
                ELSE 0
            END
        ),
        @reportTotalSell=SUM(
            CASE 
                WHEN invoice.idCurrency = 1 AND @reportCurrency='MXN' THEN items.calculationPriceUnitary * items.quantity
                WHEN invoice.idCurrency = 2 AND @reportCurrency='USD' THEN items.calculationPriceUnitary * items.quantity
                WHEN invoice.idCurrency = 1 AND @reportCurrency='USD' THEN (items.calculationPriceUnitary / invoice.protected) * items.quantity
                WHEN invoice.idCurrency = 2 AND @reportCurrency='MXN' THEN (items.calculationPriceUnitary * invoice.protected) * items.quantity
                ELSE 0
            END
        ),
        @reportTotalCost=SUM(
            CASE 
                WHEN invoice.idCurrency = 1 AND @reportCurrency='MXN' THEN items.calculationCostUnitary * items.quantity
                WHEN invoice.idCurrency = 2 AND @reportCurrency='USD' THEN items.calculationCostUnitary * items.quantity
                WHEN invoice.idCurrency = 1 AND @reportCurrency='USD' THEN (items.calculationCostUnitary / invoice.protected) * items.quantity
                WHEN invoice.idCurrency = 2 AND @reportCurrency='MXN' THEN (items.calculationCostUnitary * invoice.protected) * items.quantity
                ELSE 0
            END
        )
    FROM DocumentItems AS items
        LEFT JOIN Documents AS invoice ON invoice.idDocument=items.document
        LEFT JOIN Customers AS client ON client.customerID= invoice.idCustomer
    WHERE 
        invoice.idTypeDocument= @idDocumentType
        AND invoice.idStatus= @idDocumentStatus
        AND items.[status]=1
        AND client.[status]=1

    SELECT
        @mxnTotalMargin= @mxnTotalSell-@mxnTotalCost,
        @usdTotalMargin= @usdTotalSell-@usdTotalCost,
        @reportTotalMargin = @reportTotalSell - @reportTotalCost,
        @reportTotalInvoiced = @reportTotalSell

    -- OBTENER LA LISTA DE LOS CLIENTES
    DECLARE @idClients TABLE (
        id INT NOT NULL IDENTITY(1,1),
        idClient INT NOT NULL
    )
    INSERT INTO @idClients

    SELECT
        client.customerID
    FROM DocumentItems AS items
        LEFT JOIN Documents AS invoice ON invoice.idDocument= items.document
        LEFT JOIN Customers AS client ON client.customerID= invoice.idCustomer
        LEFT JOIN Users AS executive ON executive.userID= invoice.idExecutive
    WHERE 
        invoice.idTypeDocument= @idDocumentType
        AND invoice.idStatus= @idDocumentStatus
        AND items.[status]=1
        AND client.[status]=1
    GROUP BY 
        client.customerID


    DECLARE @clients TABLE (
        id INT NOT NULL IDENTITY(1,1),
        idClient INT NOT NULL,
        rfc NVARCHAR(128),
        socialReason NVARCHAR(256)
    )

    INSERT INTO @clients
        (
        idClient,
        rfc,
        socialReason
        )
    SELECT
        ids.idClient,
        customer.rfc,
        customer.socialReason
    FROM @idClients AS ids
        LEFT JOIN Customers AS customer ON customer.customerID = ids.idClient


    DECLARE @initialPareto TABLE (
        id INT NOT NULL IDENTITY(1,1),
        executive NVARCHAR(5) NOT NULL,
        idCustomer INT NOT NULL,
        rfc NVARCHAR(128) NOT NULL,
        socialReason NVARCHAR(256) NOT NULL,
        mxnSell DECIMAL(14,4) NOT NULL,
        usdSell DECIMAL(14,4) NOT NULL,
        mxnCost DECIMAL(14,4) NOT NULL,
        usdCost DECIMAL(14,4) NOT NULL,
        mxnMargin DECIMAL(14,4) NOT NULL,
        usdMargin DECIMAL(14,4) NOT NULL,
        reportMargin DECIMAL(14,4) NOT NULL,
        reportInvoiced DECIMAL(14,4) NOT NULL
        
    )

    INSERT INTO @initialPareto
        (
        executive,
        idCustomer,
        rfc,
        socialReason,
        mxnSell,
        mxnCost,
        usdSell,
        usdCost,
        mxnMargin,
        usdMargin,
        reportMargin,
        reportInvoiced

        )

    SELECT
        executive.initials,
        client.idClient,
        client.rfc,
        client.socialReason,
        SUM(
            CASE 
                WHEN invoice.idCurrency=1 THEN items.calculationPriceUnitary*items.quantity
                ELSE 0
            END
        ), -- mxnSell
        SUM(
            CASE 
                WHEN invoice.idCurrency=1 THEN items.calculationCostUnitary*items.quantity
                ELSE 0
            END
        ), -- mxnCost
        SUM(
            CASE 
                WHEN invoice.idCurrency=2 THEN items.calculationPriceUnitary*items.quantity
                ELSE 0
            END
        ),-- usdSell
        SUM(
            CASE 
                WHEN invoice.idCurrency=2 THEN items.calculationCostUnitary*items.quantity
                ELSE 0
            END
        ),-- usdCost
        ( SUM(
            CASE 
                WHEN invoice.idCurrency=1 THEN items.calculationPriceUnitary*items.quantity
                ELSE 0
            END
        )
        -
        SUM(
            CASE 
                WHEN invoice.idCurrency=1 THEN items.calculationCostUnitary*items.quantity
                ELSE 0
            END
        )),
        ( SUM(
            CASE 
                WHEN invoice.idCurrency=2 THEN items.calculationPriceUnitary*items.quantity
                ELSE 0
            END
        )
        -
        SUM(
            CASE 
                WHEN invoice.idCurrency=2 THEN items.calculationCostUnitary*items.quantity
                ELSE 0
            END
        )),
        (
            SUM(
            CASE 
                WHEN invoice.idCurrency = 1 AND @reportCurrency='MXN' THEN items.calculationPriceUnitary * items.quantity
                WHEN invoice.idCurrency = 2 AND @reportCurrency='USD' THEN items.calculationPriceUnitary * items.quantity
                WHEN invoice.idCurrency = 1 AND @reportCurrency='USD' THEN (items.calculationPriceUnitary / invoice.protected) * items.quantity
                WHEN invoice.idCurrency = 2 AND @reportCurrency='MXN' THEN (items.calculationPriceUnitary * invoice.protected) * items.quantity
                ELSE 0
            END
        )
        -
        SUM(
            CASE 
                WHEN invoice.idCurrency = 1 AND @reportCurrency='MXN' THEN items.calculationCostUnitary * items.quantity
                WHEN invoice.idCurrency = 2 AND @reportCurrency='USD' THEN items.calculationCostUnitary * items.quantity
                WHEN invoice.idCurrency = 1 AND @reportCurrency='USD' THEN (items.calculationCostUnitary / invoice.protected) * items.quantity
                WHEN invoice.idCurrency = 2 AND @reportCurrency='MXN' THEN (items.calculationCostUnitary * invoice.protected) * items.quantity
                ELSE 0
            END
        )
        ),
        SUM(
            CASE 
                WHEN invoice.idCurrency = 1 AND @reportCurrency='MXN' THEN items.calculationPriceUnitary * items.quantity
                WHEN invoice.idCurrency = 2 AND @reportCurrency='USD' THEN items.calculationPriceUnitary * items.quantity
                WHEN invoice.idCurrency = 1 AND @reportCurrency='USD' THEN (items.calculationPriceUnitary / invoice.protected) * items.quantity
                WHEN invoice.idCurrency = 2 AND @reportCurrency='MXN' THEN (items.calculationPriceUnitary * invoice.protected) * items.quantity
                ELSE 0
            END
        )

    FROM DocumentItems AS items
        LEFT JOIN Documents AS invoice ON invoice.idDocument= items.document
        LEFT JOIN @clients AS client ON client.idClient= invoice.idCustomer
        LEFT JOIN Customer_Executive AS executiveRelation ON executiveRelation.customerID= client.idClient
        LEFT JOIN Users AS executive ON executive.userID= executiveRelation.executiveID
    WHERE 
        invoice.idTypeDocument= @idDocumentType
        AND invoice.idStatus= @idDocumentStatus
        AND items.[status]=1
    GROUP BY
        executive.initials,
        client.idClient,
        client.rfc,
        client.socialReason

    -- SELECT
    --     @mxnTotalMargin AS mxnTotalMargin,
    --     @usdTotalMargin AS usdTotalMargin,
    --     @reportTotalInvoiced AS reportTotalInvoiced,
    --     @reportTotalMargin AS reportTotalMargin

    DECLARE @Pareto TABLE (
        id INT NOT NULL IDENTITY(1,1),
        executive NVARCHAR(5) NOT NULL,
        idCustomer INT NOT NULL,
        rfc NVARCHAR(128) NOT NULL,
        socialReason NVARCHAR(256) NOT NULL,
        mxnSell DECIMAL(14,4) NOT NULL,
        usdSell DECIMAL(14,4) NOT NULL,
        mxnCost DECIMAL(14,4) NOT NULL,
        usdCost DECIMAL(14,4) NOT NULL,
        mxnMargin DECIMAL(14,4) NOT NULL,
        usdMargin DECIMAL(14,4) NOT NULL,
        reportMargin DECIMAL(14,4) NOT NULL,
        reportInvoiced DECIMAL(14,4) NOT NULL,
        marginPercentage DECIMAL(14,4) NOT NULL,
        invoicedPercentage DECIMAL(14,4) NOT NULL
        
    )

    INSERT INTO @Pareto (
        executive,
        idCustomer,
        rfc,
        socialReason,
        mxnSell,
        usdSell,
        mxnCost,
        usdCost,
        mxnMargin,
        usdMargin,
        reportMargin,
        reportInvoiced,
        marginPercentage,
        invoicedPercentage
    )


    SELECT
        executive,
        idCustomer,
        rfc,
        socialReason,
        mxnSell,
        mxnCost,
        usdSell,
        usdCost,
        mxnMargin,
        usdMargin,
        reportMargin,
        reportInvoiced,
        (reportMargin * 100) /@reportTotalMargin,
        (reportInvoiced * 100) /@reportTotalInvoiced 
    FROM @initialPareto
    ORDER BY 
        CASE 
            WHEN @reportType =2 THEN (reportMargin * 100) /@reportTotalMargin  
            ELSE (reportInvoiced * 100) /@reportTotalInvoiced  
        END DESC

    SELECT 
        executive,
        idCustomer,
        rfc,
        socialReason,
        mxnSell,
        usdSell,
        mxnCost,
        usdCost,
        mxnMargin,
        usdMargin,
        reportMargin,
        reportInvoiced,
        marginPercentage,
        invoicedPercentage,
        CASE 
            WHEN @reportType = 2 THEN SUM(marginPercentage) OVER (ORDER BY Id)
            ELSE SUM(invoicedPercentage) OVER (ORDER BY Id)
        END AS pareto
    FROM @Pareto

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------