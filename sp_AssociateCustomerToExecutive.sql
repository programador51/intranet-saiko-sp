CREATE PROCEDURE sp_AssociateCustomerToExecutive(

	@customerID INT,
	@executiveID INT,
	@status TINYINT,
	@createdBy NVARCHAR(30)

)

AS BEGIN

	INSERT INTO Customer_Executive
        (
            customerID,executiveID,status,
            createdBy,createdDate,lastUpdatedBy,
            lastUpdatedDate
        )
        
        VALUES

        (
            @customerID,@executiveID,@status,
            @createdBy,GETDATE(),@createdBy,
            GETDATE()
        )

END