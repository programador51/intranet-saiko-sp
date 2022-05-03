SELECT 
    [comment],
    [order],
    commentType
 FROM DocumentsComments 
 WHERE documentId= 247
 ORDER BY commentType, [order]