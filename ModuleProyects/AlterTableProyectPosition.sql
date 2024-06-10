ALTER TABLE Proyects
ADD CONSTRAINT DF_createdDate
DEFAULT (GETUTCDATE()) FOR createdDate;
GO

ALTER TABLE Proyects
ADD CONSTRAINT DF_updatedDate
DEFAULT (GETUTCDATE()) FOR updatedDate;

ALTER TABLE Proyects
ADD idClient INT NOT NULL DEFAULT 0;

ALTER TABLE PositionsProyects
ADD CONSTRAINT DF_PositionsProyect_createdDate
DEFAULT (GETUTCDATE()) FOR createdDate;
GO

ALTER TABLE PositionsProyects
ADD CONSTRAINT DF_PositionsProyect_updatedDate
DEFAULT (GETUTCDATE()) FOR updatedDate;

SELECT * FROM Proyects;
SELECT * FROM PositionsProyects;
