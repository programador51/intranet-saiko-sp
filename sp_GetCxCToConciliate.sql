-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 12-10-2021
-- Description: We obtain the Header for every document
-- STORED PROCEDURE NAME:	sp_GetCxCToConciliate
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: The id of the signed user
-- ===================================================================================================================================
-- Returns:
-- The document date, number, the customer info, the document status, credit days, expiration date, currency, import, iva, total and the user how creates the document
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-12-10		Adrian Alardin   			1.0.0.0			Initial Revision
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_GetCxCToConciliate(@customerID BIGINT) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON -- Insert statements for procedure here
    -- Insert statements for procedure here
SET
    LANGUAGE Spanish;

SELECT
    DISTINCT CXC.idDocument AS id,
    -- Importe: Lo que se tiene que liquidar (total)
    CXC.totalAmount AS [importe.number],
    dbo.fn_FormatCurrency(CXC.totalAmount) AS [importe.text],
    -- dbo.fn_MexicoLocalTime(CXC.expirationDate)
    CASE
        WHEN CXC.expirationDate < GETDATE() THEN CONVERT(BIT, 1)
        ELSE CONVERT(BIT, 0)
    END AS isExpirated,
    CONCAT(CXC.currectFaction, '/', CXC.factionsNumber) AS partialitie,
    -- Saldo actual: Lo pendiente por pagar
    CXC.amountToPay AS [saldoActual.number],
    dbo.fn_FormatCurrency(CXC.amountToPay) AS [saldoActual.text],
    Invoice.idDocument AS [invoice.id],
    Invoice.totalAmount AS [invoice.total.number],
    dbo.fn_FormatCurrency(Invoice.totalAmount) AS [invoice.total.text],
    Invoice.idCurrency AS [currency.id],
    Currencies.code AS [currency.code] -- Invoice.documentNumber AS [invoice.docNumber]
FROM
    Documents AS CXC
    INNER JOIN Documents Invoice ON CXC.idInvoice = Invoice.idDocument
    INNER JOIN Currencies ON Invoice.idCurrency = Currencies.currencyID
WHERE
    CXC.idTypeDocument = 5
    and CXC.idCustomer = @customerID
    AND CXC.amountToPay != 0 
    FOR JSON PATH,ROOT('cxc');

END