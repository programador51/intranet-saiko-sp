DECLARE @idExecutive INT=20;
DECLARE @userStatus INT=1;

IF OBJECT_ID(N'tempdb..#TemChildRoles') IS NOT NULL
        BEGIN
            DROP TABLE #TemChildRoles
        END

CREATE TABLE #TemChildRoles (
    id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    idChildRole INT
)

INSERT INTO #TemChildRoles (
    idChildRole
)
    SELECT 
        parentRole.idChildRole 
    FROM Users AS users
    LEFT JOIN ParentRoles AS parentRole ON parentRole.idParentRole= users.rol
    WHERE users.userID= @idExecutive
    
    SELECT 
        users.userID AS idRegister,
        users.userID AS idUser,
        users.rol AS rolID,
        users.userID AS ignore,
        users.firstName,
        users.middleName,
        users.lastName1,
        users.lastName2,
        CONCAT(users.firstName,' ',users.middleName,' ',users.lastName1,' ',users.lastName2) AS fullName,
        CONVERT(BIT,0) AS mustErase
    
    FROM #TemChildRoles AS tempRoles
    LEFT JOIN Users AS users ON users.rol= tempRoles.idChildRole
    WHERE users.[status]= @userStatus ORDER BY users.lastName1



    IF OBJECT_ID(N'tempdb..#TemChildRoles') IS NOT NULL
        BEGIN
            DROP TABLE #TemChildRoles
        END
