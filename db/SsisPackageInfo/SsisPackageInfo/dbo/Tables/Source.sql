CREATE TABLE [dbo].[Source] (
    [SourceId]     INT             IDENTITY (1, 1) NOT NULL,
    [ExecutableId] INT             NOT NULL,
    [ConnectionId] INT             NOT NULL,
    [Name]         NVARCHAR (1000) NOT NULL,
    [ClassId]      NVARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_Source] PRIMARY KEY CLUSTERED ([SourceId] ASC),
    CONSTRAINT [FK_Source_Connection] FOREIGN KEY ([ConnectionId]) REFERENCES [dbo].[Connection] ([ConnectionId]),
    CONSTRAINT [FK_Source_Executable] FOREIGN KEY ([ExecutableId]) REFERENCES [dbo].[Executable] ([ExecutableId]) ON DELETE CASCADE ON UPDATE CASCADE
);

