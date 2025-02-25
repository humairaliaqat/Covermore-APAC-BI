USE [db-au-bobjaudit]
GO
/****** Object:  Table [dbo].[ADS_CLUSTER]    Script Date: 21/02/2025 11:29:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_CLUSTER](
	[Cluster_ID] [varchar](64) NOT NULL,
	[Retrieved_Events_Completed_By] [datetime] NULL,
	[Last_Poll_Time] [datetime] NULL,
	[Potentially_Incomplete_Data] [int] NULL,
 CONSTRAINT [ADS_CLUSTER_Cluster_ID] PRIMARY KEY CLUSTERED 
(
	[Cluster_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
