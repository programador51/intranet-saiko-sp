DECLARE @idDocument INT = 4727

DECLARE @idContact INT;
SELECT 
    @idContact= idContact
FROM Documents
WHERE idDocument=@idDocument


IF(@idContact IS NOT NULL)
    BEGIN
        IF OBJECT_ID(N'tempdb..#TempUens') IS NOT NULL 
                BEGIN
                DROP TABLE #TempUens
            END



        DECLARE @status TINYINT = 1;


        CREATE TABLE #TempUens (
            id INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
            idUen INT NOT NULL
        )



        INSERT INTO #TempUens (
            idUen
        )
        SELECT DISTINCT
            catalogue.uen
        FROM DocumentItems AS items
        LEFT JOIN Catalogue AS catalogue ON catalogue.id_code=items.idCatalogue
        WHERE items.document=@idDocument

        -- SELECT * FROM #TempUens

        INSERT INTO ContactsByUens (
            idContact,
            idUen,
            idDocument,
            createdBy,
            createdDate,
            [status],
            unblockedBy,
            updatedDate

        )
        SELECT 
            tempUens.idUen
        FROM #TempUens AS tempUens
        LEFT JOIN ContactsByUens AS contactByUen ON contactByUen.idContact=@idContact
        WHERE contactByUen.idUen!=tempUens.idUen

        IF OBJECT_ID(N'tempdb..#TempUens') IS NOT NULL 

                BEGIN
                DROP TABLE #TempUens
            END
    END


    -- SELECT * FROM Documents WHERE idTypeDocument= 1


