-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-26-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_AddNcToCxp
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
--	2023-06-26		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/26/2023
-- Description: sp_AddNcToCxp - Some Notes
CREATE PROCEDURE sp_AddNcToCxp(
    @idInvoice INT,
    @idNcr INT,
    @importe DECIMAL(14,2),
    @createdBy NVARCHAR(30),
    @nctocxc NCEToCxC READONLY
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @legalDocumentResidue DECIMAL(14,4);
    DECLARE @legalDocumentAplied DECIMAL(14,4);
    DECLARE @legalDocumentAcumulated DECIMAL(14,4);
    DECLARE @tc DECIMAL(14,2);

    SELECT  TOP(1) @tc =  saiko FROM TCP ORDER BY id DESC
    
    SELECT 
        @legalDocumentResidue = residue,
        @legalDocumentAplied= applied,
        @legalDocumentAcumulated = acumulated
    FROM LegalDocuments WHERE id=@idInvoice

    SELECT 
        @legalDocumentResidue=@legalDocumentResidue -@importe,
        @legalDocumentAplied=@legalDocumentAplied +@importe,
        @legalDocumentAcumulated=@legalDocumentAcumulated +@importe;

    UPDATE LegalDocuments SET
        -- residue=@legalDocumentResidue,
        applied=@legalDocumentAplied,
        acumulated=@legalDocumentAcumulated
    WHERE id=@idInvoice
    UPDATE LegalDocuments SET
                idLegalDocumentStatus = CASE
                                            WHEN LegalDocuments.residue = LegalDocuments.total THEN 1
                                            WHEN LegalDocuments.residue = 0 THEN 2 
                                            ELSE 11
                                        END
    WHERE id=@idInvoice

    INSERT INTO CreditNoteToCxP (
        idNce,
        idInvoice,
        idCxp,
        applied,
        cxpResidue,
        newCxpResidue,
        tc,
        createdBy,
        createdDate,
        [status],
        updatedBy,
        updatedDate
    )
    SELECT 
        idNce,
        idInvoice,
        idCxc,
        aplied,
        cxcResidue,
        newCxcResidue,
        @tc,
        @createdBy,
        GETUTCDATE(),
        1,
        @createdBy,
        GETUTCDATE()
    FROM @nctocxc

    UPDATE cxp SET
    cxp.amountToBeCredited=cxp.amountToBeCredited- nctocxc.aplied,
    cxp.amountToPay=cxp.amountToPay- nctocxc.aplied,
    cxp.totalAcreditedAmount=cxp.totalAcreditedAmount + nctocxc.aplied
    FROM Documents AS cxp
    LEFT JOIN @nctocxc AS nctocxc ON nctocxc.idCxc=cxp.idDocument
    WHERE cxp.idDocument= nctocxc.idCxc

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------