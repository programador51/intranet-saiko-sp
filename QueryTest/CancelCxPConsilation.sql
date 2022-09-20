



--!-------------------------------------------------------------
DECLARE @arrayConsilation NVARCHAR(MAX) ='47,48';
DECLARE @lastUpdateBy NVARCHAR(30) ='Adrian Alardin Iracheta';



IF OBJECT_ID(N'tempdb..#TempMovement') IS NOT NULL
        BEGIN
            DROP TABLE #TempMovement
        END
IF OBJECT_ID(N'tempdb..#TempCxP') IS NOT NULL
        BEGIN
            DROP TABLE #TempCxP
        END
IF OBJECT_ID(N'tempdb..#TempFacturasR') IS NOT NULL
        BEGIN
            DROP TABLE #TempFacturasR
        END

--+ ----------------- ↓↓↓ CREACION DE TABLAS TEMPORALES ↓↓↓ -----------------------

CREATE TABLE #TempMovement (
            id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
            idMovement INT NOT NULL,
            totalMovementAsociated DECIMAL (14,4) DEFAULT 0  ,-- Es la suma de cada asociacion de las CXP 
            totalMovement DECIMAL (14,4) , -- Total del movimiento
            currentMovementResidue DECIMAL (14,4) , -- Es el saldo actual del movimiento
            newMovementResidue DECIMAL(14,4) DEFAULT 0  , -- Es el nuevo saldo del movimiento despues de la cancelación
            currentTotalMovementAsociated DECIMAL(14,4) , --Monto total usando del movimiento
            currentStatus INT,  -- Estatus actual del movimiento
            newStatus INT  DEFAULT -1 -- Representa el nuevo status del movimiento.

        )

        CREATE TABLE #TempCxP (
            id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
            uuid NVARCHAR(256) NOT NULL,
            idCxP INT NOT NULL,
            totalMovementAmount DECIMAL (14,4) NOT NULL,
            totalAmountCxP DECIMAL (14,4) NOT NULL,
            totalAcreditedCxP DECIMAL (14,4) NOT NULL,
            amountToPay DECIMAL (14,4) NOT NULL,
            newTotalAcreditedCxP DECIMAL(14,4) DEFAULT 0,
            newAmountToPayCxP DECIMAL(14,4),
            currentStatus INT NOT NULL,
            newStatus INT DEFAULT -1,
        )

        CREATE TABLE #TempFacturasR(
            id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
            uuid NVARCHAR(256) NOT NULL,
            total DECIMAL(14,4),
            acumulated DECIMAL(14,4),
            residue DECIMAL (14,4),
            newAcumulated DECIMAL (14,4),
            newResidue DECIMAL(14,4),
            currentStatus INT,
            newStatus INT
        )
        --+ ----------------- ↑↑↑ CREACION DE TABLAS TEMPORALES  ↑↑↑ -----------------------


        --? ----------------- ↓↓↓ MANEJAR TABLA TEMPORAL DE MOVIMINETOS ↓↓↓ -----------------------

        INSERT INTO #TempMovement (
            idMovement,
            totalMovementAsociated,
            totalMovement,
            currentMovementResidue,
            newMovementResidue,
            currentTotalMovementAsociated,
            currentStatus
        )
        SELECT DISTINCT
            consilationCxP.idMovement,
            0, -- totalMovementAsociated
            movement.amount,
            movement.saldo,
            0,--newMovementResidue
            movement.acreditedAmountCalculated,
            movement.[status]
        FROM ConcilationCxP AS consilationCxP
        LEFT JOIN LegalDocuments AS legalDocument ON legalDocument.uuid= consilationCxP.uuid
        LEFT JOIN Movements AS movement ON movement.MovementID= consilationCxP.idMovement

        WHERE 
            consilationCxP.id IN (SELECT value FROM string_split(@arrayConsilation,',')) AND 
            consilationCxP.[status]=1;
            

        UPDATE #TempMovement SET 
            totalMovementAsociated= (
                SELECT 
                    ROUND(SUM(amountPaid),1) 
                FROM ConcilationCxP AS consilationCxP 
                WHERE consilationCxP.idMovement= tempMovement.idMovement AND
                consilationCxP.id IN (SELECT value FROM string_split(@arrayConsilation,',') )AND
                consilationCxP.[status]=1
            ),
            newMovementResidue= tempMovement.currentMovementResidue + (
                SELECT 
                    ROUND(SUM(amountPaid),1) 
                FROM ConcilationCxP AS consilationCxP 
                WHERE consilationCxP.idMovement= tempMovement.idMovement AND
                consilationCxP.id IN (SELECT value FROM string_split(@arrayConsilation,','))AND
                consilationCxP.[status]=1
            )
        FROM #TempMovement AS tempMovement;

        UPDATE #TempMovement SET
            totalMovementAsociated= 
                CASE 
                    WHEN (currentTotalMovementAsociated - totalMovementAsociated >= 0 AND 
                    currentTotalMovementAsociated - totalMovementAsociated <= 1) THEN currentTotalMovementAsociated
                    WHEN (currentTotalMovementAsociated - totalMovementAsociated <= 0 AND 
                    currentTotalMovementAsociated - totalMovementAsociated >= -1) THEN currentTotalMovementAsociated
                    ELSE totalMovementAsociated
                END,
            newMovementResidue= 
                CASE
                    WHEN (totalMovement- newMovementResidue >= 0 AND 
                    totalMovement- newMovementResidue <= 1 ) THEN totalMovement
                    WHEN (totalMovement- newMovementResidue <= 0 AND 
                    totalMovement- newMovementResidue >= -1 ) THEN totalMovement
                    ELSE newMovementResidue
                END

        UPDATE #TempMovement SET
            newStatus= 
                CASE 
                    WHEN totalMovement = newMovementResidue THEN 5
                    WHEN totalMovement > newMovementResidue THEN 2
                    ELSE 5
                END;

        SELECT * FROM #TempMovement;
        --? ----------------- ↑↑↑ MANEJAR TABLA TEMPORAL DE MOVIMINETOS  ↑↑↑ -----------------------


        --? ----------------- ↓↓↓ MANEJAR TABLA TEMPORAL DE CXP ↓↓↓ -----------------------
        INSERT INTO #TempCxP (
            uuid,
            idCxP,
            totalMovementAmount,
            totalAmountCxP,
            totalAcreditedCxP,
            amountToPay,
            newTotalAcreditedCxP,
            newAmountToPayCxP,
            currentStatus,
            newStatus
        )
        SELECT DISTINCT
            consilationCxP.uuid,
            consilationCxP.idCxP,--idCxP
            0, --totalMovementAmount
            cxp.totalAmount, --totalAmountCxP
            cxp.totalAcreditedAmount, --totalAcreditedCxP
            cxp.amountToPay, --amountToPay
            0,--newTotalAcreditedCxP
            0, --newAmountToPayCxP
            cxp.idStatus,
            -1
        FROM ConcilationCxP AS consilationCxP 
        LEFT JOIN Documents AS cxp ON cxp.idDocument= consilationCxP.idCxP
        WHERE id IN (SELECT value FROM string_split(@arrayConsilation,',')) AND 
            consilationCxP.[status]=1;

        UPDATE #TempCxP SET
            totalMovementAmount= (
                SELECT 
                    ROUND(SUM(amountApplied),1) 
                FROM ConcilationCxP AS consilationCxP 
                WHERE consilationCxP.idCxP= tempCxP.idCxP AND
                consilationCxP.id IN (SELECT value FROM string_split(@arrayConsilation,','))AND
                consilationCxP.[status]=1
            ),
            newTotalAcreditedCxP= totalAcreditedCxP - (
                SELECT 
                    ROUND(SUM(amountApplied),1) 
                FROM ConcilationCxP AS consilationCxP 
                WHERE consilationCxP.idCxP= tempCxP.idCxP AND
                consilationCxP.id IN (SELECT value FROM string_split(@arrayConsilation,','))AND
                consilationCxP.[status]=1
            ),
            newAmountToPayCxP= amountToPay + (
                SELECT 
                    ROUND(SUM(amountApplied),1) 
                FROM ConcilationCxP AS consilationCxP 
                WHERE consilationCxP.idCxP= tempCxP.idCxP AND
                consilationCxP.id IN (SELECT value FROM string_split(@arrayConsilation,','))AND
                consilationCxP.[status]=1
            )

        FROM #TempCxP AS tempCxP

        UPDATE #TempCxP SET 
            newTotalAcreditedCxP= CASE 
                WHEN (newTotalAcreditedCxP<=0 AND newTotalAcreditedCxP >= -1 )THEN 0
                WHEN (newTotalAcreditedCxP>=0 AND newTotalAcreditedCxP <= 1 )THEN 0
                ELSE newTotalAcreditedCxP
            END,
            newAmountToPayCxP= CASE 
                WHEN (newTotalAcreditedCxP<=0 AND newTotalAcreditedCxP >= -1 ) THEN totalAmountCxP
                WHEN (newTotalAcreditedCxP>=0 AND newTotalAcreditedCxP <= 1 ) THEN totalAmountCxP
                ELSE newAmountToPayCxP
            END

        UPDATE #TempCxP SET 
            newStatus= CASE WHEN newTotalAcreditedCxP = 0 THEN 20
            ELSE 21
            END

        SELECT * FROM #TempCxP;

        --? ----------------- ↑↑↑ MANEJAR TABLA TEMPORAL DE CXP  ↑↑↑ -----------------------



        --? ----------------- ↓↓↓ MANEJAR TABLA TEMPORAL FACTURAS RECIBIDAS ↓↓↓ -----------------------

        INSERT INTO #TempFacturasR (
            uuid,
            total,
            acumulated,
            residue,
            newAcumulated,
            newResidue,
            currentStatus,
            newStatus
        )
        SELECT DISTINCT
            consilationCxP.uuid,
            legalDocument.total,
            legalDocument.acumulated,
            legalDocument.residue,
            0,
            0,
            legalDocument.idLegalDocumentStatus,
            0
            FROM ConcilationCxP AS consilationCxP
            LEFT JOIN LegalDocuments AS legalDocument ON legalDocument.uuid= consilationCxP.uuid
            WHERE consilationCxP.id IN (SELECT value FROM string_split(@arrayConsilation,',')) AND 
            consilationCxP.[status]=1 AND legalDocument.idLegalDocumentStatus != 5

        UPDATE #TempFacturasR SET
            newAcumulated= acumulated - (
                SELECT 
                    ROUND(SUM(amountApplied),1) 
                FROM ConcilationCxP AS consilationCxP 
                WHERE consilationCxP.uuid= tempFacturasR.uuid AND
                consilationCxP.id IN (SELECT value FROM string_split(@arrayConsilation,','))AND
                consilationCxP.[status]=1
            ),
            newResidue= residue + (
                SELECT 
                    ROUND(SUM(amountApplied),1) 
                FROM ConcilationCxP AS consilationCxP 
                WHERE consilationCxP.uuid= tempFacturasR.uuid AND
                consilationCxP.id IN (SELECT value FROM string_split(@arrayConsilation,','))AND
                consilationCxP.[status]=1
            )
        FROM #TempFacturasR AS tempFacturasR

        UPDATE #TempFacturasR SET
            newAcumulated= 
                CASE 
                    WHEN (newAcumulated<=0 AND newAcumulated >=-1) THEN 0
                    WHEN (newAcumulated>=0 AND newAcumulated <= 1) THEN 0
                    ELSE newAcumulated
                END,
            newResidue=  
                CASE 
                    WHEN (newAcumulated<=0 AND newAcumulated >=-1)  THEN residue
                    WHEN (newAcumulated>=0 AND newAcumulated <= 1)  THEN residue
                    ELSE newResidue
                END

        UPDATE #TempFacturasR SET 
            newStatus=  CASE WHEN newAcumulated=0 THEN 1
                ELSE 11
            END

        SELECT * FROM #TempFacturasR
        --? ----------------- ↑↑↑ MANEJAR TABLA TEMPORAL FACTURAS RECIBIDAS  ↑↑↑ -----------------------

