CREATE TABLE [dbo].[Destination] (
    [DestinationId] INT             IDENTITY (1, 1) NOT NULL,
    [ExecutableId]  INT             NOT NULL,
    [ConnectionId]  INT             NOT NULL,
    [Name]          NVARCHAR (1000) NOT NULL,
    [ClassId]       NVARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_Destination] PRIMARY KEY CLUSTERED ([DestinationId] ASC),
    CONSTRAINT [FK_Destination_Connection] FOREIGN KEY ([ConnectionId]) REFERENCES [dbo].[Connection] ([ConnectionId]),
    CONSTRAINT [FK_Destination_Executable] FOREIGN KEY ([ExecutableId]) REFERENCES [dbo].[Executable] ([ExecutableId]) ON DELETE CASCADE ON UPDATE CASCADE
);

