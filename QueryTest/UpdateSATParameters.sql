

-- 31,33,34

DECLARE @cfdiId NVARCHAR(100);
DECLARE @payFormId NVARCHAR(100);
DECLARE @payMethodId NVARCHAR(100);

DECLARE @tranName NVARCHAR(30) ='updateSAT';
BEGIN TRY
    BEGIN TRANSACTION @tranName


    UPDATE Parameters
        SET [value]=@cfdiId
    WHERE parameter=31
    UPDATE Parameters
        SET [value]=@payFormId
    WHERE parameter=33
    UPDATE Parameters
        SET [value]=@payMethodId
    WHERE parameter=34

    SELECT @@ROWCOUNT AS rowAfected

    COMMIT TRANSACTION @tranName;

END TRY

BEGIN CATCH
    DECLARE @Message NVARCHAR(MAX)= ERROR_MESSAGE()
    DECLARE @Severity  INT= ERROR_SEVERITY()
    DECLARE @State   SMALLINT = ERROR_SEVERITY()
    

    IF (XACT_STATE()= -1)
            BEGIN
                ROLLBACK TRANSACTION @tranName
            END
        IF (XACT_STATE()=1)
            BEGIN
                COMMIT TRANSACTION @tranName
            END

        IF @@TRANCOUNT > 0  
            BEGIN
                ROLLBACK TRANSACTION @tranName;   
            END
        -- SELECT 
        --     ERROR_NUMBER() AS CodeNumber,  
        --     ERROR_STATE() AS ErrorOccurred,   
        --     ERROR_MESSAGE() AS [Message]

            
RAISERROR(@Message, @Severity, @State)
END CATCH