
SET LANGUAGE Spanish

--? ----------------- ↓↓↓ SECCION DONDE SE BORRAN LAS TABLAS TEMPORALES ↓↓↓ -----------------------

    IF OBJECT_ID(N'tempdb..#TempCotizaciones') IS NOT NULL
        BEGIN
            DROP TABLE #TempCotizaciones
        END

    IF OBJECT_ID(N'tempdb..#TemDocumentItems') IS NOT NULL
        BEGIN
            DROP TABLE #TemDocumentItems
        END

    IF OBJECT_ID(N'tempdb..#TemDocumentsComments') IS NOT NULL
        BEGIN
            DROP TABLE #TemDocumentsComments
        END

    IF OBJECT_ID(N'tempdb..#TempPeriocity') IS NOT NULL
        BEGIN
            DROP TABLE #TempPeriocity
        END

    IF OBJECT_ID(N'tempdb..#TempNewQuotesIds') IS NOT NULL
        BEGIN
            DROP TABLE #TempNewQuotesIds
        END
    IF OBJECT_ID(N'tempdb..#TempReminders') IS NOT NULL
        BEGIN
            DROP TABLE #TempReminders
        END
    IF OBJECT_ID(N'tempdb..#TempWarningsReminders') IS NOT NULL
        BEGIN
            DROP TABLE #TempWarningsReminders
        END

--? ----------------- ↑↑↑ SECCION DONDE SE BORRAN LAS TABLAS TEMPORALES ↑↑↑ -----------------------

--* ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

--? ----------------- ↓↓↓ DECLARACION DE VARIBALES ↓↓↓ -----------------------

    DECLARE @expirationDateParam INT;

    SELECT @expirationDateParam = CAST([value] AS INT) FROM Parameters WHERE parameter=1

    DECLARE @todayDate DATETIME = dbo.fn_MexicoLocalTime(GETDATE());
    DECLARE @newExpirationDate DATETIME = DATEADD(DAY,@expirationDateParam,@todayDate);

--? ----------------- ↑↑↑ DECLARACION DE VARIBALES ↑↑↑ -----------------------

--* ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

