DECLARE @mustReversIt BIT =1;
DECLARE @idMovement INT =173;
SELECT * FROM #TemporalReversCxC

IF (@mustReversIt=1)
    BEGIN
        -- DELETE FROM ConcilationCxC WHERE idMovement=@idMovement;
        IF OBJECT_ID(N'tempdb..#TemporalReversCxC') IS NOT NULL
        BEGIN
            DROP TABLE #TemporalReversCxC
        END
        SELECT * FROM #TemporalReversCxC
    END

ELSE
    BEGIN
        IF OBJECT_ID(N'tempdb..#TemporalReversCxC') IS NOT NULL
        BEGIN
            DROP TABLE #TemporalReversCxC
        END
    END
