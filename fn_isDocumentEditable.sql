-- ======================================================
-- Create Scalar Function Template for Azure SQL Database
-- ======================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 01-10-22
-- Description: Validate if the document is editable

-- Document status id que son editables.
-- Cotizacion:---------------- 1
-- OC:------------------------ 5
-- Prefactura:---------------- 9
-- CxC:----------------------- 16
-- CxP:----------------------- 20
-- Contrato:------------------ 13
-- Orde de pago:-------------- 24
-- Servicios recibidos:------- 28
-- =============================================
CREATE FUNCTION isDocumentEditable
(
    -- Add the parameters for the function here
    @documentId INT
)
RETURNS BIT
AS
BEGIN
    -- Declare the return variable here
	DECLARE @isEditable BIT;

    -- Add the T-SQL statements to compute the return value here
    SELECT 
    @isEditable= CASE 
	WHEN 
		idStatus = 1 OR 
		idStatus = 5 OR 
		idStatus = 9 OR 
		idStatus = 16 OR
		idStatus = 20 OR
		idStatus = 13 OR
		idStatus = 24 OR
		idStatus = 28
		THEN CONVERT(BIT,1)
    ELSE CONVERT(BIT,0) END
    FROM Documents WHERE idDocument = @documentId;
    -- Return the result of the function
    RETURN @isEditable
END
GO