--? ----------------- ↓↓↓ CREACION DE TODAS LAS TABLAS TEMPORALES ↓↓↓ --------------------------------------------------------
    -- + ----------------- ↓↓↓ TABLA TEMPORAL PARA GUARDAR LAS NUEVAS COTIZACIONES (CONTRATOS) ↓↓↓ -----------------------
        CREATE TABLE #TempCotizaciones (
            id INT PRIMARY KEY NOT NULL IDENTITY (1,1), --/+  ID del registro autoincrementable.
            currentDocumentId INT NOT NULL,--/+ Id del documento actual segun el filtro (id del contrato)
            newDocumentId INT,--/+ Id del nuevo documento (id de la nueva cotización)
            newDocumentNumber INT,--/+ Nuevo numero de documento (numero de cotizacion)
            idQuote INT,--/+ Id de la cotizacion relacionada al contrato
            idCustomer INT NOT NULL,--/+ Id del customer al cual pertenece el documento
            idExecutive INT NOT NULL,--/+ Id del ejectuivo encargado
            idContact INT,--/+ Id del contacto del documento
            idCurrency INT NOT NULL,--/+ Id de la moneda del documento
            tc DECIMAL(14,4),--/+ Tipo de cambio del contrato
            expirationDate DATETIME,--/+ Fecha de expiracion del contrato 
            reminderDate DATETIME,--/+ Fecha de recordatorio del contrato
            idProbability INT NOT NULL,--/+ Id de la probabilidad de la nueva cotización (>50 %)
            creditDays INT,--/+ Dias de credito
            createdBy NVARCHAR(30),--/+ Quien creo el registro
            lastUpdatedBy NVARCHAR(30),--/+ Ultimo que actualizo el registro
            totalAmount DECIMAL(14,4),--/+ Cantidad total de la venta
            subTotalAmount DECIMAL(14,4),--/+ Cantidad total sin IVA de la venta
            ivaAmount DECIMAL(14,4),--/+ Cantidad total del IVA
            documentNumber INT,--/+ Numero de documento actual del contrato
            authorizationFlag INT,--/+ Bandera de autorizacion para la nueva cotización.
            createdDate DATETIME,--/+ Fecha de creacion del registro
            idStatus INT,--/+ Id del estatus de la nueva cotización.
            previusQuoteStatus INT--/+ Id del estatus de la anterior cotización.
        );
    -- + ----------------- ↑↑↑ TABLA TEMPORAL PARA GUARDAR LAS NUEVAS COTIZACIONES (CONTRATOS) ↑↑↑ -----------------------

    -- + ----------------- ↓↓↓ TABLA TEMPORAL DE LAS PARTIDAS DE LA NUEVA COTIZACION (PARTIDAS DEL CONTRATO) ↓↓↓ -----------------------
    CREATE TABLE #TemDocumentItems (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        currentDocumentId INT NOT NULL,
        newDocumentId INT,
        unit_price DECIMAL(14,4) NOT NULL,
        unit_cost DECIMAL(14,4) NOT NULL,
        idCatalogue INT NOT NULL,
        quantity INT NOT NULL,
        discount DECIMAL(14,4),
        totalImport DECIMAL(14,4) NOT NULL,
        [order] INT NOT NULL,
        createdBy NVARCHAR(30),
        lastUpdateBy NVARCHAR(30),
        createdDate DATETIME,
        lastUpdateDate DATETIME,
        ivaPercentage DECIMAL(5,2) NOT NULL,
        [status] TINYINT NOT NULL,
        iva DECIMAL(14,2),
        subTotal DECIMAL(14,4) NOT NULL,
        unitSellingPrice DECIMAL(14,4),
        unitPriceBeforeExchange DECIMAL(14,4),
        unitCostBeforeExchange DECIMAL(14,4),
        ivaBeforeExchange DECIMAL(14,4),
        subTotalBeforeExchange DECIMAL(14,4),
        unitSellingPriceBeforeExchange DECIMAL(14,4),
        calculationCostDiscount DECIMAL(14,4),
        calculationCostImport DECIMAL(14,4),
        calculationCostIva DECIMAL(14,4),
        calculationCostSell DECIMAL(14,4),
        calculationCostSubtotal DECIMAL(14,4),
        calculationCostUnitary DECIMAL(14,4),
        calculationPriceDiscount DECIMAL(14,4),
        calculationPriceImport DECIMAL(14,4),
        calculationPriceIva DECIMAL(14,4),
        calculationPriceSell DECIMAL(14,4),
        calculationPriceSubtotal DECIMAL(14,4),
        calculationPriceUnitary DECIMAL(14,4),
        discountPercentage DECIMAL(14,4),
        utility DECIMAL(14,4)
    )
    -- + ----------------- ↑↑↑ TABLA TEMPORAL DE LAS PARTIDAS DE LA NUEVA COTIZACION (PARTIDAS DEL CONTRATO) ↑↑↑ -----------------------

    -- + ----------------- ↓↓↓ TABLA TEMPORAL PARA GUARDAR LOS COMENTARIOS DE LA NUEVA COTIZACIÓN (LOS DEL PERIODO, NOTAS Y CONSIDERACIONES) ↓↓↓ -----------------------
    CREATE TABLE #TemDocumentsComments(
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        currentDocumentId INT NOT NULL,
        newDocumentId INT,
        comment NVARCHAR(256) NOT NULL,
        commentType INT NOT NULL,
        createdBy NVARCHAR(30),
        createdDate DATETIME,
        lastUpdateBy NVARCHAR(30),
        lastUpdateDate DATETIME,
        [order] INT NOT NULL,
        [status] TINYINT NOT NULL DEFAULT 1

        )
    -- + ----------------- ↑↑↑ TABLA TEMPORAL PARA GUARDAR LOS COMENTARIOS DE LA NUEVA COTIZACIÓN (LOS DEL PERIODO, NOTAS Y CONSIDERACIONES) ↑↑↑ -----------------------
    
    
    -- + ----------------- ↓↓↓ TABLA TEMPORAL PARA GUARDAR EL PERIODO DEL DOCUEMTNO QUE LE CORRESPONDA. ↓↓↓ -----------------------
    CREATE TABLE #TempPeriocity (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        createdBy NVARCHAR(30),
        createdDate DATETIME,
        currentDocumentId INT NOT NULL,
        newDocumentId INT,
        idPeriocityType INT NOT NULL,
        lastUpdatedBy NVARCHAR(30),
        lastUpdatedDate DATETIME,
        [status] TINYINT NOT NULL DEFAULT 1,
        [value] INT NOT NULL,
        startDate DATETIME,
        endDate DATETIME
    )
    -- + ----------------- ↑↑↑ TABLA TEMPORAL PARA GUARDAR EL PERIODO DEL DOCUEMTNO QUE LE CORRESPONDA. ↑↑↑ -----------------------
   
    -- + ----------------- ↓↓↓ TABLA TEMPORAL PARA GUARDAR LOS RECORDATORIOS DE LOS USUARIOS (SE CREO UNA NUEVA COTIZACION). ↓↓↓ -----------------------
    CREATE TABLE #TempReminders(
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        registerById INT NOT NULL,
        mustAttendById INT NOT NULL,
        newDocumentId INT,
        reminderDate DATETIME,
        attentionDate DATETIME,
        createDate DATETIME,
        comment NVARCHAR (1000),
        [status] TINYINT NOT NULL DEFAULT 1,
        createdBy NVARCHAR (30),
        lastUpdateBy NVARCHAR(30),
        commentTypeDescription NVARCHAR(30)
        )
    -- + ----------------- ↑↑↑ TABLA TEMPORAL PARA GUARDAR LOS RECORDATORIOS DE LOS USUARIOS (SE CREO UNA NUEVA COTIZACION). ↑↑↑ -----------------------
    
    -- + ----------------- ↓↓↓ TABLA TEMPORAL PARA GUARDAR LOS ID'S Y EL NUMERO DE DOCUMENTO DE LAS NUEVAS COTIZACIONES ↓↓↓ -----------------------
   CREATE TABLE #TempNewQuotesIds (
    id INT PRIMARY KEY NOT NULL IDENTITY (1,1),
    newDocumentId INT NOT NULL,
    newDocumentNumber INT NOT NULL
    )
    -- + ----------------- ↑↑↑ TABLA TEMPORAL PARA GUARDAR LOS ID'S Y EL NUMERO DE DOCUMENTO DE LAS NUEVAS COTIZACIONES ↑↑↑ -----------------------
    

