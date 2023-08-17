-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-27-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_UpdateCancelNcr
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2023-06-27		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/27/2023
-- Description: sp_UpdateCancelNcr - Some Notes
CREATE PROCEDURE sp_UpdateCancelNcr(
    @idNcr INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
        DECLARE @tranName NVARCHAR(50)='cancelNCR';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;
    BEGIN TRY

        IF (@trancount= 0)
                BEGIN
                    BEGIN TRANSACTION @tranName;
                END
            ELSE
                BEGIN
                    SAVE TRANSACTION @tranName
                END
        DECLARE @idInvoice INT;
        DECLARE @nceTotal DECIMAL (14,2);
        DECLARE @uuidInvoce NVARCHAR(256);



        SELECT 
            @nceTotal = total,
            @uuidInvoce=uuidReference 
        FROM LegalDocuments WHERE id=@idNcr;
        
        SELECT @idInvoice = id FROM LegalDocuments WHERE uuid=@uuidInvoce;




        DECLARE @legalDocumentResidue DECIMAL(14,4);
        DECLARE @legalDocumentAplied DECIMAL(14,4);
        DECLARE @legalDocumentAcumulated DECIMAL(14,4);
        SELECT 
            @legalDocumentResidue = residue,
            @legalDocumentAplied= applied,
            @legalDocumentAcumulated = acumulated
        FROM LegalDocuments WHERE id=@idInvoice


        SELECT 
        @legalDocumentResidue=@legalDocumentResidue + @nceTotal,
        @legalDocumentAplied=@legalDocumentAplied - @nceTotal,
        @legalDocumentAcumulated=@legalDocumentAcumulated - @nceTotal;

        


        UPDATE LegalDocuments SET
                -- residue=@legalDocumentResidue,
                applied=@legalDocumentAplied,
                acumulated=@legalDocumentAcumulated,
                idLegalDocumentStatus = CASE
                                            WHEN LegalDocuments.residue = LegalDocuments.total THEN 1

                                            WHEN LegalDocuments.residue = 0 THEN 2
                                            ELSE 11
                                        END
            WHERE id=@idInvoice

        UPDATE LegalDocuments SET 
            idLegalDocumentStatus = 17
        WHERE id=@idNcr

        UPDATE cxp SET
            cxp.amountToBeCredited=cxp.amountToBeCredited+ nctocxp.applied,
            cxp.amountToPay=cxp.amountToPay+ nctocxp.applied,
            cxp.totalAcreditedAmount=cxp.totalAcreditedAmount - nctocxp.applied
        FROM Documents AS cxp
        LEFT JOIN CreditNoteToCxP AS nctocxp ON nctocxp.idCxp=cxp.idDocument
        WHERE cxp.idDocument= nctocxp.idCxp AND nctocxp.[status]=1

        UPDATE cxp SET
            idStatus= 
                CASE 
                    WHEN cxp.totalAcreditedAmount = 0 THEN 20
                    ELSE 21
                END
        FROM Documents AS cxp
        LEFT JOIN CreditNoteToCxP AS nctocxp ON nctocxp.idCxp=cxp.idDocument
        WHERE cxp.idDocument= nctocxp.idCxp AND nctocxp.[status]=1

        UPDATE CreditNoteToCxP SET
            [status]= 0
        WHERE idNce=@idNcr;
            
        IF (@trancount=0)
                    BEGIN
                        COMMIT TRANSACTION @tranName
                    END   
    
    END TRY
    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()
        DECLARE @Message   NVARCHAR(MAX)
        DECLARE @xstate INT= XACT_STATE();

        DECLARE @infoSended NVARCHAR(MAX)= 'Sin informacion por el momento';
        DECLARE @wasAnError TINYINT=1;
        DECLARE @mustBeSyncManually TINYINT=1;
        DECLARE @provider TINYINT=4;

        SET @Message= ERROR_MESSAGE();
        IF (@xstate= -1)
            BEGIN
                ROLLBACK TRANSACTION @tranName
            END
        IF (@xstate=1 AND @trancount=0)
            BEGIN
                -- COMMIT TRANSACTION @tranName
                ROLLBACK TRANSACTION @tranName
            END

        IF (@xstate=1 AND @trancount > 0)
            BEGIN
                ROLLBACK TRANSACTION @tranName;
            END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;

    END CATCH

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------