--* ----------------- ↓↓↓ UPDATES A LAS TABLAS REALES ↓↓↓ -----------------------
UPDATE Movements SET
    movements.[status]= tempMovement.newStatus,
    movements.customerAssociated = 
        CASE
            WHEN tempMovement.newMovementResidue = movements.amount THEN NULL
        END,
    movements.saldo= tempMovement.newMovementResidue,
    -- movements.acreditedAmountCalculated= 
    --     CASE 
    --         WHEN (movements.acreditedAmountCalculated - tempMovement.totalMovementAsociated >=0 AND 
    --         movements.acreditedAmountCalculated - tempMovement.totalMovementAsociated <= 1) THEN 0
    --         WHEN (movements.acreditedAmountCalculated - tempMovement.totalMovementAsociated <=0 AND 
    --         movements.acreditedAmountCalculated - tempMovement.totalMovementAsociated >= -1) THEN 0
    --         ELSE movements.acreditedAmountCalculated - tempMovement.totalMovementAsociated
    --     END,
    lastUpdatedDate= GETUTCDATE(),
    lastUpdatedBy= @lastUpdateBy
FROM Movements AS movements
LEFT JOIN #TempMovement AS tempMovement ON tempMovement.idMovement= movements.MovementID
WHERE tempMovement.idMovement= movements.MovementID AND movements.[status]!= 4

