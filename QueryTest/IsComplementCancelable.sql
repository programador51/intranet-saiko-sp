DECLARE @concilationArray NVARCHAR(MAX) ='349,350'
DECLARE @idMovement INT= 241;

DECLARE @hasComplement BIT;
DECLARE @isComplementCancelable BIT=0;
DECLARE @ppdCount INT;
DECLARE @complementStatus TINYINT;

SELECT 
    @hasComplement= 
        CASE
            WHEN idPaymentPluginStatus = 2 THEN 1
            ELSE 0
        END
FROM Movements
WHERE MovementID=@idMovement AND [status] NOT IN(1,5)


SELECT 
    @complementStatus=[status] 
FROM Complements 
WHERE idMovement=@idMovement AND [status]=1

SELECT 
    @ppdCount=COUNT(*)
FROM Documents WHERE uuid IN (
    SELECT 
        uuid
    FROM ConcilationCxC 
    WHERE id IN (SELECT CONVERT(INT,[value]) FROM string_split(@concilationArray,','))
    GROUP BY uuid
) AND idTypeDocument=2 AND idPaymentForm=1


IF (@ppdCount>0 AND @hasComplement=1 AND @complementStatus=1)
    BEGIN
        SET @isComplementCancelable=1
    END

SELECT @isComplementCancelable AS isComplementCancelable
