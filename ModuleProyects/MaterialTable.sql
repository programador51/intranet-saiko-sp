DROP TABLE IF EXISTS Materials;
GO
CREATE TABLE Materials (
    id INT IDENTITY(1,1) PRIMARY KEY,
    cost DECIMAL(20,4) NOT NULL,
    createdBy NVARCHAR(256) NOT NULL,
    createdDate DATETIME NOT NULL DEFAULT GETUTCDATE(),
    currentQuantity INT NOT NULL DEFAULT 0, -- No sea mayor a la cantidad pedida
    idCatalogue INT NOT NULL,
    idPosition INT NOT NULL,
    idProyect INT NOT NULL,
    initialQuantity INT NOT NULL,
    residueQuantity AS initialQuantity - currentQuantity, -- Autocalculado
    sell DECIMAL(20,4) NOT NULL,
    totalCost AS CAST((initialQuantity* cost) AS DECIMAL(20,4)), -- Autocalculado
    totalSell AS CAST((initialQuantity* sell) AS DECIMAL(20,4)), -- Autocalculado
    updatedBy NVARCHAR(256),
    updatedDate DATETIME DEFAULT GETUTCDATE(),
    [status] BIT NOT NULL DEFAULT 1,
    CHECK (currentQuantity <= initialQuantity),
);

