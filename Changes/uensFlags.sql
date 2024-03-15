
-- [requierdConfirmation]: identifica  si requiere numero de confirmación
ALTER TABLE UEN ADD requierdConfirmation BIT NOT NULL DEFAULT 0
GO

-- [requierdCFSign] identifica si requiere firmar el contrato del fabricante
ALTER TABLE UEN ADD requierdCFSign BIT NOT NULL DEFAULT 0
GO


-- [requierdContractSing] identifica si requiere firmar el contrato institucional
ALTER TABLE UEN ADD requierdContractSing BIT NOT NULL DEFAULT 0
GO


-- [requierdLicences] identifica si requiere firmar el contrato institucional
ALTER TABLE UEN ADD requierdLicences BIT NOT NULL DEFAULT 0
GO
