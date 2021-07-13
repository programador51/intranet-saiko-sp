CREATE PROCEDURE sp_SelectTypeCustomers

AS BEGIN

	SELECT
        customerTypeID AS value,
        description AS text,
        status
        FROM CustomerTypes

END