--? ----------------- ↑↑↑ CREACION DE TODAS LAS TABLAS TEMPORALES ↑↑↑ -------------------------------------------------------------------------------

--* ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----


--? ----------------- ↓↓↓ INSERCION DE TODAS LAS TABLAS TEMPORALES  ↓↓↓ -----------------------

    -- + ----------------- ↓↓↓ INSERCIÓN DE LAS COTIZACIONES TEMPORALES (CONTRATOS) ↓↓↓ -----------------------
        -- De la tabla de documentos busca los contratos cuya fecha de recordatorio se igual a la de hoy y esten vigentes
        INSERT INTO #TempCotizaciones (
            currentDocumentId,
            idQuote,
            idCustomer,
            idExecutive,
            idContact,
            idCurrency,
            tc,
            expirationDate,
            reminderDate,
            idProbability,
            creditDays,
            createdBy,
            lastUpdatedBy,
            totalAmount,
            subTotalAmount,
            ivaAmount,
            documentNumber,
            authorizationFlag,
            createdDate,
            idStatus,
            previusQuoteStatus
        )
            SELECT 
                contractDocument.idDocument,
                contractDocument.idQuotation,
                contractDocument.idCustomer,
                contractDocument.idExecutive,
                contractDocument.idContact,
                contractDocument.idCurrency,
                contractDocument.protected,
                CASE 
                    WHEN @newExpirationDate < contractDocument.expirationDate THEN @newExpirationDate
                    ELSE  contractDocument.expirationDate
                END, -- New expirationDate
                dbo.fn_MexicoLocalTime(GETDATE()),-- New reminderDate
                3,-- >50% significa que es una renovación.
                contractDocument.creditDays,
                contractDocument.createdBy,
                contractDocument.lastUpdatedBy,
                contractDocument.totalAmount,
                contractDocument.subTotalAmount,
                contractDocument.ivaAmount,
                contractDocument.documentNumber,
                quoteDocument.authorizationFlag,
                @todayDate, -- New created Date
                1, -- significa que explicitamente le decimos que la nueva cotizacion sera 'Abierta'
                quoteDocument.idStatus
            FROM Documents AS contractDocument 
            LEFT JOIN Documents AS quoteDocument ON quoteDocument.idDocument= contractDocument.idQuotation
            WHERE 
                contractDocument.idTypeDocument=6 AND  
                contractDocument.idStatus=13 AND 
                (MONTH(contractDocument.reminderDate) = MONTH(@todayDate) AND 
                YEAR(contractDocument.reminderDate) = YEAR(@todayDate) AND 
                DAY(contractDocument.reminderDate) = DAY(@todayDate))



    -- + ----------------- ↑↑↑ INSERCIÓN DE LAS COTIZACIONES TEMPORALES (CONTRATOS) ↑↑↑ -----------------------
    --- ↓ Apartir de aquí, todas las inserciones siguientes dependen de la de cotizaciones temporales  ↓

    -- + ----------------- ↓↓↓ INSERCION DE LAS PARTIDAS TEMPORALES ↓↓↓ -----------------------
        /* Inserta las partidas a la tabla temporal que cumplan con la condicion de que el id del documento actual 
        (tabla de cotizacion temporal) considan con los de la tabla de DocumentsItems
        */
        INSERT INTO #TemDocumentItems (
        currentDocumentId,
        unit_price,
        unit_cost,
        idCatalogue,
        quantity,
        discount,
        totalImport,
        [order],
        createdBy,
        lastUpdateBy,
        createdDate,
        lastUpdateDate,
        ivaPercentage,
        [status],
        iva,
        subTotal,
        unitSellingPrice,
        unitPriceBeforeExchange,
        unitCostBeforeExchange,
        ivaBeforeExchange,
        subTotalBeforeExchange,
        unitSellingPriceBeforeExchange,
        calculationCostDiscount,
        calculationCostImport,
        calculationCostIva,
        calculationCostSell,
        calculationCostSubtotal,
        calculationCostUnitary,
        calculationPriceDiscount,
        calculationPriceImport,
        calculationPriceIva,
        calculationPriceSell,
        calculationPriceSubtotal,
        calculationPriceUnitary,
        discountPercentage,
        utility
    )
        SELECT 
            docItems.document,
            docItems.unit_price,
            docItems.unit_cost,
            docItems.idCatalogue,
            docItems.quantity,
            docItems.discount,
            docItems.totalImport,
            docItems.[order],
            docItems.createdBy,
            docItems.lastUpdatedBy,
            @todayDate,
            @todayDate,
            docItems.ivaPercentage,
            docItems.[status],
            docItems.iva,
            docItems.subTotal,
            docItems.unitSellingPrice,
            docItems.unitPriceBeforeExchange,
            docItems.unitCostBeforeExchange,
            docItems.ivaBeforeExchange,
            docItems.subTotalBeforeExchange,
            docItems.unitSellingPriceBeforeExchange,
            docItems.calculationCostDiscount,
            docItems.calculationCostImport,
            docItems.calculationCostIva,
            docItems.calculationCostSell,
            docItems.calculationCostSubtotal,
            docItems.calculationCostUnitary,
            docItems.calculationPriceDiscount,
            docItems.calculationPriceImport,
            docItems.calculationPriceIva,
            docItems.calculationPriceSell,
            docItems.calculationPriceSubtotal,
            docItems.calculationPriceUnitary,
            docItems.discountPercentage,
            docItems.utility
        FROM DocumentItems AS docItems
        LEFT JOIN #TempCotizaciones AS tempCotizacion ON tempCotizacion.currentDocumentId = docItems.document
        WHERE docItems.document=tempCotizacion.currentDocumentId
    -- + ----------------- ↑↑↑ INSERCION DE LAS PARTIDAS TEMPORALES ↑↑↑ -----------------------

    -- + ----------------- ↓↓↓ INSERCIÓN DE LOS PERIODOS TEMPORALES DE CONTRATOS ESPECIALES ↓↓↓ -----------------------
    /*
        De la tabla de cotizaciones temporales, busca los contratos que son especiales (el id de la cotizacion debe ser nulo)
        cuyo id de documento coincida con el id del documento en el periodo
    */
    INSERT INTO #TempPeriocity (
        createdBy,
        createdDate,
        currentDocumentId,
        idPeriocityType,
        lastUpdatedBy,
        lastUpdatedDate,
        [status],
        [value],
        startDate,
        endDate
    )
        SELECT 
            periocity.createdBy,
            periocity.createdDate,
            periocity.idDocument,
            periocity.idPeriocityType,
            periocity.lastUpdatedBy,
            periocity.lastUpdatedDate,
            periocity.[status],
            CASE 
                WHEN periocity.idPeriocityType= 1 THEN periocity.[value] + 1
                ELSE periocity.[value]
            END,-- Periocity value
            CASE 
                WHEN periocity.idPeriocityType= 1 THEN DATEADD(MONTH,1,periocity.startDate)
                ELSE DATEADD(DAY,1,periocity.startDate)
            END,-- StartDay
            CASE 
                WHEN periocity.idPeriocityType= 1 THEN DATEADD(MONTH,1,periocity.endDate)
                ELSE DATEADD(DAY,(1+periocity.value),periocity.startDate)
            END-- EndDate
        FROM Periocity AS periocity
        LEFT JOIN #TempCotizaciones AS tempCotizacion ON tempCotizacion.currentDocumentId= periocity.idDocument
        WHERE tempCotizacion.idQuote IS NULL AND periocity.idDocument=tempCotizacion.currentDocumentId
    -- + ----------------- ↑↑↑ INSERCIÓN DE LOS PERIODOS TEMPORALES DE CONTRATOS ESPECIALES ↑↑↑ -----------------------

    -- + ----------------- ↓↓↓ INSERCION DE LOS PERIODOS TEMPORALES DE CONTRATOS NORMALES ↓↓↓ -----------------------
    /*
        De la tabla de cotizaciones temporales, busca los contratos que son normales (el id de la cotizacion no es nulo)
        cuyo id de cotizacion anterior, coincida con el id del documento en el periodo
    */
    INSERT INTO #TempPeriocity (
        createdBy,
        createdDate,
        currentDocumentId,
        idPeriocityType,
        lastUpdatedBy,
        lastUpdatedDate,
        [status],
        [value],
        startDate,
        endDate
    )
        SELECT 
            periocity.createdBy,
            periocity.createdDate,
            tempCotizacion.currentDocumentId,-- id del documento
            periocity.idPeriocityType,
            periocity.lastUpdatedBy,
            periocity.lastUpdatedDate,
            periocity.[status],
            CASE 
                WHEN periocity.idPeriocityType= 1 THEN periocity.[value] + 1
                ELSE periocity.[value]
            END,-- Periocity value
            CASE 
                WHEN periocity.idPeriocityType= 1 THEN DATEADD(MONTH,1,periocity.startDate)
                ELSE DATEADD(DAY,1,periocity.endDate)
            END,-- StartDay
            CASE 
                WHEN periocity.idPeriocityType= 1 THEN DATEADD(MONTH,1,periocity.endDate)
                ELSE DATEADD(DAY,(DATEDIFF(DAY,periocity.startDate,periocity.endDate)+1),periocity.endDate)
            END-- EndDate

        FROM Periocity AS periocity
        LEFT JOIN #TempCotizaciones AS tempCotizacion ON tempCotizacion.idQuote= periocity.idDocument
        WHERE  tempCotizacion.idQuote IS NOT NULL AND periocity.idDocument=tempCotizacion.idQuote

        SELECT * FROM #TempPeriocity
    -- + ----------------- ↑↑↑ INSERCION DE LOS PERIODOS TEMPORALES DE CONTRATOS NORMALES ↑↑↑ -----------------------

    -- + ----------------- ↓↓↓ INSERCION DE LOS COMENTARIOS TEMPORALES DE PERIODO (SOLO APLICA PARA LOS DOCUMENTOS CON PERIODO) ↓↓↓ -----------------------
    /*
        De la tabla de periodos temporales, se van a insertar los comentarios de periodo a los documentos correspondientes
    */
    INSERT INTO #TemDocumentsComments (
        currentDocumentId,
        comment,
        commentType,
        createdBy,
        createdDate,
        lastUpdateBy,
        lastUpdateDate,
        [order],
        [status]
    )
        SELECT
            periodo.currentDocumentId,
            CASE 
                WHEN periodo.idPeriocityType = 1 AND periodo.startDate IS NOT NULL
                THEN CONCAT('Correspondiente al periodo 1 de ',DATENAME(MONTH,periodo.startDate), ' de ',YEAR(periodo.startDate),' - ',DAY(EOMONTH(periodo.startDate)), ' de ',DATENAME(MONTH,periodo.startDate), ' de ',YEAR(periodo.startDate))
                ELSE CONCAT('Correspondiente al periodo ',DAY(periodo.startDate), ' de ', DATENAME(MONTH,periodo.startDate), ' de ',YEAR(periodo.startDate), ' - ',DAY(periodo.endDate), ' de ', DATENAME(MONTH,periodo.endDate) , ' de ',YEAR(periodo.endDate))
            END,
            1, -- Nota
            periodo.createdBy,
            @todayDate,
            periodo.createdBy,
            @todayDate,
            1,
            1
        FROM #TempPeriocity AS periodo


    -- + ----------------- ↑↑↑ INSERCION DE LOS COMENTARIOS TEMPORALES DE PERIODO (SOLO APLICA PARA LOS DOCUMENTOS CON PERIODO) ↑↑↑ -----------------------
    
    -- + ----------------- ↓↓↓ INSERCION DE LOS COMENTARIOS TEMPORALES SEGUN LA REGLA DE NEGOCIO EN LOS PARAMETROS ↓↓↓ -----------------------
    
    INSERT INTO #TemDocumentsComments (
        currentDocumentId,
        comment,
        commentType,
        createdBy,
        createdDate,
        lastUpdateBy,
        lastUpdateDate,
        [order],
        [status]
    )
        SELECT
            cotizacion.currentDocumentId,
            notesConditions.content,
            notesConditions.[type],
            notesConditions.createdBy,
            @todayDate,
            notesConditions.createdBy,
            @todayDate,
            notesConditions.[order],
            1
        FROM #TempCotizaciones AS cotizacion
        LEFT JOIN NoteAndConditionToDocType noteConditionsCC ON noteConditionsCC.idDocumentType=1
        LEFT JOIN NoteAndCondition notesConditions ON notesConditions.id= noteConditionsCC.idNoteAndCondition
        WHERE 
            notesConditions.[status]=1 AND 
            notesConditions.[type]!=0 AND 
          (notesConditions.currency IS NULL OR  
            notesConditions.currency = CASE
                                        WHEN  cotizacion.idCurrency=1 THEN 'MXN'
                                        ELSE 'USD'
                                    END)

    -- + ----------------- ↑↑↑ INSERCION DE LOS COMENTARIOS TEMPORALES SEGUN LA REGLA DE NEGOCIO EN LOS PARAMETROS ↑↑↑ -----------------------


