-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 01-15-2024
-- Description: Gets the active invoice
-- STORED PROCEDURE NAME:	sp_GetActiveFacturamaInvoice
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- The Legal document id and facturama id
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-01-15		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetActiveFacturamaInvoice')
    BEGIN 

        DROP PROCEDURE sp_GetActiveFacturamaInvoice;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 01/15/2024
-- Description: sp_GetActiveFacturamaInvoice - Gets the active invoice
CREATE PROCEDURE sp_GetActiveFacturamaInvoice AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idInvoiceStatus INT = 7 -- //CxC
    DECLARE @idlegalDocumentType INT = 2 -- //CxC


    SELECT DISTINCT 
        id, 
        idFacturamaLegalDocument,
        uuid
    FROM LegalDocuments 
    WHERE 
        idTypeLegalDocument= @idlegalDocumentType AND 
        idLegalDocumentStatus=@idInvoiceStatus

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------