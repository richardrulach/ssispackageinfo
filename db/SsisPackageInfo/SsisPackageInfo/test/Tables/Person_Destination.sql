CREATE TABLE [test].[Person_Destination] (
    [Person_DestinationId] INT          IDENTITY (1, 1) NOT NULL,
    [FullName]             VARCHAR (50) NOT NULL,
    [Age]                  INT          NOT NULL,
    CONSTRAINT [PK_Person_Destination] PRIMARY KEY CLUSTERED ([Person_DestinationId] ASC)
);