--? ----------------- ↑↑↑ INSERCION DE TODAS LAS TABLAS TEMPORALES ↑↑↑ ------------------------

--* ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

--? ----------------- ↓↓↓ INSERCION DE LOS DOCUEMTNSO TEMPORALES A LA TABLA DE "DOCUMENTS" ↓↓↓ -----------------------
    /*
        Insertara todos los documentos temporales a la tabla de "Documents" y a la vez guardara el id y el numero de documentos
        en la tabla temporal de "#TempNewQuotesIds". Despues actualilzara la tabla temporal de cotizaciones "#TempCotizaciones"
        con el id y numero de documento que se inserto.
    */
    INSERT INTO Documents (
        idContractParent,
        idTypeDocument,
        idCustomer,
        idExecutive,
        idContact,
        idCurrency,
        protected,
        expirationDate,
        reminderDate,
        idProbability,
        creditDays,
        createdBy,
        lastUpdatedBy,
        totalAmount,
        subTotalAmount,
        ivaAmount,
        documentNumber,
        authorizationFlag,
        createdDate,
        idStatus
    )
    OUTPUT inserted.idDocument, inserted.documentNumber INTO #TempNewQuotesIds(newDocumentId,newDocumentNumber)
        SELECT 
            currentDocumentId,
            1,
            idCustomer,
            idExecutive,
            idContact,
            idCurrency,
            tc,
            expirationDate,
            reminderDate,
            idProbability,
            creditDays,
            createdBy,
            lastUpdatedBy,
            totalAmount,
            subTotalAmount,
            ivaAmount,
            dbo.fn_NextDocumentNumber(1),-- DocumentNumber
            authorizationFlag,
            createdDate,
            idStatus
        FROM #TempCotizaciones
        
        -- + ----------------- ↓↓↓ ACTUALIZAR TABLA TEMPORAL DE COTIZACIONES (id y numero de documento) ↓↓↓ -----------------------
       
        UPDATE temporalDocument SET 
            temporalDocument.newDocumentId= newDocumentsIds.newDocumentId,
            temporalDocument.newDocumentNumber= newDocumentsIds.newDocumentNumber
            FROM #TempCotizaciones AS temporalDocument
            INNER JOIN #TempNewQuotesIds AS newDocumentsIds
            ON temporalDocument.id=newDocumentsIds.id

        -- + ----------------- ↑↑↑ ACTUALIZAR TABLA TEMPORAL DE COTIZACIONES (id y numero de documento) ↑↑↑ -----------------------
        

