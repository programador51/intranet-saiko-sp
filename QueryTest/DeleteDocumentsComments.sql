DECLARE @documentId INT =247;

 DELETE FROM CommentsCopiedTo 
        WHERE idComment = (SELECT id FROM DocumentsComments WHERE documentId=@documentId)
    DELETE FROM DocumentsComments 
        WHERE documentId=@documentId
    