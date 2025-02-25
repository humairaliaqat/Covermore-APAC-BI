USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cisco_contactservicequeue]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisco_contactservicequeue](
	[contactservicequeueid] [int] NOT NULL,
	[profileid] [int] NOT NULL,
	[csqname] [varchar](50) NOT NULL,
	[resourcepooltype] [smallint] NOT NULL,
	[resourcegroupid] [int] NULL,
	[selectioncriteria] [varchar](30) NOT NULL,
	[skillgroupid] [int] NULL,
	[servicelevel] [int] NOT NULL,
	[servicelevelpercentage] [smallint] NOT NULL,
	[active] [bit] NOT NULL,
	[autowork] [bit] NOT NULL,
	[dateinactive] [datetime2](7) NULL,
	[queuealgorithm] [varchar](30) NOT NULL,
	[recordid] [int] NOT NULL,
	[orderlist] [int] NULL,
	[wrapuptime] [smallint] NULL,
	[prompt] [varchar](256) NOT NULL,
	[privatedata] [image] NULL,
	[queuetype] [smallint] NOT NULL,
	[queuetypename] [varchar](30) NULL,
	[accountuserid] [varchar](254) NULL,
	[accountpassword] [varchar](255) NULL,
	[channelproviderid] [int] NULL,
	[reviewqueueid] [int] NULL,
	[routingtype] [varchar](30) NULL,
	[foldername] [varchar](255) NULL,
	[pollinginterval] [int] NULL,
	[snapshotage] [int] NULL,
	[feedid] [varchar](30) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cidx_cisco_contactservicequeue]    Script Date: 24/02/2025 5:22:16 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_cisco_contactservicequeue] ON [dbo].[cisco_contactservicequeue]
(
	[recordid] ASC,
	[profileid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
