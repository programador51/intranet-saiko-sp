-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 01-02-2024
-- Description: 
    -- Gets the Pareto analysis per customer, based on the invoice or the margin, depending on what is chosen.
    -- In addition, the reference currency can be selected.
-- STORED PROCEDURE NAME:	sp_Getpareto
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @reportCurrency: Reference currency in which the report will be generated
-- @reportType: Type of report to be delivered Invoices or Margin
-- ===================================================================================================================================
-- =============================================
-- Returns: 
    -- socialReason: Client's social reason
    -- sell: Amount of the sale
    -- cost: Amount of the purshase
    -- margin: Margin of sale
    -- currency: Report Currency
    -- invoicePercentage: Percentage of invoices
    -- marginPercentage: Margin Percentage
    -- pareto: Pareto
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-01-02		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_Getpareto')
    BEGIN 

        DROP PROCEDURE sp_Getpareto;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 01/02/2024
-- Description: sp_Getpareto
CREATE PROCEDURE sp_Getpareto(
    @reportCurrency NVARCHAR(3),
    @reportType TINYINT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idInvoicedStatus INT = 5;
DECLARE @idDocumentType INT = 2;


DECLARE @temOdcItems TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idOdc INT NOT NULL,
    subtotal DECIMAL(14,4) NOT NULL,
    currency NVARCHAR(3) NOT NULL
)

INSERT INTO @temOdcItems(
    idOdc,
    subtotal,
    currency
)
    SELECT 
        items.document,
        SUM(
            CASE 
                WHEN @reportCurrency = items.currency THEN items.quantity * items.unit_cost
                WHEN @reportCurrency != items.currency AND @reportCurrency='MXN' THEN items.quantity * items.unit_cost*odc.protected
                WHEN @reportCurrency != items.currency AND @reportCurrency='USD' THEN items.quantity * items.unit_cost/odc.protected
            END
        ) AS importe,
        @reportCurrency

    FROM DocumentItems AS items
    LEFT JOIN Documents AS odc ON odc.idDocument= items.document
    WHERE 
        [status] =1 AND
        document IN (
            SELECT 
                idOc
            FROM Documents
            WHERE 
                idTypeDocument= @idDocumentType AND
                idStatus= @idInvoicedStatus AND
                idOC IS NOT NULL
        )
    GROUP BY 
        document

DECLARE @tempPareto TABLE (
    id INT NOT NULL IDENTITY(1,1),
    idOrder INT NOT NULL,
    idOdc INT NOT NULL,
    idCustomer INT NOT NULL,
    sellImport DECIMAL(14,4) NOT NULL,
    costImport DECIMAL(14,4) NOT NULL,
    margin AS CAST((sellImport - costImport) AS DECIMAL(14,4)),
    currency NVARCHAR(3) NOT NULL
)
INSERT INTO @tempPareto (
    idOrder,
    idOdc,
    idCustomer,
    sellImport,
    costImport,
    currency
)
SELECT
    orden.idDocument,
    orden.idOC,
    ISNULL(client.corporative,client.customerID),
    CASE 
        WHEN @reportCurrency = currency.code THEN orden.subTotalAmount
        WHEN @reportCurrency != currency.code AND @reportCurrency ='MXN' THEN orden.subTotalAmount*orden.protected
        WHEN @reportCurrency != currency.code AND @reportCurrency='USD' THEN orden.subTotalAmount/orden.protected
    END,
    odcItems.subtotal,
    @reportCurrency
FROM Documents AS orden
LEFT JOIN Customers AS client ON client.customerID= orden.idCustomer
LEFT JOIN @temOdcItems AS odcItems ON odcItems.idOdc = orden.idOC
LEFT JOIN Currencies AS currency ON currency.currencyID = orden.idCurrency
LEFT JOIN Documents AS odc ON odc.idDocument= orden.idOC
WHERE
    orden.idTypeDocument= @idDocumentType AND
    orden.idStatus= @idInvoicedStatus AND
    orden.idOC IS NOT NULL


DECLARE @totalIncoice DECIMAL(14,4)
DECLARE @totalMargin DECIMAL(14,4)

SELECT @totalIncoice =  SUM(sellImport) FROM @tempPareto
SELECT @totalMargin =  SUM(margin) FROM @tempPareto

DECLARE @pareto TABLE (
    id INT NOT NULL IDENTITY(1,1),
    socialReason NVARCHAR(128) NOT NULL,
    sell DECIMAL (14,4) NOT NULL,
    cost DECIMAL(14,4) NOT NULL,
    margin DECIMAL (14,4) NOT NULL,
    currency NVARCHAR(3) NOT NULL,
    invoicePercentage DECIMAL (8,4) NOT NULL,
    marginPercentage DECIMAL (8,4) NOT NULL

)

INSERT INTO @pareto (
    socialReason,
    sell,
    cost,
    margin,
    currency,
    invoicePercentage,
    marginPercentage
)
SELECT 
    client.socialReason,
    SUM(tempPareto.sellImport) AS sellImport,
    SUM(tempPareto.costImport) AS costImport,
    SUM(tempPareto.margin) AS margin,
    tempPareto.currency,
    SUM(tempPareto.sellImport)/@totalIncoice*100 AS invoicePercentage,
    SUM(tempPareto.margin)/@totalIncoice*100 AS marginPercentage
FROM @tempPareto AS tempPareto
LEFT JOIN Customers AS client ON client.customerID= tempPareto.idCustomer
GROUP BY 
    client.socialReason,
    tempPareto.currency
ORDER BY 
    CASE 
        WHEN @reportType =1 THEN SUM(tempPareto.sellImport)/@totalIncoice*100  
        ELSE SUM(tempPareto.margin)/@totalIncoice*100 
    END DESC
    
    SELECT 
        socialReason,
        sell,
        cost,
        margin,
        currency,
        invoicePercentage,
        marginPercentage,
        CASE 
            WHEN @reportType = 1 THEN SUM(invoicePercentage) OVER (ORDER BY Id)
            ELSE SUM(marginPercentage) OVER (ORDER BY Id)
        END AS pareto
FROM @pareto


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------