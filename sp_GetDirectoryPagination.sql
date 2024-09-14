-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin Iracheta 
-- Create date: 12-28-2021

-- Description: Gets the pagination for the directory table

-- STORED PROCEDURE NAME:	sp_GetDirectoryPagination
-- STORED PROCEDURE OLD NAME: sp_FilterDirectory_Pagination


-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @type INT The customer type id
-- @status TINYINT Status
-- @executive INT The executive id 
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================	
--  2021-12-28      Adrian Alardin Iracheta     1.0.0.0         Initial Revision	
--  2021-01-06      Adrian Alardin Iracheta     2.0.0.0         Improvement: It is more maintainable	
-- *****************************************************************************************************************************



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetDirectoryPagination (

	@type INT,
	@status TINYINT,
	@executive INT

)

AS BEGIN

DECLARE  @WHERE_CLAUSE NVARCHAR (MAX);
DECLARE  @SELECT_CLAUSE NVARCHAR (MAX);
DECLARE  @FROM_CLAUSE NVARCHAR (MAX);
DECLARE  @JOIN_CLAUSE NVARCHAR (MAX);
DECLARE  @SP_STATEMENT NVARCHAR (MAX);
DECLARE @PARAMS NVARCHAR (MAX);


-- We declare the variables
SET @PARAMS= '@type INT,@status INT,@executive INT'
-- We save the generic SELECT
SET @SELECT_CLAUSE='SELECT 
        Customers.customerID AS ID,
        Customers.status AS Estatus_cliente,
        Customers.customerType AS Customers_Tipo_Cliente,
        Customer_Executive.customerID,
        Customer_Executive.executiveID,
        Users.userID AS ID_Ejecutivo,
        CustomerTypes.customerTypeID AS ID_tipo_cliente ';

-- We save the FROM statement
SET @FROM_CLAUSE = 'FROM Customers ';

-- We save the JOIN statement
SET @JOIN_CLAUSE='JOIN Customer_Executive ON Customers.customerID = Customer_Executive.customerID
        JOIN Users ON Customer_Executive.executiveID = Users.userID
        JOIN CustomerTypes on Customers.customerType = CustomerTypes.customerTypeID ';
--------------

IF(@type=1)
    BEGIN
    SET @WHERE_CLAUSE='WHERE
		(Customers.status = @status OR @status IS NULL) AND
		(Customer_Executive.executiveID = @executive) AND
		(Customers.customerType = @type) '
      
    END

    ELSE IF (@type IS NULL)
    BEGIN
    SET @WHERE_CLAUSE='WHERE
		(Customers.status = @status OR @status IS NULL) AND
		(Customer_Executive.executiveID = @executive) OR
		(Customers.customerType = 2 OR Customers.customerType = 5) '
      
    END
    ELSE
        BEGIN
        SET @WHERE_CLAUSE='WHERE
            (Customers.status = @status OR @status IS NULL) AND
            (Customers.customerType = @type) '
        END

  SET @SP_STATEMENT= @SELECT_CLAUSE +@FROM_CLAUSE+@JOIN_CLAUSE+ @WHERE_CLAUSE;
  
  EXEC SP_EXECUTESQL @SP_STATEMENT,@PARAMS, @type, @status, @executive

END


