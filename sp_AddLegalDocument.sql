-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-04-2022
-- Description: Insert the legal document
-- STORED PROCEDURE NAME:	sp_AddLegalDocument
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @acumulated: The total acumulated.
-- @createdAndModifyBy: User who created the record.
-- @creditDays: The credit days.
-- @currencyCode: The currecy code "MXN"|"USD".
-- @emitedDate: The date the CFDI it was created.
-- @expirationDate: The expiration date.
-- @idLegalDocumentProvider: The provider id.
-- @idLegalDocumentReference: Is the id reference to the same table.
-- @idLegalDocumentStatus:The status id.
-- @idTypeLegalDocument: Is the type id.
-- @import: Import.
-- @iva: IVA.
-- @createdAndModifyBy:User who created the record.
-- @noDocument: Document number.
-- @pdf: PDF´s link to blobStorage.
-- @residue: residue.
-- @rfcEmiter: RFC emiter.
-- @rfcReceptor: RFC receptor.
-- @socialReason: social reson.
-- @total: total.
-- @uuid: uuid.
-- @uuidReference: Is the uuid reference to the same table.
-- @xml: XML´s link to blobStorage.
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
-- Description: sp_AddLegalDocument -Insert the legal document
-- =============================================
CREATE PROCEDURE sp_AddLegalDocument (
    @acumulated DECIMAL(14,4),
    @createdAndModifyBy NVARCHAR(30),
    @creditDays INT,
    @currencyCode NVARCHAR (3),
    @emitedDate DATETIME,
    @expirationDate DATETIME,
    @idLegalDocumentProvider INT,
    @idLegalDocumentReference INT,
    @idLegalDocumentStatus INT,
    @idTypeLegalDocument INT,
    @import DECIMAL (14,4),
    @iva DECIMAL (14,4),
    @noDocument NVARCHAR(256),
    @pdf NVARCHAR(MAX),
    @residue DECIMAL (14,4),
    @rfcEmiter NVARCHAR(256),
    @rfcReceptor NVARCHAR(256),
    @socialReason NVARCHAR(256),
    @total DECIMAL (14,4),
    @uuid NVARCHAR(256),
    @uuidReference NVARCHAR(256),
    @xml NVARCHAR(MAX)
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    INSERT INTO LegalDocuments
	(	acumulated,
		createdBy,-- Le pertenece a la variable @createdAndModifyBy
		createdDate,-- Es la fecha de creación GETDATE()
		creditDays,
		currencyCode,
		emitedDate,
		expirationDate,
		idLegalDocumentProvider,
		idLegalDocumentReference,
		idLegalDocumentStatus,
		idTypeLegalDocument,
		import,
		iva,
		lastUpdatedBy,-- Le pertenece a la variable @createdAndModifyBy
		lastUpadatedDate,-- Es la ultima fecha de actualización GETDATE()
		noDocument,
		pdf,
		residue,
		rfcEmiter,
		rfcReceptor,
		socialReason,
		total,
		uuid,
		uuidReference,
		xml
	)
	VALUES 
		(
			@acumulated,
            @createdAndModifyBy,
            GETDATE(),
            @creditDays,
            @currencyCode,
            @emitedDate,
			@expirationDate,
            @idLegalDocumentProvider,
            @idLegalDocumentReference,
            @idLegalDocumentStatus,
            @idTypeLegalDocument,
            @import,
            @iva,
            @createdAndModifyBy,
            GETDATE(),
            @noDocument,
            @pdf,
            @residue,
            @rfcEmiter,
            @rfcReceptor,
            @socialReason,
            @total,
            @uuid,
            @uuidReference,
            @xml
		)
    SELECT SCOPE_IDENTITY() AS ID
END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------