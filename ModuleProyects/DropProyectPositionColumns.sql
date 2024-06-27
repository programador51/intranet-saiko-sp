ALTER TABLE PositionsProyects
DROP CONSTRAINT DF__Positions__labor__05B9B084;
GO

ALTER TABLE PositionsProyects
DROP CONSTRAINT DF__Positions__labor__04C58C4B;
GO

ALTER TABLE PositionsProyects
DROP COLUMN laborCost;
GO
ALTER TABLE PositionsProyects
DROP COLUMN laborSell;
GO

ALTER TABLE PositionsProyects
DROP COLUMN material;
GO

ALTER TABLE PositionsProyects
DROP COLUMN quantity;
GO

ALTER TABLE PositionsProyects
DROP COLUMN subPos;
GO

ALTER TABLE PositionsProyects
DROP COLUMN umSat;


