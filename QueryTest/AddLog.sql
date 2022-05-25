
DECLARE @createdBy NVARCHAR(30);
DECLARE @infoSended NVARCHAR(MAX);
DECLARE @responseReceived NVARCHAR(MAX);
DECLARE @error NVARCHAR(MAX);
DECLARE @wasAnError TINYINT;
DECLARE @mustBeSyncManually TINYINT;
DECLARE @provider TINYINT;

INSERT INTO Logs (
    [provider],
    createdBy,
    infoSended,
    responseReceived,
    wasAnError,
    error,
    mustBeSyncManually
)

VALUES (
    @provider,
    @createdBy,
    @infoSended,
    @responseReceived,
    @wasAnError,
    @error,
    @mustBeSyncManually
)

