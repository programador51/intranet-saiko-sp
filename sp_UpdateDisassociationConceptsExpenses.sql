-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-25-2022
-- Description: Disassociation concepts of expenses
-- STORED PROCEDURE NAME:	sp_UpdateDisassociationConceptsExpenses
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idMovement: Id Movement
-- @deducibleArray: deductible association id list
-- @noDeducibleArray: list of non-deductible association ids
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @deducibleLength
-- @noDeducibleLength 
-- @movementRefund
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
--	2022-10-25		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 10/25/2022
-- Description: sp_UpdateDisassociationConceptsExpenses - Disassociation concepts of expenses
CREATE PROCEDURE sp_UpdateDisassociationConceptsExpenses(
    @idMovement INT,
    @deducibleArray NVARCHAR(MAX),
    @noDeducibleArray NVARCHAR(MAX),
    @lastUpdatedBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    IF OBJECT_ID(N'tempdb..#InvoiceReduns') IS NOT NULL
        BEGIN
            DROP TABLE #InvoiceReduns
        END

    DECLARE @tranName NVARCHAR(50)='disassociation';
    DECLARE @deducibleLength INT;
    DECLARE @noDeducibleLength INT;
    DECLARE @movementRefund DECIMAL(14,2)=0;
    DECLARE @trancount int;
    SET @trancount = @@trancount;

    CREATE TABLE #InvoiceReduns (
        id INT NOT NULL IDENTITY(1,1),
        uuidInvoice NVARCHAR(256),
        refund DECIMAL(14,2),
        currentResidue DECIMAL(14,2),
        currentAcumulated DECIMAL(14,2),
        newResidue DECIMAL(14,2),
        newAcumulated DECIMAL(14,2)
    )

    BEGIN TRY

        IF (@trancount= 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
        ELSE
            BEGIN 
                SAVE TRANSACTION @tranName
            END

        --    PRINT('Validaciones');
        --    IF(@deducibleArray IS NOT NULL )
        --         BEGIN
        --             PRINT('NO ES NULA EL ARRAY')
        --         END
        --    IF(@deducibleArray IS NOT NULL )
        --         BEGIN
        --             PRINT('NO ES NULA EL ARRAY')
        --         END

        SELECT @deducibleLength= LEN(@deducibleArray);
        SELECT @noDeducibleLength= LEN(@noDeducibleArray)

    


        
        IF(@deducibleArray IS NOT NULL AND @deducibleLength !=0)
            BEGIN
            PRINT('Ajustando la tabla temporal...');
            -- SE EMPIEZA A DESASOCIAR
                INSERT INTO #InvoiceReduns(
                    uuidInvoice,
                    refund
                )
                --? GURDAMOS LA FACTURA Y EL TOTAL QUE SE LE HA ASOCIADO EN LA TABLA TEMPORAL
                SELECT 
                    associatedExpense.uuid,
                    SUM(associatedExpense.amountApplied)
                FROM ConcilationEgresses AS associatedExpense
                WHERE 
                    associatedExpense.idMovement= @idMovement AND 
                    associatedExpense.id IN (SELECT CONVERT(INT,[value]) FROM string_split(@deducibleArray,','))
                GROUP BY 
                    associatedExpense.uuid,
                    associatedExpense.amountApplied

                --? ACTUALIZAMOS LA TABLA TEMPORAL PARA OBTENER EL SALDO Y ACUMULADO ACTUAL DE LA FACTURA
                UPDATE tempRefunds SET
                    tempRefunds.currentResidue= invoice.residue,
                    tempRefunds.currentAcumulated=invoice.acumulated
                FROM #InvoiceReduns AS tempRefunds
                INNER JOIN LegalDocuments AS invoice ON invoice.uuid= tempRefunds.uuidInvoice
                WHERE tempRefunds.uuidInvoice=tempRefunds.uuidInvoice

                --? ACTUALIZAMOS LA TABLA TEMPORAL PARA CALCULAR EL NUEVO SALDO Y MONTO APLICADO
                UPDATE #InvoiceReduns SET
                    newAcumulated= currentAcumulated-refund,
                    newResidue=currentResidue+refund;

                
                --? SUMAMOS LO QUE SE DEVUELVE AL MOVIMIENTO.
                SELECT 
                    @movementRefund= @movementRefund + SUM(associatedExpense.amountPaid)
                FROM ConcilationEgresses AS associatedExpense
                LEFT JOIN LegalDocuments AS invoice ON invoice.uuid=associatedExpense.uuid
                WHERE 
                    associatedExpense.idMovement= @idMovement AND 
                    associatedExpense.id IN (SELECT CONVERT(INT,[value]) FROM string_split(@deducibleArray,','))

                    PRINT('Total del movimiento en Deducible')
                    PRINT(@movementRefund);
                    SELECT * FROM #InvoiceReduns;
            END


            -- amoutPaid es  lo que se uso del movimiento para pagar la factura
            -- ammountApplied es lo que se le aplico a la factura (depende de la moneda del documento y el movimiento)

         ------