--? ----------------- ↑↑↑ INSERCION DE LOS DOCUEMTNSO TEMPORALES A LA TABLA DE "DOCUMENTS" ↑↑↑ -----------------------
    

--* ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----


--? ----------------- ↓↓↓ ACTUALIZACION DE LAS TABLAS TEMPORALES CON EL NUEVO ID Y NUMERO DE DOCUMENTO ↓↓↓ -----------------------
    -- + ----------------- ↓↓↓ ACTUALIZACION DE LAS PARTIDAS ↓↓↓ -----------------------
    UPDATE temporalItems SET 
        temporalItems.newDocumentId = newQuoteId.newDocumentId
        FROM #TemDocumentItems AS temporalItems
        INNER JOIN #TempCotizaciones AS newQuoteId
        ON temporalItems.currentDocumentId= newQuoteId.currentDocumentId
    -- + ----------------- ↓↓↓ ACTUALIZACION DE LAS PARTIDAS ↓↓↓ -----------------------


    -- + ----------------- ↑↑↑ ACTUALIZACION DE LOS COMENTARIOS ↑↑↑ -----------------------
    UPDATE temporalComments SET 
        temporalComments.newDocumentId = newQuoteId.newDocumentId
        FROM #TemDocumentsComments AS temporalComments
        INNER JOIN #TempCotizaciones AS newQuoteId
        ON temporalComments.currentDocumentId= newQuoteId.currentDocumentId


    -- + ----------------- ↑↑↑ ACTUALIZACION DE LOS COMENTARIOS ↑↑↑ -----------------------
    
    -- + ----------------- ↑↑↑ ACTUALIZACION DEL PERIODO ↑↑↑ -----------------------
    UPDATE temporalPeriocity SET 
        temporalPeriocity.newDocumentId = newQuoteId.newDocumentId
        FROM #TempPeriocity AS temporalPeriocity
        INNER JOIN #TempCotizaciones AS newQuoteId
        ON temporalPeriocity.currentDocumentId= newQuoteId.currentDocumentId
        -- ON temporalPeriocity.currentDocumentId= newQuoteId.idQuote
    -- + ----------------- ↑↑↑ ACTUALIZACION DEL PERIODO ↑↑↑ -----------------------
