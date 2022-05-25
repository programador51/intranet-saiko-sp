
DECLARE @documentId INT = 247
DECLARE @documentType INT =3
SELECT  
    DocComments.id,
    DocComments.comment,
    DocComments.commentType,
    DocComments.[order]

FROM DocumentsComments AS DocComments
LEFT JOIN CommentsCopiedTo AS CommentsCC ON CommentsCC.idComment=DocComments.id 
WHERE DocComments.documentId=@documentId AND CommentsCC.idTypeDocument=@documentType
ORDER BY CASE
            WHEN DocComments.commentType= 1 THEN 1
            WHEN DocComments.commentType= 2 THEN 3
            WHEN DocComments.commentType= 3 THEN 2
            ELSE NULL END, DocComments.[order]