UPDATE Documents SET 
    idStatus=tempCxp.newStatus,
    totalAcreditedAmount= tempCxp.newTotalAcreditedCxP,
    amountToPay=tempCxp.newAmountToPayCxP,
    lastUpdatedDate= GETUTCDATE(),
    lastUpdatedBy=@lastUpdateBy
FROM Documents AS cxp
LEFT JOIN #TempCxP AS tempCxp ON tempCxp.idCxP=cxp.idDocument
WHERE tempCxp.idCxP=cxp.idDocument AND idTypeDocument= 4 AND idStatus!=23


UPDATE LegalDocuments SET
    acumulated= tempFacturasR.newAcumulated,
    residue= tempFacturasR.newResidue,
    idLegalDocumentStatus= tempFacturasR.newStatus,
    lastUpadatedDate= GETUTCDATE(),
    lastUpdatedBy= @lastUpdateBy
FROM LegalDocuments AS legalDocument
LEFT JOIN #TempFacturasR AS tempFacturasR ON tempFacturasR.uuid= legalDocument.uuid
WHERE tempFacturasR.uuid= legalDocument.uuid AND idLegalDocumentStatus != 5 AND 
idTypeLegalDocument=1;


UPDATE ConcilationCxP SET
    [status]= 0,
    updatedDate= GETUTCDATE(),
    updatedBy= @lastUpdateBy
