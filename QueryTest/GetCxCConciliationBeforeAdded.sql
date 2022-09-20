

-- OBTENER LAS CONCILIACIONES ANTES DEL CAMBIO.
--CON UNA TABLA TEMPORAL INTENTAR GUARDAR EN MEMEORIA LO QUE SE PODIRA HACER DE REVERSA
DECLARE @idMovement INT = 173;

SELECT 
    idCxC,
    tcConcilation,
    amountPaid,
    totalAmount,
    amountToPay,
    newAmount,
    amountAccumulated,
    createdBy,
    createdDate,
    updatedBy,
    updatedDate,
    [status],
    uuid,
    idMovement,
    amountApplied
 FROM ConcilationCxC WHERE idMovement=@idMovement AND [status]=1
