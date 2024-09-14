-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-08-2022
-- Description: Update the ODC when the invoice is received
-- STORED PROCEDURE NAME:	sp_UpdateODCAssociation
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: Document id
-- @totalAcredited: To acredited
-- @lastUpadatedDate: Last update Date
-- @amountToPay: The residue.
-- @lastUpadatedBy: The user how update the record
-- @uuid: The UUID
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @prevAcredited:Store the previus amount to pay
-- @status:The document status (7|30)
-- ===================================================================================================================================
-- Returns:
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/08/2022
-- Description: sp_UpdateODCAssociation -Update the ODC when the invoice is received
-- =============================================
CREATE PROCEDURE sp_UpdateODCAssociation
    (
    @documentId INT,
    @totalAcredited DECIMAL (14,4),
    @amountToPay DECIMAL (14,4),
    @lastUpadatedBy NVARCHAR(30),
    @uuid NVARCHAR(256)
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    -- UPDATE Documents
    
-- ----------------- ↓↓↓ VARIABLES DECLARATION ↓↓↓ -----------------------
    DECLARE @realAcreditedAmount DECIMAL (14,4);
    DECLARE @tolerace DECIMAL (14,4);
    -- DECLARE @prevAcredited DECIMAL (14,4);-- !Eliminar esto.
    -- DECLARE @status INT;
    -- DECLARE @realResidue DECIMAL (14,4);
    -- DECLARE @progress INT;
-- ----------------- ↑↑↑ VARIABLES DECLARATION↑↑↑ -----------------------


--! ----------------- ↓↓↓ GET THE PREV ACREDIT AMOUNT↓↓↓ -----------------------
    -- SELECT @prevAcredited=ISNULL(totalAcreditedAmount,0)
    -- FROM Documents
    -- WHERE idDocument=@documentId
--! ----------------- ↑↑↑ GET THE PREV ACREDIT AMOUNT ↑↑↑ -----------------------

--! ----------------- ↓↓↓ GET THE TOLERACE ↓↓↓ -----------------------
    -- SELECT @tolerace= CONVERT (DECIMAL(14,4),Parameters.value)
    -- FROM Parameters
    -- WHERE parameter=27
--! ----------------- ↑↑↑ GET THE TOLERACE ↑↑↑ -----------------------

--! ----------------- ↓↓↓ IF TO CHANGE THE STATUS ↓↓↓ -----------------------
    -- IF (@amountToPay<=tolerace AND @amountToPay>= (-1*tolerace))
    --     BEGIN
    --         SET @status=7;
    --         SET @progress=8;
    --         SET @realResidue=0
    --     END
    -- ELSE
    --     BEGIN
    --         SET @status=30;
    --         SET @progress=18;
    --         SET @realResidue=@amountToPay
    --     END
--! ----------------- ↑↑↑ IF TO CHANGE THE STATUS  ↑↑↑ -----------------------


-- ----------------- ↓↓↓ UPDATE STATEMENT ↓↓↓ -----------------------

    UPDATE Documents 
    SET
        @realAcreditedAmount=  ISNULL(subDoc.totalAcreditedAmount,0) +@totalAcredited,
        @tolerace= CONVERT (DECIMAL(14,4),Parameters.value),

        Documents.totalAcreditedAmount=@realAcreditedAmount,
        Documents.lastUpdatedDate=dbo.fn_MexicoLocalTime(GETDATE()),
        Documents.amountToPay= CASE WHEN (@amountToPay<=@tolerace AND @amountToPay>= (-1*@tolerace)) THEN 0 ELSE @amountToPay END,
        Documents.lastUpdatedBy=@lastUpadatedBy,
        Documents.uuid=@uuid,
        Documents.idStatus= CASE WHEN (@amountToPay<=@tolerace AND @amountToPay>= (-1*@tolerace)) THEN 7 ELSE 30 END,
        Documents.idProgress = CASE WHEN (@amountToPay<=@tolerace AND @amountToPay>= (-1*@tolerace)) THEN 8 ELSE 18 END
    FROM Documents
    LEFT JOIN Documents AS subDoc ON Documents.idDocument=@documentId
    LEFT JOIN Parameters AS Parameters ON Parameters.parameter=27

    WHERE Documents.idDocument=@documentId
-- ----------------- ↑↑↑ UPDATE STATEMENT ↑↑↑ -----------------------

END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------