--
        --? ACTUALIZAMOS LOS DOCUMENTOS LEGALES CON EL NUEVO ACUMULADO Y SALDO
        IF(@deducibleArray IS NOT NULL AND @deducibleLength !=0)
            BEGIN
                PRINT('Actualizando la factura y las asociaciones del egreso')

                UPDATE invoice SET
                    acumulated= tempRefunds.newAcumulated,
                    applied=tempRefunds.newAcumulated,
                    residue= tempRefunds.newResidue
                FROM LegalDocuments AS invoice
                INNER JOIN #InvoiceReduns AS tempRefunds ON tempRefunds.uuidInvoice= invoice.uuid
                WHERE uuid=tempRefunds.uuidInvoice;

                --? ACTUALIZAMOS LOS DOCUMENTOS LEGALES CON EL NUEVO ESTATUS SEGUN EL SALDO
                UPDATE invoice SET
                    idLegalDocumentStatus= (CASE WHEN residue= total THEN 1 ELSE 11 END),
                    lastUpdatedBy=@lastUpdatedBy,
                    lastUpadatedDate=GETUTCDATE()
                FROM LegalDocuments AS invoice
                INNER JOIN #InvoiceReduns AS tempRefunds ON tempRefunds.uuidInvoice= invoice.uuid
                WHERE uuid=tempRefunds.uuidInvoice;

                --? ACTUALIZAMOS EL ESTATUS DE LA CONCILIACION DE EGRESOS DEDUCIBLES
                UPDATE ConcilationEgresses SET
                    [status]= 0,
                    updatedBy= @lastUpdatedBy,
                    updatedDate= GETUTCDATE()
                WHERE id IN (SELECT CONVERT(INT,[value]) FROM string_split(@deducibleArray,','));
            END
        
        IF(@noDeducibleArray IS NOT NULL AND @noDeducibleLength !=0)
        PRINT('Actualizando las asociaciones a conceptos');
            BEGIN
            -- SE EMPIEZA A DESASOCIAR
                SELECT 
                    @movementRefund= @movementRefund+SUM(applied)
                FROM NonDeductibleAssociations -- (applied,idMovement,import)
                WHERE 
                    idMovement=@idMovement AND
                    id IN (SELECT CONVERT(INT,[value]) FROM string_split(@noDeducibleArray,','));

                --? ACTUALIZAMOS EL ESTATUS DE LA CONCILIACION DE EGRESOS NO DEDUCIBLES
                UPDATE NonDeductibleAssociations SET
                    [status]=0,
                    lastUpdatedBy=@lastUpdatedBy,
                    lastUpdatedDate=GETUTCDATE()
                WHERE id IN (SELECT CONVERT(INT,[value]) FROM string_split(@noDeducibleArray,','));

                PRINT('Total del movimiento en no deducibles')
                PRINT(@movementRefund);
            END


                PRINT('TOTAL del movimiento para refund');
                PRINT(@movementRefund);
        --? ACTUALIZAMOS EL MOVIMIENTO CON EL NUEVO SALDO Y APLICADO
        UPDATE Movements SET
            saldo= saldo + @movementRefund
            -- acreditedAmountCalculated= acreditedAmountCalculated - @movementRefund
        WHERE MovementID= @idMovement;

        --? ACTUALIZAMOS EL MOVIMIENTO CON EL NUEVO ESTATUS
        UPDATE Movements SET
            [status]= (CASE WHEN amount=saldo THEN 1 ELSE 2 END),
            lastUpdatedBy=@lastUpdatedBy,
            lastUpdatedDate=GETUTCDATE()
        WHERE MovementID= @idMovement;



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


        DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_UpdateDisassociationConceptsExpenses,
            @idMovement,
            @deducibleArray,
            @noDeducibleArray,
            @lastUpdatedBy
            ';
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

        IF (@xstate=1   AND @trancount > 0)
            BEGIN
                ROLLBACK TRANSACTION @tranName;   
            END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;

    END CATCH


IF OBJECT_ID(N'tempdb..#InvoiceReduns') IS NOT NULL
        BEGIN
            DROP TABLE #InvoiceReduns
        END

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------