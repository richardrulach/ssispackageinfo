CREATE TABLE [dbo].[Source_Destination_Map] (
    [Source_Destination_MapId] INT IDENTITY (1, 1) NOT NULL,
    [SourceId]                 INT NOT NULL,
    [DestinationId]            INT NOT NULL,
    CONSTRAINT [PK_Source_Destination_Map] PRIMARY KEY CLUSTERED ([Source_Destination_MapId] ASC),
    CONSTRAINT [FK_Source_Destination_Map_Destination] FOREIGN KEY ([DestinationId]) REFERENCES [dbo].[Destination] ([DestinationId]),
    CONSTRAINT [FK_Source_Destination_Map_Source] FOREIGN KEY ([SourceId]) REFERENCES [dbo].[Source] ([SourceId])
);


GO
CREATE NONCLUSTERED INDEX [NCI_Source_Destination_Map]
    ON [dbo].[Source_Destination_Map]([SourceId] ASC, [DestinationId] ASC);