WHERE id IN (SELECT value FROM string_split(@arrayConsilation,','))

--* ----------------- ↑↑↑ UPDATES A LAS TABLAS REALES  ↑↑↑ -----------------------




IF OBJECT_ID(N'tempdb..#TempMovement') IS NOT NULL
        BEGIN
            DROP TABLE #TempMovement
        END
IF OBJECT_ID(N'tempdb..#TempCxP') IS NOT NULL
        BEGIN
            DROP TABLE #TempCxP
        END
IF OBJECT_ID(N'tempdb..#TempFacturasR') IS NOT NULL
        BEGIN
            DROP TABLE #TempFacturasR
        END


--!-------------------------------------------------------------
SELECT 
    id,
    idCxP,
    idMovement,
    amountPaid,
    totalAmount,
    amountToPay,
    newAmount,
    amountAccumulated,
    amountApplied
 FROM ConcilationCxP WHERE id IN (SELECT value FROM string_split(@arrayConsilation,','))

SELECT 
    amount,
    saldo,
    acreditedAmountCalculated
 FROM Movements WHERE MovementID IN (120,119)

SELECT 
    SUM(amountPaid) AS totalConsiliadoMovimientos,
    SUM(amountApplied) AS totalAplicadoFactura 
FROM ConcilationCxP WHERE idCxP=2013

SELECT 
    subTotalAmount AS importe,
    ivaAmount AS iva,
    totalAmount AS total,
    totalAcreditedAmount AS acreditado,
    amountToBeCredited AS totalPorAcreditar,
    amountToPay AS montoApagar,
    idStatus
FROM Documents WHERE idDocument=2013

SELECT 
    import AS importe,
    iva AS iva,
    total AS total,
    acumulated AS acreditado,
    residue AS totalPorAcreditar
FROM LegalDocuments WHERE uuid= 'b9786ba4-15e8-49d7-b335-143de159f2c7'


SELECT * FROM LegalDocumentTypes
SELECT * FROM LegalDocumentStatus
SELECT * FROM LegalDocuments