SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 24-08-2022
-- Description: Get the associations made of an incoming for an invoice(s)
-- STORED PROCEDURE NAME:	sp_getCxcConcilationsMovement
-- ************************************************************************************************************************
-- PARAMETERS:
-- [idMovement:int] Id of the incoming
-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
-- ***********************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ========================================================================================================================
--  24-08-2022     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************

DECLARE @idMovement INT =230;

SELECT 
    concilationCxC.id AS [id],
    concilationCxC.amountPaid AS [applied.number],
    dbo.fn_FormatCurrency(concilationCxC.amountPaid) AS [applied.text],
    'La cantidad que se utilizo DEL INGRESO para poder pagar la CxC. Por ejemplo, se tomaron 10USD (del movimiento/ingreso) para pagar una cantidad de 150MXN de la CxC (por ende la factura)' AS [applied.info],
    concilationCxC.tcConcilation AS [applied.tc.number],
    dbo.fn_FormatCurrency(concilationCxC.tcConcilation)AS [applied.tc.text],
    legalDocument.total AS [invoice.total.number],
    dbo.fn_FormatCurrency(legalDocument.total) AS [invoice.total.text],
    FORMAT(CAST(legalDocument.noDocument AS INT) ,'000000') AS [invoice.folio],
    legalDocument.uuid AS [invoice.uuid],
    legalDocument.currencyCode AS [invoice.currency],
    legalDocument.residue AS [invoice.residue.number],
    dbo.fn_FormatCurrency(legalDocument.residue) AS [invoice.residue.text],
    'Se refiere al dinero que todavía falta por ser cobrado al cliente para saldar su deuda de la compra que realizó con el ejecutivo"' AS [invoice.residue.info],
    legalDocument.socialReason AS [invoice.socialReason],
    cxc.idDocument AS [cxc.id],
    cxc.totalAmount AS [cxc.total.number],
    dbo.fn_FormatCurrency(cxc.totalAmount) AS [cxc.total.text],
    cxc.totalAmount - ISNULL(cxc.totalAcreditedAmount,0) AS [cxc.residue.number],
    dbo.fn_FormatCurrency(cxc.totalAmount - ISNULL(cxc.totalAcreditedAmount,0) ) AS [cxc.residue.text],
    cxc.factionsNumber AS [cxc.partialitie.partialitie],
    cxc.currectFaction AS [cxc.partialitie.current],
    CONCAT (cxc.currectFaction,'/',cxc.factionsNumber) AS [cxc.partialitie.ui],
    concilationCxC.amountApplied AS [paid.number],
    dbo.fn_FormatCurrency(concilationCxC.amountApplied) AS [paid.text],
    'La cantidad que se pago a la CxC (por ende la factura)' AS [paid.info]



FROM ConcilationCxC AS concilationCxC
LEFT JOIN LegalDocuments AS legalDocument ON legalDocument.uuid=concilationCxC.uuid
LEFT JOIN Documents AS cxc ON cxc.idDocument= concilationCxC.idCxC

WHERE 
    concilationCxC.idMovement=@idMovement AND
    concilationCxC.[status]=1 AND
    legalDocument.idTypeLegalDocument=2 AND
    legalDocument.idLegalDocumentStatus!=8
FOR JSON PATH,ROOT('cxcAssociations'), INCLUDE_NULL_VALUES

-- SELECT * FROM ConcilationCxC


-- SELECT * FROM LegalDocumentStatus WHERE idTypeLegalDocumentType=2

    -- SELECT DISTINCT
    --         conciliationCxC.id AS id,
    --         conciliationCxC.amountPaid AS [applied.number],
    --        'La cantidad que se utilizo DEL INGRESO para poder pagar la CxC. Por ejemplo, se tomaron 10USD (del movimiento/ingreso) para pagar una cantidad de 150MXN de la CxC (por ende la factura)' AS [applied.info],
    --        dbo.fn_FormatCurrency(conciliationCxC.amountPaid) AS [applied.text],
    --        conciliationCxC.tcConcilation AS [applied.tc.number],
    --        dbo.fn_FormatCurrency(conciliationCxC.tcConcilation) AS [applied.tc.text],
    --        Invoice.totalAmount AS [invoice.total.number],
    --        dbo.fn_FormatCurrency(Invoice.totalAmount) AS [invoice.total.text],
    --        dbo.fn_formatFolio(legalDocuments.noDocument) AS [invoice.folio],
    --     --    FORMAT(Invoice.documentNumber,'0000000') AS [invoice.folio],
    --        Invoice.uuid AS [invoice.uuid],
    --        currency.code AS [invoice.currency],
    --        Invoice.totalAmount - ISNULL(Invoice.totalAcreditedAmount, 0) AS [invoice.residue.number],
    --        dbo.fn_FormatCurrency(Invoice.totalAmount - ISNULL(Invoice.totalAcreditedAmount, 0)) AS [invoice.residue.text],
    --        'Se refiere al dinero que todavía falta por ser cobrado al cliente para saldar su deuda de la compra que realizó con el ejecutivo' AS [invoice.residue.info],
    --        customer.socialReason AS [invoice.socialReason],
    --        conciliationCxC.idCxC AS [cxc.id],
    --        CxC.factionsNumber AS [cxc.partialitie.partialities],
    --        CxC.currectFaction AS [cxc.partialitie.current],
    --        CONCAT(CxC.currectFaction, '/', CxC.factionsNumber) AS [cxc.partialitie.ui],
    --        conciliationCxC.amountApplied AS [paid.number],
    --        dbo.fn_FormatCurrency(conciliationCxC.amountApplied) AS [paid.text],
    --        'La cantidad que se pago a la CxC (por ende la factura)' AS [paid.info]
    -- FROM ConcilationCxC AS conciliationCxC

    --     LEFT JOIN LegalDocuments AS legalDocuments ON legalDocuments.uuid= conciliationCxC.uuid

    --     LEFT JOIN Documents AS Invoice ON Invoice.uuid =conciliationCxC.uuid
    --     LEFT JOIN Currencies AS currency ON currency.currencyID= Invoice.idCurrency 
    --     LEFT JOIN Customers AS customer ON customer.customerID= Invoice.idCustomer 
    --     LEFT JOIN Documents AS CxC ON CxC.idDocument = conciliationCxC.idCxC
    -- WHERE conciliationCxC.idMovement = @idMovement
    --       AND Invoice.idTypeDocument = 5
    --       AND conciliationCxC.[status] = 1
    -- FOR JSON PATH, ROOT('cxcAssociations'), INCLUDE_NULL_VALUES;


-- SELECT * FROM ConcilationCxC WHERE id=335

-- SELECT  *FROM Documents WHERE uuid='67b5189e-d9a1-4b85-8df8-e37d47b78ca2'