DECLARE @documentId INT = 239;
DECLARE @commnet NVARCHAR (256) = 'Son pruebas de comentarios';
DECLARE @commentType INT = 3;
DECLARE @createdBy NVARCHAR (30)= 'Adrian Alardin Iracheta';
DECLARE @order INT = 1
DECLARE @ccArray NVARCHAR(MAX)= '1,2,3,4';

DECLARE @commentId INT;

INSERT INTO DocumentsComments (
    documentId,
    comment,
    commentType,
    createdBy,
    lastUpdateBy,
    [order]
)
VALUES (
    @documentId,
    @commnet,
    @commentType,
    @createdBy,
    @createdBy,
    @order
)

SELECT @commentId = SCOPE_IDENTITY();

IF @commentType = 3
    BEGIN
        IF @ccArray IS NOT NULL 
            BEGIN
                INSERT INTO CommentsCopiedTo (
                    idComment,
                    idTypeDocument,
                    createdBy,
                    lastUpdateBy
                )
                SELECT 
                    @commentId,
                    value,
                    @createdBy,
                    @createdBy
                FROM STRING_SPLIT(@ccArray, ',')
                WHERE RTRIM(value)<>''
            END
    END