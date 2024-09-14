DECLARE @isAuthorized BIT
DECLARE @repply NVARCHAR(256)
DECLARE @limitTime DATETIME
DECLARE @tc DECIMAL(14,2)
DECLARE @partialities INT
DECLARE @idTodo INT
DECLARE @idExecutive INT
DECLARE @updatedBy NVARCHAR(30)

DECLARE @idFrom INT;
DECLARE @idCustomer INT;
DECLARE @todayUTC DATETIME;
DECLARE @parent NVARCHAR(256);

SELECT @todayUTC = GETUTCDATE();

DECLARE @idExecutiveRequested INT;
SELECT 
    @idExecutiveRequested =executiveWhoCreatedId,
    @idFrom=fromId,
    @idCustomer= customerId,
    @parent= parent
FROM ToDo WHERE id=@idTodo;

EXEC sp_UpdateTerminateToDo @idTodo,@idExecutive,@updatedBy;

EXEC sp_AddToDo 
    NULL,
    @todayUTC,
    @updatedBy,
    @idExecutive,
    @idFrom,
    5,
    -200,
    @todayUTC,
    'Autorizaciones',
    'Respuesta de la solisitud de autorización',
    @repply,
    @idCustomer,
    @parent;
EXEC sp_UpdateAuthorizationRequest 
1,
@updatedBy,
@todayUTC,
@limitTime,
@partialities,
@tc,
@isAuthorized,
@idFrom;