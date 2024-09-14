DECLARE @createdBy NVARCHAR(30)
DECLARE @description NVARCHAR(30);
DECLARE @idExecutive INT;
DECLARE @idType INT;


INSERT INTO Tags (
    createdBy,
    createdDate,
    [description],
    idExecutive,
    idType,
    lastUpdateBy,
    lastUpdateDate,
    [status]
)
VALUES(
    @createdBy,
    dbo.fn_MexicoLocalTime(GETDATE()),
    @description,
    @idExecutive,
    @idType,
    @createdBy,
    dbo.fn_MexicoLocalTime(GETDATE()),
    1

)

SELECT SCOPE_IDENTITY() AS tagId;