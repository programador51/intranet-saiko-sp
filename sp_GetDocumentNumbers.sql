-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 13-10-2021
-- ************************************************************************************************************************
-- Description: Get the document numbers related to an specific document
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: Id of the document to query the number documents related to it

-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
 -- ************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  13-10-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************

CREATE PROCEDURE sp_GetDocumentNumbers(
    @idDocument INT
)

AS BEGIN

    -- Number document of the requested document
    DECLARE @documentNumber INT;

    -- Id type document of the requested document
    DECLARE @idTypeDocument INT;

    -- Not need to search his number document
    DECLARE @invoiceMizar NVARCHAR(256);

    -- Number quote (Initially, will store the id of the document and eventually overwritten with the no. document)
    DECLARE @noQuote INT;
 
    -- Number contract (Initially, will store the id of the document and eventually overwritten with the no. document)
    DECLARE @noContract INT;

    --- Number preinvoice (Initially, will store the id of the document and eventually overwritten with the no. document)
    DECLARE @noPreinvoice INT;

    -- Number oc (Initially, will store the id of the document and eventually overwritten with the no. document)
    DECLARE @noOc INT;

    SELECT 
    @idDocument = documentNumber, 
    @idTypeDocument = idTypeDocument,
    @documentNumber = documentNumber,
    @noQuote = idQuotation,
    @noContract = idContract,
    @noPreinvoice = idInvoice,
    @noOc = idOC,
    @invoiceMizar = invoiceMizarNumber

    FROM Documents WHERE idDocument = @idDocument;

    -----------------------------------------------------------------------------------------

    -- Set quote number
    SELECT
        @noQuote AS documentNumber

    FROM Documents WHERE idDocument = @noQuote;

    -- Set contract number
    SELECT
        @noContract = documentNumber

    FROM Documents WHERE idDocument = @noContract;

    -- Set preinvoice number
    SELECT
        @noPreinvoice = documentNumber

    FROM Documents WHERE idDocument = @noPreinvoice;

    -- Set preinvoice number
    SELECT
        @noOc = documentNumber

    FROM Documents WHERE idDocument = @noOc;

    -----------------------------------------------------------------------------------------
    -- Return the number documents
    SELECT 
        
        CASE @idTypeDocument

            WHEN 1 THEN 
                @documentNumber

            ELSE @noQuote
        END AS noQuote,

        CASE @idTypeDocument

            WHEN 2 THEN 
                @documentNumber

            ELSE @noPreinvoice
        END AS noPreinvoice,

        CASE @idTypeDocument

            WHEN 6 THEN 
                @documentNumber

            ELSE @noContract
        END AS noContract,
        
        CASE @idTypeDocument

            WHEN 3 THEN 
                @documentNumber

            ELSE @noOc
        END AS noOc,

        @invoiceMizar AS invoice;

END