-- [confirmed]: 
    -- Bandera especificamente utilizada pra la orden de compra.
    -- [0]:No confirmado.
    -- [1]:Confirmado.
    -- [2]:No requiere confirmación.
ALTER TABLE Documents ADD confirmed TINYINT NOT NULL DEFAULT 0 CHECK (confirmed >= 0 AND confirmed <=2);
GO

-- [confirmedDate]: la afecha en cuando fue confirmada
ALTER TABLE Documents ADD confirmedDate DATETIME DEFAULT GETUTCDATE();
GO

-- [confirmationNumber]: El numero de confirmacion de la orden de compra
    --[N/A]: significa que no aplica la el numero de confirmación
ALTER TABLE Documents ADD confirmationNumber NVARCHAR(128);
GO

-- [cfSing]: Indica si la firma del contrato del fabricante ya fue realizada
ALTER TABLE Documents ADD cfSing BIT DEFAULT 0;
GO
-- [cfSingedDate]: la afecha en cuando fue firmado el contrato del fabricante
ALTER TABLE Documents ADD cfSingedDate DATETIME DEFAULT GETUTCDATE();
GO

-- [myContractSing]: Indica si la firma de mi contrato ya fue realizada
ALTER TABLE Documents ADD myContractSing BIT DEFAULT 0;
GO
-- [myContractSingedDate]: la afecha en cuando fue firmado el contrato del fabricante
ALTER TABLE Documents ADD myContractSingedDate DATETIME DEFAULT GETUTCDATE();
GO

-- [licencesConfirmed]: Indica si la firma de mi contrato ya fue realizada
ALTER TABLE Documents ADD licencesConfirmed  BIT DEFAULT 0;
GO
-- [licencesConfirmedDate]: la afecha en cuando fue firmado el contrato del fabricante
ALTER TABLE Documents ADD licencesConfirmedDate DATETIME DEFAULT GETUTCDATE();
GO