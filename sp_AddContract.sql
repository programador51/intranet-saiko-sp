/****** Object:  StoredProcedure [dbo].[sp_AddContract]    Script Date: 22/09/2021 09:29:48 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
-- @idExecutive: ID of the executive who created the document
-- @contract: Contract that the user typed

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  10-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
--  22-09-2021     Jose Luis Perez             1.0.0.1         Nuevos atributos para agregar		
-- *****************************************************************************************************************************

ALTER PROCEDURE [dbo].[sp_AddContract](
    @idQuote INT,
    @idContact INT,
    @idCurrency INT,
    @tcp DECIMAL(14,4),
    @totalImport DECIMAL(14,4),
    @subTotalAmount DECIMAL(14,4),
    @ivaAmount DECIMAL(14,4),
    @createdBy NVARCHAR(30),
    @idCustomer INT,
	@idExecutive INT,
	@contract NVARCHAR(30),
    @expiration DATETIME,
	@reminder DATETIME
)

AS BEGIN

    INSERT INTO Documents

    (
        idTypeDocument , idQuotation , idCustomer , 
        idContact , idCurrency , protected , 
        totalAmount , subTotalAmount , ivaAmount,
        idStatus, createdDate , createdBy,
		idExecutive , expirationDate, contract,
        reminderDate
    )

    VALUES

    (
        6 , @idQuote , @idCustomer ,
        @idContact , @idCurrency , @tcp,
        @totalImport , @subTotalAmount , @ivaAmount,
        13 , GETDATE() , @createdBy,
		@idExecutive , @expiration , @contract ,
        @reminder

    )

    SELECT SCOPE_IDENTITY()

END