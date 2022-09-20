-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-01-2022
-- Description: Add the relationship of the invoice and its taxes
-- STORED PROCEDURE NAME:	sp_AddInvoiceTaxas
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @uuidInvoice: The invoice uuid
-- @baseAmount: It is the base of the amount to calculate the IVA
-- @ivaPercentage: The IVA percentage
-- @ivaAmount: It is the calculation of the IVA percentage for the base amount
-- @percentageTotal: It is the percentage that represents the total according to the number of items that correspond to the same percentage of IVA
-- @createdBy: user who create the record
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
--	2022-09-01		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/01/2022
-- Description: sp_AddInvoiceTaxas - Add the relationship of the invoice and its taxes
CREATE PROCEDURE sp_AddInvoiceTaxas(
    @uuidInvoice NVARCHAR(256),
    @baseAmount DECIMAL(14,2),
    @ivaPercentage DECIMAL(5,2),
    @ivaAmount DECIMAL(14,2),
    @percentageTotal DECIMAL(5,2),
    @createdBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='addInvoiceTaxas';
    BEGIN TRY
        BEGIN TRANSACTION @tranName;
        INSERT INTO InvoiceTaxas (
            uuidInvoce,
            baseAmount,
            ivaPercentage,
            ivaAmount,
            percentageTotal,
            lastUpdatedBy,
            createdBy
        )
        VALUES (
            @uuidInvoice,
            @baseAmount,
            @ivaPercentage,
            @ivaAmount,
            @percentageTotal,
            @createdBy,
            @createdBy
        )
        COMMIT TRANSACTION @tranName;
    END TRY
    BEGIN CATCH
                DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()
        DECLARE @Message   NVARCHAR(MAX)

        DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_AddInvoiceTaxas,
        @uuidInvoice,
        @baseAmount,
        @ivaPercentage,
        @ivaAmount,
        @percentageTotal,
        @createdBy';
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