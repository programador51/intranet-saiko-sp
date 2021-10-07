-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--
--	STORED PROCEDURE NAME:	sp_AddPermission 
--
--	DESCRIPTION:			This SP adds a new permission into the permission's table
--
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    	Revision Notes			
-- ==================================================================================================================================================
--	2021-10-06		Iván Díaz   					1.0.0.0			Initial Revision		
-- **************************************************************************************************************************************************


CREATE PROCEDURE sp_AddPermission(

	@rolID INT,
	@sectionID INT,
	@description NVARCHAR(50),
	@status TINYINT,
	@lastUpdatedBy NVARCHAR(50)

)

AS BEGIN

	INSERT INTO Permissions (
            rolID,sectionID,description,
            status,createdBy,createdDate,
            lastUpdatedBy,lastUpadatedDate)
        
        VALUES
    
        (
            @rolID,@sectionID,@description,
            @status,@lastUpdatedBy,GETDATE(),
            @lastUpdatedBy,GETDATE()
        )

END
