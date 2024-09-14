SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_ChangeCurencyAgainstDocument](
    @tc DECIMAL(14,4),
    @import DECIMAL (14,4),
    @documentCurrency NVARCHAR(3),
    @itemCurrency NVARCHAR(3)

)

RETURNS DECIMAL(14,4)


BEGIN
DECLARE @newImport DECIMAL(14,4);
    IF @documentCurrency = @itemCurrency
        BEGIN
            SET @newImport= @import;
        END
    ELSE
        BEGIN
            IF @documentCurrency='MXN'
                BEGIN
                -- SIGNIFICA QUE LAS MONEDAS NO SON IGUALES (DOCUMENTO = MXN Y ITEMS = USD)
                    SELECT @newImport= @import/@tc
                END
            ELSE 
                BEGIN 
                    SELECT @newImport= @import*@tc
                END

        END
    RETURN @newImport
END
GO
