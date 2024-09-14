/****** Object:  StoredProcedure [dbo].[sp_AddPreInvoice]    Script Date: 04/11/2021 12:16:13 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 10-09-2021

-- Description: Insert a preinvoice and return the id of the document inserted

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
-- @idExecutive: ID of the executive who created the document
-- @authorizationFlag: ID that indicates if the preinvoice can be stamped

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  10-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

ALTER PROCEDURE [dbo].[sp_AddPreInvoice](
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
    @ivaAmount DECIMAL(14,4),
	@idExecutive INT,
	@authorizationFlag INT
)

AS BEGIN

    INSERT INTO Documents

    (

        idTypeDocument , idQuotation , idContact,
        idCustomer , idCurrency , protected,
        idCfdi , idPaymentForm , idPaymentMethod , 
        creditDays , totalAmount , subTotalAmount , 
        ivaAmount , createdDate , idStatus,
        createdBy , idExecutive , expirationDate,
		authorizationFlag

    )

    VALUES

    (

        2 , @idQuote , @idContact,
        @idCustomer , @idCurrency , @tcp,
        @idCfdi , 1 , 99,
        @creditDays , @totalImport , @subTotalAmount ,
        @ivaAmount , GETDATE() , 9,
        @createdBy , @idExecutive , GETDATE(),
		@authorizationFlag
    )

    SELECT SCOPE_IDENTITY()

END