--? ----------------- ↑↑↑ ACTUALIZACION DE LAS TABLAS TEMPORALES CON EL NUEVO ID Y NUMERO DE DOCUMENTO ↑↑↑ -----------------------

--* ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

--? ----------------- ↓↓↓ INSERCION DE LOS RECORDATORIOS EN LA TABLA TEMPORAL ↓↓↓ -----------------------
    /*
        Con la tabla de cotizaciones temporales actualizada con el id de la nueva cotización, insertamos en la tabla temporal
        de los recordatorios el mensaje segun la validación. Si la cotización anterior aún no esta facturada, se maraca con rojo
    */
    INSERT INTO #TempReminders (
        registerById,
        mustAttendById,
        newDocumentId,
        reminderDate,
        attentionDate,
        createDate,
        comment,
        [status],
        createdBy,
        lastUpdateBy,
        commentTypeDescription
    )
        SELECT 
            tempCotizacion.idExecutive,-- registerById
            tempCotizacion.idExecutive,-- mustAttendById
            tempCotizacion.newDocumentId,-- newDocumentId
            @todayDate,-- reminderDate
            @todayDate,-- attentionDate
            @todayDate,-- createDate
            CASE 
                WHEN tempCotizacion.previusQuoteStatus = 3 THEN CONCAT('Nueva cotización creada: ',tempCotizacion.newDocumentNumber,' para ', customer.shortName)
                WHEN tempCotizacion.previusQuoteStatus IS NULL THEN CONCAT('Nueva cotización creada: ',tempCotizacion.newDocumentNumber,' para ', customer.shortName)
                ELSE CONCAT('Advertencia se creo una nueva cotización cuya cotizacion anterior no ha sido facturada : ', tempCotizacion.newDocumentNumber, ' para ', customer.shortName )
            END,
            1,
            'Sistema',
            'Sistema',
            CASE 
                WHEN tempCotizacion.previusQuoteStatus = 3 THEN N'🟢Cotizacion creada'
                WHEN tempCotizacion.previusQuoteStatus IS NULL THEN N'🟢Cotizacion creada'
                ELSE N'🔴Cotizacion creada'
            END
        FROM #TempCotizaciones AS tempCotizacion
        LEFT JOIN Customers AS customer ON customer.customerID=tempCotizacion.idCustomer
