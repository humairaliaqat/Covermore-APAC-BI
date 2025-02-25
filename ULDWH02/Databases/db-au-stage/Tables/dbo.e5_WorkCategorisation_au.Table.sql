USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_WorkCategorisation_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_WorkCategorisation_au](
	[Id] [bigint] NOT NULL,
	[Work_Id] [uniqueidentifier] NOT NULL,
	[WorkFaceTime_Id] [bigint] NULL,
	[FromCat_Id] [int] NULL,
	[ToCat_Id] [int] NULL,
	[ChangeDate] [datetime] NOT NULL,
	[ChangeUser] [nvarchar](100) NULL
) ON [PRIMARY]
GO
