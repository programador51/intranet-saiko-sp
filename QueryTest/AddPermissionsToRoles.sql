DECLARE @createdBy NVARCHAR(30) = 'Adrian Alardin Iracheta'
DECLARE @rolId INT = 28
DECLARE @status TINYINT = 1
DECLARE @arrayUuid NVARCHAR(MAX)= '200,201,202'


BEGIN TRANSACTION
    INSERT INTO RolePermissions (
        createdBy,
        createdDate,
        lastUpdatedBy,
        lastUpdatedDate,
        rolId,
        uuid,
        [status]

    )
        SELECT 
            @createdBy,
            dbo.fn_MexicoLocalTime(GETDATE()),
            @createdBy,
            dbo.fn_MexicoLocalTime(GETDATE()),
            @rolId,
            value,
            1
        FROM STRING_SPLIT(@arrayUuid, ',')
        WHERE RTRIM(value)<>''
COMMIT
