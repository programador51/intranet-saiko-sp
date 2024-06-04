
-- Ya no es necesario este cambio, se ha decidido que no se va a implementar
ALTER TABLE LegalDocuments
ADD isRelatedToOrder BIT DEFAULT 1;
