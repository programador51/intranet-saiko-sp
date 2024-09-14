

-- BUSCAMOS LAS COTIZACIONES CREADAS HOY POR EL EJECUTIVO 20 
SELECT * FROM Documents WHERE idTypeDocument=1 AND idExecutive=20 AND idCustomer=63 -- Cotizacion
SELECT * FROM Documents WHERE idTypeDocument=6 AND idExecutive=20 AND idCustomer=63 AND idStatus=14 -- contrato
SELECT * FROM DocumentItems WHERE document IN (SELECT idDocument FROM Documents WHERE idTypeDocument=1 AND idExecutive=20 AND idCustomer=63) -- Partidas
SELECT * FROM DocumentsComments WHERE documentId IN (SELECT idDocument FROM Documents WHERE idTypeDocument=1 AND idExecutive=20 AND idCustomer=63)
SELECT * FROM Periocity WHERE idDocument IN (SELECT idDocument FROM Documents WHERE idTypeDocument=1 AND idExecutive=20 AND idCustomer=63)
SELECT * FROM Commentation WHERE documentId IN (SELECT idDocument FROM Documents WHERE idTypeDocument=1 AND idExecutive=20 AND idCustomer=63)


DELETE FROM Commentation WHERE documentId IN (SELECT idDocument FROM Documents WHERE idTypeDocument=1 AND idExecutive=20 AND idCustomer=63)
DELETE FROM Periocity WHERE idDocument IN (SELECT idDocument FROM Documents WHERE idTypeDocument=1 AND idExecutive=20 AND idCustomer=63)
DELETE FROM DocumentsComments WHERE documentId IN (SELECT idDocument FROM Documents WHERE idTypeDocument=1 AND idExecutive=20 AND idCustomer=63)
DELETE FROM DocumentItems WHERE document IN (SELECT idDocument FROM Documents WHERE idTypeDocument=1 AND idExecutive=20 AND idCustomer=63)
DELETE FROM Documents WHERE idTypeDocument=1 AND idExecutive=20 AND idCustomer=63
UPDATE Documents SET
idStatus= 13
WHERE idTypeDocument=6 AND idExecutive=20 AND idCustomer=63 AND idStatus=14 

-- SELECT DAY (dbo.fn_MexicoLocalTime(reminderDate)) FROM Documents WHERE idTypeDocument=6 AND idExecutive=20 AND idCustomer=63 AND idStatus=13 -- contrato