CREATE TABLE [dbo].[Executable] (
    [ExecutableId]     INT             IDENTITY (1, 1) NOT NULL,
    [PackageId]        INT             NOT NULL,
    [ExecutableTypeId] INT             NOT NULL,
    [Name]             NVARCHAR (1000) NOT NULL,
    [ClassId]          NVARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_Executable] PRIMARY KEY CLUSTERED ([ExecutableId] ASC),
    CONSTRAINT [FK_Executable_ExecutableType] FOREIGN KEY ([ExecutableTypeId]) REFERENCES [dbo].[ExecutableType] ([ExecutableTypeId]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_Executable_Package] FOREIGN KEY ([PackageId]) REFERENCES [dbo].[Package] ([PackageId]) ON DELETE CASCADE ON UPDATE CASCADE
);

