DECLARE @idMovement INT=399;
DECLARE @deducibleArray NVARCHAR(MAX)='74,76';
DECLARE @noDeducibleArray NVARCHAR(MAX)='36,37';



IF OBJECT_ID(N'tempdb..#InvoiceReduns') IS NOT NULL
        BEGIN
            DROP TABLE #InvoiceReduns
        END

DECLARE @deducibleLength INT;
SELECT @deducibleLength=LEN(@deducibleArray);

DECLARE @noDeducibleLength INT;
SELECT @noDeducibleLength=LEN(@noDeducibleArray);

DECLARE @movementRefund DECIMAL(14,2)=0;

CREATE TABLE #InvoiceReduns (
    id INT NOT NULL IDENTITY(1,1),
    uuidInvoice NVARCHAR(256),
    refund DECIMAL(14,2),
    currentResidue DECIMAL(14,2),
    currentAcumulated DECIMAL(14,2),
    newResidue DECIMAL(14,2),
    newAcumulated DECIMAL(14,2)
)



IF(@deducibleArray IS NOT NULL AND @deducibleLength !=0)
    BEGIN
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
            newResidue=currentResidue+refund

        SELECT * FROM #InvoiceReduns

        


        --? SUMAMOS LO QUE SE DEVUELVE AL MOVIMIENTO.
        SELECT 
            @movementRefund= @movementRefund + SUM(associatedExpense.amountPaid)
        FROM ConcilationEgresses AS associatedExpense
        LEFT JOIN LegalDocuments AS invoice ON invoice.uuid=associatedExpense.uuid
        WHERE 
            associatedExpense.idMovement= @idMovement AND 
            associatedExpense.id IN (SELECT CONVERT(INT,[value]) FROM string_split(@deducibleArray,','))
    END


    -- amoutPaid es  lo que se uso del movimiento para pagar la factura
    -- ammountApplied es lo que se le aplico a la factura (depende de la moneda del documento y el movimiento)


IF(@noDeducibleArray IS NOT NULL AND @noDeducibleLength !=0)
    BEGIN
    -- SE EMPIEZA A DESASOCIAR
        SELECT 
            @movementRefund= @movementRefund+SUM(applied)
        FROM NonDeductibleAssociations -- (applied,idMovement,import)
        WHERE 
            idMovement=@idMovement AND
            id IN (SELECT CONVERT(INT,[value]) FROM string_split(@noDeducibleArray,','))
    END

--? ACTUALIZAMOS LOS DOCUMENTOS LEGALES CON EL NUEVO ACUMULADO Y SALDO
-- UPDATE invoice SET
--     invoice.acumulated= tempRefunds.newAcumulated,
--     invoice.applied=tempRefunds.newAcumulated,
--     invoice.residue= tempRefunds.newResidue
-- FROM LegalDocuments AS invoice
-- INNER JOIN #InvoiceReduns AS tempRefunds ON tempRefunds.uuidInvoice= invoice.uuid
-- WHERE invoice.uuid=tempRefunds.uuidInvoice;

--? ACTUALIZAMOS LOS DOCUMENTOS LEGALES CON EL NUEVO ESTATUS SEGUN EL SALDO
    -- UPDATE invoice SET
    --     invoice.idLegalDocumentStatus (CASE WHEN invoice.residue= invoces.total THEN 1 ELSE 11 END)
    -- FROM LegalDocuments AS invoice
    -- INNER JOIN #InvoiceReduns AS tempRefunds ON tempRefunds.uuidInvoice= invoice.uuid
    -- WHERE invoice.uuid=tempRefunds.uuidInvoice;


--? ACTUALIZAMOS EL MOVIMIENTO CON EL NUEVO SALDO Y APLICADO
-- UPDATE Movements SET
--     saldo= saldo + @movementRefund,
--     acreditedAmountCalculated= acreditedAmountCalculated - @movementRefund
-- WHERE MovementID= @idMovement
--? ACTUALIZAMOS EL MOVIMIENTO CON EL NUEVO ESTATUS
-- UPDATE Movements SET
--     [status]= (CASE WHEN amount=saldo THEN 1 ELSE 5 END)
-- WHERE MovementID= @idMovement

--? ACTUALIZAMOS EL ESTATUS DE LA CONCILIACION DE EGRESOS DEDUCIBLES
-- UPDATE ConcilationEgresses SET
--     [status]= 0
-- WHERE id IN (SELECT CONVERT(INT,[value]) FROM string_split(@deducibleArray,','))


--? ACTUALIZAMOS EL ESTATUS DE LA CONCILIACION DE EGRESOS NO DEDUCIBLES
-- UPDATE NonDeductibleAssociations SET
--     [status]=0
-- WHERE id IN (SELECT CONVERT(INT,[value]) FROM string_split(@noDeducibleArray,','))


IF OBJECT_ID(N'tempdb..#InvoiceReduns') IS NOT NULL
        BEGIN
            DROP TABLE #InvoiceReduns
        END


--!-------------------------------------------------------------------
-- SELECT 
--     deducible.id AS idDeducible,
--     deducible.amountAcumulated AS amountAcumulatedDeducible,
--     deducible.amountApplied AS amountAppliedDeducible,
--     deducible.amountToPay AS amountToPayDeducible,
--     deducible.idConcept AS idConceptDeducible,
--     deducible.idMovement AS idMovementDeducible,
--     deducible.newAmount AS newAmountDeducible,
--     deducible.uuid AS uuidDeducible,
--     invoces.total AS totalInvoice,
--     invoces.acumulated AS acumulatedInvoice,
--     invoces.applied AS appliedInvoice,
--     invoces.idConcept AS idConceptInvoice,
--     invoces.residue AS residueInvoice

-- FROM ConcilationEgresses AS deducible --(amountAcumulated,amountApplied,amountPaid,amountToPay, idConcept,idmovement,newAmount)
-- LEFT JOIN LegalDocuments AS invoces ON invoces.uuid=deducible.uuid
-- WHERE deducible.idMovement=@idMovement;


-- SELECT 
--     id,
--     applied,
--     idMovement,
--     import
-- FROM NonDeductibleAssociations -- (applied,idMovement,import)
-- WHERE idMovement=@idMovement;


-- SELECT 
--     amount,
--     saldo,
--     acreditedAmountCalculated,
--     bankAccount,
--     noMovement
-- FROM Movements WHERE MovementID=399 --(saldo y acreditedAmountCalculated, status)



-- TENGO QUE SUMAR TODO LO APLICADO A LO NO DEDUCIBLE Y DEDUCIBLE PARA REGRESARSELO AL EGRESO
-- SE TIENE QUE RESTAR EN LA FACTURA RECIBIDA EL MONTO QUE SE DEVUELVE DEL INGTRESO
-- 