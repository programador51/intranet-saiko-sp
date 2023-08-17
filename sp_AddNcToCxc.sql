-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-10-2023
-- Description: Agrega y aplica el importe a las cxc de la nota de credito
-- STORED PROCEDURE NAME:	sp_AddNcToCxc
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
--	2023-02-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/10/2023
-- Description: sp_AddNcToCxc - Some Notes
CREATE PROCEDURE sp_AddNcToCxc(
    @idInvoice INT,
    @idNce INT,
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
        residue=@legalDocumentResidue,
        applied=@legalDocumentAplied,
        acumulated=@legalDocumentAcumulated
    WHERE id=@idInvoice
    UPDATE LegalDocuments SET
        idLegalDocumentStatus=
            CASE
                WHEN   residue=0 THEN 10
                ELSE 9
            END
    WHERE id=@idInvoice

    INSERT INTO CreditNoteToCxC (
        idNce,
        idInvoice,
        idCxc,
        applied,
        cxcResidue,
        newCxcResidue,
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

    UPDATE cxc SET
    cxc.amountToBeCredited=cxc.amountToBeCredited- nctocxc.aplied,
    cxc.amountToPay=cxc.amountToPay- nctocxc.aplied,
    cxc.totalAcreditedAmount=cxc.totalAcreditedAmount + nctocxc.aplied
    FROM Documents AS cxc
    LEFT JOIN @nctocxc AS nctocxc ON nctocxc.idCxc=cxc.idDocument
    WHERE cxc.idDocument= nctocxc.idCxc



END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------