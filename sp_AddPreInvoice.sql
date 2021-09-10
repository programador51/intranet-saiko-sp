-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 10-09-2021

-- Description: Insert a purchase order (OC) and return the id of the document inserted

-- ===================================================================================================================================
-- PARAMETERS:
-- @idQuote: ID of the quote
-- @idCustomer: ID of the customer that it's on the quote
-- @createdBy: Fullname of the executive who won the quote
-- @idContact: ID of the contact that it's on the quote
-- @idCurrency: ID of the currency that it's on the quote
-- @tcp: "Tipo cambio protegido" that it's on the quote
-- @idCfdi: ID of the cfdi choosen
-- @idPayForm: Id of the pay form
-- @idPayMethod: If of the pay method
-- @creditDays: Credit days that the executive typed for the pre-invoice
-- @totalImport: Subtotal all IVA's + Subtotal of all costs
-- @subTotalAmount: Subtotal of all costs
-- @ivaAmount: Subtotal of all ivas

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  10-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddPreInvoice(
    @idQuote INT,
    @idCustomer INT,
    @createdBy NVARCHAR(30),
    @idContact INT,
    @idCurrency INT,
    @tcp DECIMAL(14,4),
    @idCfdi INT,
    @idPayForm INT,
    @idPayMethod INT,
    @creditDays INT,
    @totalImport DECIMAL(14,4),
    @subTotalAmount DECIMAL(14,4),
    @ivaAmount DECIMAL(14,4)
)

AS BEGIN

    INSERT INTO Documents

    (

        idTypeDocument , idQuotation , idContact,
        idCustomer , idCurrency , protected,
        idCfdi , idPaymentForm , idPaymentMethod , 
        creditDays , totalAmount , subTotalAmount , 
        ivaAmount , createdDate , idStatus,
        createdBy

    )

    VALUES

    (

        2 , @idQuote , @idContact,
        @idCustomer , @idCurrency , @tcp,
        @idCfdi , @idPayForm , @idPayMethod,
        @creditDays , @totalImport , @subTotalAmount ,
        @ivaAmount , GETDATE() , 9,
        @createdBy
    )

    SELECT SCOPE_IDENTITY()

END