--? ----------------- ↑↑↑ INSERCION DE LOS RECORDATORIOS EN LA TABLA TEMPORAL ↑↑↑ -----------------------

--* ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----


--? ----------------- ↓↓↓ INSERCION MASIVA A TABLAS REALES ↓↓↓ -----------------------
    -- + ----------------- ↓↓↓ INSERCION A PARTIDAS ↓↓↓ -----------------------
    INSERT INTO DocumentItems (
        document, 
        unit_price,
        unit_cost,
        idCatalogue,
        quantity,
        discount,
        totalImport,
        [order],
        createdBy,
        lastUpdatedBy,
        createdDate,
        lastUpdatedDate,
        ivaPercentage,
        [status],
        iva,
        subTotal,
        unitSellingPrice,
        unitPriceBeforeExchange,
        unitCostBeforeExchange,
        ivaBeforeExchange,
        subTotalBeforeExchange,
        unitSellingPriceBeforeExchange,
        calculationCostDiscount,
        calculationCostImport, 
        calculationCostIva,
        calculationCostSell, 
        calculationCostSubtotal,
        calculationCostUnitary, 
        calculationPriceDiscount,
        calculationPriceImport,
        calculationPriceIva,
        calculationPriceSell,
        calculationPriceSubtotal,
        calculationPriceUnitary,
        discountPercentage , 
        utility
    )
        SELECT
            newDocumentId,
            unit_price,
            unit_cost,
            idCatalogue,
            quantity,
            discount,
            totalImport,
            [order],
            createdBy,
            lastUpdateBy,
            createdDate,
            lastUpdateDate,
            ivaPercentage,
            [status],
            iva,
            subTotal,
            unitSellingPrice,
            unitPriceBeforeExchange,
            unitCostBeforeExchange,
            ivaBeforeExchange,
            subTotalBeforeExchange,
            unitSellingPriceBeforeExchange,
            calculationCostDiscount,
            calculationCostImport,
            calculationCostIva,
            calculationCostSell,
            calculationCostSubtotal,
            calculationCostUnitary,
            calculationPriceDiscount,
            calculationPriceImport,
            calculationPriceIva,
            calculationPriceSell,
            calculationPriceSubtotal,
            calculationPriceUnitary,
            discountPercentage,
            utility
        FROM #TemDocumentItems 
    -- + ----------------- ↑↑↑ INSERCION A PARTIDAS ↑↑↑ -----------------------

    -- + ----------------- ↓↓↓ INSERCION A COMENTARIOS ↓↓↓ -----------------------
    INSERT INTO DocumentsComments (
        documentId,
        comment,
        commentType,
        createdBy,
        lastUpdateBy,
        [order]
    )
        SELECT 
                newDocumentId,
                comment,
                commentType,
                createdBy,
                lastUpdateBy,
                [order]
        FROM #TemDocumentsComments
    -- + ----------------- ↑↑↑ INSERCION A COMENTARIOS ↑↑↑ -----------------------

    -- + ----------------- ↓↓↓ INSERCION A PERIODOS ↓↓↓ -----------------------
    INSERT INTO Periocity (
        createdBy,
        idDocument,
        idPeriocityType,
        lastUpdatedBy,
        [value],
        startDate,
        endDate
    )
        SELECT 
            createdBy,
            newDocumentId,
            idPeriocityType,
            lastUpdatedBy,
            [value],
            startDate,
            endDate
        FROM #TempPeriocity
    -- + ----------------- ↑↑↑ INSERCION A PERIODOS ↑↑↑ -----------------------

    -- + ----------------- ↓↓↓ INSERCION A RECORDATORIOS ↓↓↓ -----------------------
    INSERT INTO Commentation (
        registerById,
        mustAttendById,
        documentId,
        reminderDate,
        attentionDate,
        createdDate,
        comment,
        [status],
        createdBy,
        lastUpdateBy,
        commentTypeDescription,
        reminderFrom

    )
        SELECT 
            registerById,
            mustAttendById,
            newDocumentId,
            reminderDate,
            attentionDate,
            createDate,
            comment,
            [status],
            createdBy,
            lastUpdateBy,
            commentTypeDescription,
            0
            
        FROM #TempReminders
    -- + ----------------- ↑↑↑ INSERCION A RECORDATORIOS ↑↑↑ -----------------------
    

