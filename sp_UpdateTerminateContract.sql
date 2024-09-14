-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-26-2021
-- Description: We validate the quote,pre-invoice and oc documents to terminate the contract
-- STORED PROCEDURE NAME:	sp_UpdateTerminateContract
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentID: The document id
-- @modifyBy: Th person who modify the document
-- ===================================================================================================================================
-- VARIABLE:
-- @quoteStatus=2: Means the quote is 'Ganada'
-- @preInvoiceStatus=10: Means the pre-invoice is 'Timbrada'
-- @OcWasSend=1: Means the OC was send
-- @documentStatus=15: It means the Contract change the status to 'Terminado'
-- @NoQuote: The quote number
-- @NoPreInvoice: The PreInvoice number
-- @NoOc: The Oc number
             
-- ===================================================================================================================================
-- Returns:
-- The status and message of this process
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-10-26		Adrian Alardin   			1.0.0.0			Initial Revision                       
--	2021-10-27		Adrian Alardin   			1.0.0.1			We add the varibles NoQuote, NoPreInvoice, NoOc. And the message change
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_UpdateTerminateContract(
        @documentID INT,
        @modifyBy NVARCHAR(30)

    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON 
DECLARE @quoteStatus TINYINT, @preInvoiceStatus TINYINT, @OcWasSend TINYINT
DECLARE @Mensaje NVARCHAR (256)
DECLARE @NoQuote NVARCHAR (10)
DECLARE @NoPreInvoice NVARCHAR (10)
DECLARE @NoOc NVARCHAR (10)
DECLARE @status TINYINT

DECLARE @documentStatus INT
SET @documentStatus=15

SELECT 
	@quoteStatus= Quote.idStatus,
	@preInvoiceStatus=PreInvoice.idStatus,
	@OcWasSend=OC.wasSend,
	@NoQuote=FORMAT(Quote.documentNumber,'0000000'),
	@NoPreInvoice=FORMAT(PreInvoice.documentNumber,'0000000'),
	@NoOc=FORMAT(OC.documentNumber,'0000000')
FROM Documents As Contract

LEFT JOIN Documents AS Quote ON Contract.idQuotation=Quote.idDocument
LEFT JOIN Documents AS PreInvoice ON Contract.idInvoice=PreInvoice.idDocument
LEFT JOIN Documents AS OC ON Contract.idOC=OC.idDocument
WHERE Contract.idDocument= @documentID

IF(@quoteStatus=2 AND @preInvoiceStatus=10 AND @OcWasSend=1)
	BEGIN
		SET @Mensaje='Se termino el contrato'
		SET @status=1
		EXECUTE sp_UpdateDocumentStatus @documentStatus,@documentID,@modifyBy
	END
ELSE IF(@quoteStatus!=2)
	BEGIN
		SET @Mensaje= CONCAT ('La Cotizacion No. ',@NoQuote,' tiene que estar ganada.')
		SET @status=0
	END
ELSE 
	BEGIN
		SET @Mensaje= CONCAT ('La Prefacutra No. ' ,@NoPreInvoice, 'tiene que ser timbrada y/o La OC No. ' ,@NoOc, 'tiene que ser enviada')
		SET @status=0
	END
SELECT @Mensaje AS message,@status AS status
END
GO