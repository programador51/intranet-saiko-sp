-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-04-2022
-- Description: Insert the legal document association
-- STORED PROCEDURE NAME:	sp_AddLegalDocumentAssociation
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @applied: Applied
-- @createdAndModifyBy:User who created the record
-- @idConcept: Concept id
-- @idDocument: Document id
-- @idLegalDocument: Legal docuement Id
-- @import: import
-- @tc: TC
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: The id of the inserted record
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-04		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/01/2022
-- Description: sp_AddLegalDocumentAssociation -Insert the legal document association
-- =============================================
CREATE PROCEDURE sp_AddLegalDocumentAssociation
    (
    @applied DECIMAL (14,4),
    @createdAndModifyBy NVARCHAR(30),
    @idConcept INT,
    @idDocument INT,
    @idLegalDocument INT,
    @import DECIMAL (14,4),
    @tc DECIMAL (14,4)
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    -- Insert rows into table 'LegalDocumentsAssociations'
    INSERT INTO LegalDocumentsAssociations
        ( -- columns to insert data into
        applied,
        createdBy,
        createdDate,
        idConcept,
        idDocument,
        idLegalDocuments,
        importe,
        lastUpadatedDate,
        lastUpdatedBy,
        tc
        )
    VALUES
        ( -- first row: values for the columns in the list above
            @applied,
            @createdAndModifyBy,
            dbo.fn_MexicoLocalTime( GETDATE()),
            @idConcept,
            @idDocument,
            @idLegalDocument,
            @import,
            dbo.fn_MexicoLocalTime( GETDATE()),
            @createdAndModifyBy,
            @tc
)

END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------