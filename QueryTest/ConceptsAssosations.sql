-- Asociar un gasto a un movimiento de egreso
--  1.- Crear tabla con conceptos asociados.
--      a.- createdDate.
--      b.- createdBy.
--      c.- lastUpdateDate.
--      d.- lastUpdateBy.
--      e.- status.
--      f.- conceptId -- Concepto al cual se asocia el movimiento.
--      g.- idMovment -- Id del movimiento asociado al concepto.
--      h.- import -- El importe asociado.

DECLARE @createdBy NVARCHAR (30);
DECLARE @conceptId INT;
DECLARE @movementId INT;
DECLARE @import DECIMAL (14,4);

INSERT INTO ConceptsAssosations (
    createdBy,
    lastUpdateBy,
    conceptId,
    idMovment,
    import
)
VALUES (
    @createdBy,
    @createdBy,
    @conceptId,
    @movementId,
    @import
)