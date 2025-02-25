USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_WorkActivityProperty_v4]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_WorkActivityProperty_v4](
	[Work_Id] [uniqueidentifier] NOT NULL,
	[WorkActivity_Id] [uniqueidentifier] NOT NULL,
	[Property_Id] [nvarchar](32) NOT NULL,
	[PropertyValue] [sql_variant] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [e5_WorkActivityProperty_v4]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [e5_WorkActivityProperty_v4] ON [dbo].[e5_WorkActivityProperty_v4]
(
	[Work_Id] ASC,
	[WorkActivity_Id] ASC,
	[Property_Id] ASC
)
INCLUDE([PropertyValue]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