--? ----------------- ↑↑↑ INSERCION MASIVA A TABLAS REALES ↑↑↑ -----------------------


--* ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

--? ----------------- ↓↓↓ ACTUALIZAR EL ESTATUS DEL CONTRATO ↓↓↓ -----------------------
    UPDATE documents SET 
        documents.idStatus = 14
        FROM Documents AS documents
        INNER JOIN #TempCotizaciones AS tempContratos
        ON documents.idDocument = tempContratos.currentDocumentId
--? ----------------- ↑↑↑ ACTUALIZAR EL ESTATUS DEL CONTRATO ↑↑↑ -----------------------

--* ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

--? ----------------- ↓↓↓ SECCION DONDE SE BORRAN LAS TABLAS TEMPORALES ↓↓↓ -----------------------

    IF OBJECT_ID(N'tempdb..#TempCotizaciones') IS NOT NULL
        BEGIN
            DROP TABLE #TempCotizaciones
        END

    IF OBJECT_ID(N'tempdb..#TemDocumentItems') IS NOT NULL
        BEGIN
            DROP TABLE #TemDocumentItems
        END

    IF OBJECT_ID(N'tempdb..#TemDocumentsComments') IS NOT NULL
        BEGIN
            DROP TABLE #TemDocumentsComments
        END

    IF OBJECT_ID(N'tempdb..#TempPeriocity') IS NOT NULL
        BEGIN
            DROP TABLE #TempPeriocity
        END

    IF OBJECT_ID(N'tempdb..#TempNewQuotesIds') IS NOT NULL
        BEGIN
            DROP TABLE #TempNewQuotesIds
        END
    IF OBJECT_ID(N'tempdb..#TempReminders') IS NOT NULL
        BEGIN
            DROP TABLE #TempReminders
        END
    IF OBJECT_ID(N'tempdb..#TempWarningsReminders') IS NOT NULL
        BEGIN
            DROP TABLE #TempWarningsReminders
        END

--? ----------------- ↑↑↑ SECCION DONDE SE BORRAN LAS TABLAS TEMPORALES ↑↑↑ -----------------------

--! ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----



