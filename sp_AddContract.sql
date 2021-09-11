-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 10-09-2021

-- Description: Insert a contract related with a contract with this one it's won

-- ===================================================================================================================================
-- PARAMETERS:
-- @idQuote: ID of the quote related with the contract
-- @idContact: ID of the contact that it's on the quote
-- @idCurrency: ID of the currency that it's on the quote
-- @tcp: "Tipo cambio protegido" used on the quote
-- @totalImport: Total import OF THE QUOTE (IVA + All document items subtotal)
-- @subTotalAmount: Total subtotal OF THE QUOTE DOCUMENT ITEMS (all items)
-- @ivaAmount: Total IVA of OF THE QUOTE
-- @createdBy: Fullname who won the quote to create this document
-- @idCustomer: ID of the customer that it's on the quote

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  10-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddContract(
    @idQuote INT,
    @idContact INT,
    @idCurrency INT,
    @tcp DECIMAL(14,4),
    @totalImport DECIMAL(14,4),
    @subTotalAmount DECIMAL(14,4),
    @ivaAmount DECIMAL(14,4),
    @createdBy NVARCHAR(30),
    @idCustomer INT
)

AS BEGIN

    INSERT INTO Documents

    (
        idTypeDocument , idQuotation , idCustomer , 
        idContact , idCurrency , protected , 
        totalAmount , subTotalAmount , ivaAmount,
        idStatus, createdDate , createdBy
    )

    VALUES

    (
        6 , @idQuote , @idCustomer ,
        @idContact , @idCurrency , @tcp,
        @totalImport , @subTotalAmount , @ivaAmount,
        13 , GETDATE() , @createdBy

    )

    SELECT SCOPE_IDENTITY()

END