-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 10-09-2021

-- Description: Insert a purchase order (OC) and return the id of the document inserted

-- ===================================================================================================================================
-- PARAMETERS:
-- @idProvider: Id of the customer/provider selected
-- @idQuote: Id of the quote document
-- @createdBy: Fullname who won the quote
-- @idContact: Id of the contact that has the quote document
-- @idCurrency: Id of the currency that has the quote document
-- @tcp: "Tipo cambio protegido" that has the quote document
-- @creditDays: Credit days for the order purcharse
-- @totalImport: Subtotal all IVA's + Subtotal of all costs
-- @subTotalAmount: Subtotal of all costs
-- @ivaAmount : Subtotal of all ivas

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  10-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddOc(
    @idProvider INT,
    @idQuote INT,
    @createdBy NVARCHAR(30),
    @idContact INT,
    @idCurrency INT,
    @tcp DECIMAL(14,4),
    @creditDays INT,
    @totalImport DECIMAL(14,4),
    @subTotalAmount DECIMAL(14,4),
    @ivaAmount DECIMAL(14,4)
)

AS BEGIN

INSERT INTO Documents
    
(
    idTypeDocument , idCustomer, idQuotation,
    createdBy , idContact , idCurrency,
    protected , idProgress , creditDays,
    totalAmount , subTotalAmount , ivaAmount,
    idStatus, createdDate
)

VALUES

(
    3 , @idProvider , @idQuote , 
    @createdBy , @idContact , @idCurrency , 
    @tcp , 6 , @creditDays ,
    @totalImport , @subTotalAmount , @ivaAmount,
    5 , GETDATE()
)

SELECT SCOPE_IDENTITY()

END