CREATE TABLE [dbo].[ExecutableType] (
    [ExecutableTypeId] INT             IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_ExecutableType] PRIMARY KEY CLUSTERED ([ExecutableTypeId] ASC)
);

