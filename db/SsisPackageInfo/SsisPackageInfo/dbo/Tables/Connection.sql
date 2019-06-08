CREATE TABLE [dbo].[Connection] (
    [ConnectionId] INT             IDENTITY (1, 1) NOT NULL,
    [PackageId]    INT             NOT NULL,
    [Name]         NVARCHAR (1000) NOT NULL,
    [ClassId]      NVARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_Connection] PRIMARY KEY CLUSTERED ([ConnectionId] ASC),
    CONSTRAINT [FK_Connection_Package] FOREIGN KEY ([PackageId]) REFERENCES [dbo].[Package] ([PackageId]) ON DELETE CASCADE ON UPDATE CASCADE
);

