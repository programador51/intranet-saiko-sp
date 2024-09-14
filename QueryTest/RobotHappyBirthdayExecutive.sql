DECLARE @todayDate DATETIME= dbo.fn_MexicoLocalTime(GETDATE());
DECLARE @message NVARCHAR(1000);

SELECT  @message=[value] FROM Parameters WHERE parameter=36
 
INSERT INTO Advertisements (
    registrationUserID,
    registrationDate,
    startDate,
    endDate,
    [message],
    messageTypeID,
    [status],
    createdBy,
    createdDate,
    lastUpdatedBy,
    lastUpadatedDate
) 

    SELECT
        20,-- registrationUserID
        dbo.fn_MexicoLocalTime(GETDATE()) ,-- registrationDate
        dbo.fn_MexicoLocalTime(GETDATE()) ,-- startDate
        dbo.fn_MexicoLocalTime(GETDATE()) ,-- endDate
        CASE 
            WHEN middleName IS NULL THEN CONCAT(firstName, ' ', lastName1, ' ', lastName2, ' ',@message)
            ELSE CONCAT(firstName, ' ',middleName,' ', lastName1, ' ', lastName2, ' ',@message)
        END,-- message
        2, -- messageTypeID
        1,--status
        'SISTEMA',--createdBy
        dbo.fn_MexicoLocalTime(GETDATE()),--createdDate
        'SISTEMA',--lastUpdatedBy
        dbo.fn_MexicoLocalTime(GETDATE())--lastUpadatedDate
     FROM Users
    WHERE birthDay= DAY (@todayDate) AND birthMonth = MONTH(@todayDate)


