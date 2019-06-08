CREATE TABLE [dbo].[Package] (
    [PackageId]     INT             IDENTITY (1, 1) NOT NULL,
    [PackageLoadId] INT             NOT NULL,
    [FullPath]      NVARCHAR (1000) NOT NULL,
    [PackageName]   NVARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_Package] PRIMARY KEY CLUSTERED ([PackageId] ASC),
    CONSTRAINT [FK_Package_PackageLoad] FOREIGN KEY ([PackageLoadId]) REFERENCES [dbo].[PackageLoad] ([PackageLoadId]) ON DELETE CASCADE ON UPDATE CASCADE
);

