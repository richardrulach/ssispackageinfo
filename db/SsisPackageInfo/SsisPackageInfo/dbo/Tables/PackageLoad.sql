CREATE TABLE [dbo].[PackageLoad] (
    [PackageLoadId] INT             IDENTITY (1, 1) NOT NULL,
    [SourceFolder]  NVARCHAR (1000) NOT NULL,
    [LoadDate]      DATETIME        CONSTRAINT [DF_PackageLoad_LoadDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PackageLoad] PRIMARY KEY CLUSTERED ([PackageLoadId] ASC)
);

