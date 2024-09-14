-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-20-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetOcNrDetails
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
--	2023-10-20		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 10/20/2023
-- Description: sp_GetOcNrDetails - Some Notes
ALTER PROCEDURE sp_GetOcNrDetails(
    @idSummary INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    SELECT 
        detailOcnr.id,
        detailOcnr.idOdc,
        dbo.fn_formatFolio(odc.documentNumber) AS documentNumber,
        odc.createdDate,
        supplier.socialReason AS supplier,
        currency.code AS currency,
        odc.amountToPay AS residue,
        detailOcnr.status,
        concept.[description] AS concept
        


    FROM DetailOCNR AS detailOcnr
    LEFT JOIN Documents AS odc ON odc.idDocument=detailOcnr.idOdc
    LEFT JOIN Customers AS supplier ON supplier.customerID=odc.idCustomer
    LEFT JOIN Currencies AS currency ON currency.currencyID=odc.idCurrency
    LEFT JOIN InformativeExpenses AS concept ON concept.id = odc.idDocumentConcept
    WHERE
        idSummary=@idSummary

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------