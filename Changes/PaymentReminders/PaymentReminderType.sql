-- Renombra el tipo de tabla antiguo
EXEC sys.sp_rename 'dbo.PaymentReminderType', 'zMyOldTableType';

-- Crea un nuevo tipo de tabla con el nombre original y las modificaciones que necesites
CREATE TYPE dbo.PaymentReminderType AS TABLE(
    idInvoice INT,
    idClient INT,
    emitedDate DATETIME,
    expirationDate DATETIME,
    indexDate DATE,
    idRule INT,
    contact NVARCHAR(128),
    phone NVARCHAR(50),
    email NVARCHAR(50),
    total DECIMAL(14,4),
    residue DECIMAL(14,4),
    currency NVARCHAR(3),
    executive NVARCHAR(10),
    idCxc INT,
    partiality NVARCHAR(50),
    folio NVARCHAR(256)
);

-- Actualiza cada dependencia
DECLARE @Name NVARCHAR(776);
DECLARE REF_CURSOR CURSOR FOR
SELECT referencing_schema_name + '.' + referencing_entity_name
FROM sys.dm_sql_referencing_entities('dbo.PaymentReminderType', 'TYPE');

OPEN REF_CURSOR;
FETCH NEXT FROM REF_CURSOR INTO @Name;

WHILE (@@FETCH_STATUS = 0)
BEGIN
    EXEC sys.sp_refreshsqlmodule @name = @Name;
    FETCH NEXT FROM REF_CURSOR INTO @Name;
END;

CLOSE REF_CURSOR;
DEALLOCATE REF_CURSOR;

-- Elimina el tipo de tabla antiguo renombrado
DROP TYPE dbo.zMyOldTableType;
