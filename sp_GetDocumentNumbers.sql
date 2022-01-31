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

    -- Number origin (Initially, will store the id of the document and eventually overwritten with the no. document)
	DECLARE @origin INT;

    SELECT 
    @idDocument = documentNumber, 
    @idTypeDocument = idTypeDocument,
    @documentNumber = documentNumber,
    @noQuote = idQuotation,
    @noContract = idContract,
    @noPreinvoice = idInvoice,
    @noOc = idOC,
    @invoiceMizar = invoiceMizarNumber,
    @origin = idContractParent

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

    -- Set origin number
    SELECT
        @origin = documentNumber

    FROM Documents WHERE idDocument = @origin;

    -----------------------------------------------------------------------------------------
    -- Return the number documents
    SELECT 
		
		-------------------------------------------------------------------

        CASE @idTypeDocument

            WHEN 1 THEN 
				FORMAT(@documentNumber,'0000000')
                

            ELSE FORMAT(@noQuote,'0000000')
        END AS noQuote,

		-------------------------------------------------------------------

        CASE @idTypeDocument

            WHEN 2 THEN 
                FORMAT(@documentNumber,'0000000')

            ELSE FORMAT(@noPreinvoice,'0000000')
        END AS noPreinvoice,

		-------------------------------------------------------------------

        CASE @idTypeDocument

            WHEN 6 THEN 
                FORMAT(@documentNumber,'0000000')

            ELSE FORMAT(@noContract,'0000000')
        END AS noContract,

		-------------------------------------------------------------------
        
        CASE @idTypeDocument

            WHEN 3 THEN 
				FORMAT(@documentNumber,'0000000')

            ELSE FORMAT(@noOc,'0000000')
        END AS noOc,

		-------------------------------------------------------------------

        CASE @idTypeDocument

            WHEN 9 THEN 
				FORMAT(@documentNumber,'0000000')
                

            ELSE FORMAT(@origin,'0000000')
        END AS noOrigin,

        @invoiceMizar AS invoice;

END