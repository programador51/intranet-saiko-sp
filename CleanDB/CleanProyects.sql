

DECLARE @TemItems TABLE
(
    idItem INT
)

INSERT INTO @TemItems (idItem)

SELECT items.idItem FROM DocumentItems AS items
LEFT JOIN Documents AS docs ON items.document = docs.idDocument
WHERE docs.idPosition IS NOT NULL 


DELETE FROM DocumentItems WHERE idItem IN (SELECT idItem FROM @TemItems)
DELETE FROM Documents WHERE idPosition IS NOT NULL
DELETE FROM Proyects
DELETE FROM PositionsProyects
DELETE FROM Materials
DELETE FROM ProposalPositionIndex
DELETE FROM ProyectProposals
