-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-26-2022
-- Description: Add a complement 
-- STORED PROCEDURE NAME:	sp_AddComplement
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @applied: Amount applied
-- @createdBy: Crated by
-- @currencyCode: Currency code
-- @folio: folio
-- @idCfdi: Cfdi id
-- @idCustomer: Customer id
-- @idMovement: Movement id
-- @pdf: Pdf id
-- @rfcEmiter: Rfc emitter
-- @rfcReceptor: Rfc receptor
-- @socialResonReceptor: Social Reson Receptor
-- @uuid: UUID
-- @xml: XML id
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
--	2022-08-26		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/26/2022
-- Description: sp_AddComplement - Add a complement 
CREATE PROCEDURE sp_AddComplement(
    @applied DECIMAL(14,2),
    @createdBy NVARCHAR(30),
    @currencyCode NVARCHAR(3),
    @folio NVARCHAR(256),
    @idCfdi NVARCHAR(256),
    @idCustomer INT,
    @idMovement INT,
    @pdf INT,
    @rfcEmiter NVARCHAR(256),
    @rfcReceptor NVARCHAR(256),
    @socialResonReceptor NVARCHAR(256),
    @uuid NVARCHAR(256),
    @xml INT 
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(50)='addComplement';
    BEGIN TRY
    BEGIN TRANSACTION @tranName
    INSERT INTO Complements (
        applied,
        createdBy,
        lastUpdatedBy,
        currencyCode,
        folio,
        idCfdi,
        idCustomer,
        idMovement,
        pdf,
        rfcEmiter,
        rfcReceptor,
        socialReasonReceptor,
        uuid,
        [xml]
    )
    VALUES (
        @applied,
        @createdBy,
        @createdBy,
        @currencyCode,
        @folio,
        @idCfdi,
        @idCustomer,
        @idMovement,
        @pdf,
        @rfcEmiter,
        @rfcReceptor,
        @socialResonReceptor,
        @uuid,
        @xml
    )
    COMMIT TRANSACTION @tranName

    END TRY

    BEGIN CATCH

            DECLARE @Severity  INT= ERROR_SEVERITY()
            DECLARE @State   SMALLINT = ERROR_SEVERITY()
            DECLARE @Message   NVARCHAR(MAX)

            DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar para agregar el complemento 
            SP sp_AddComplement
                    @applied,
                    @createdBy,
                    @createdBy,
                    @currencyCode,
                    @folio,
                    @idCfdi,
                    @idCustomer,
                    @idMovement,
                    @pdf,
                    @rfcEmiter,
                    @rfcReceptor,
                    @socialResonReceptor,
                    @uuid,
                    @xml';
            DECLARE @wasAnError TINYINT=1;
            DECLARE @mustBeSyncManually TINYINT=1;
            DECLARE @provider TINYINT=4;

            SET @Message= ERROR_MESSAGE();
            IF (XACT_STATE()= -1)
                BEGIN
                    ROLLBACK TRANSACTION @tranName
                END
            IF (XACT_STATE()=1)
                BEGIN
                    COMMIT TRANSACTION @tranName
                END

            IF @@TRANCOUNT > 0  
                BEGIN
                    ROLLBACK TRANSACTION @tranName;   
                END
            RAISERROR(@Message, @Severity, @State);
            EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;
    END CATCH



END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------