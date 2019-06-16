CREATE TABLE [test].[Person_Source] (
    [Person_SourceId] INT          IDENTITY (1, 1) NOT NULL,
    [FullName]        VARCHAR (50) NOT NULL,
    [Age]             INT          NOT NULL,
    CONSTRAINT [PK_Person_Source] PRIMARY KEY CLUSTERED ([Person_SourceId] ASC)
);

