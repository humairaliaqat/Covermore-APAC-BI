USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cisAgent]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisAgent](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AgentKey] [nvarchar](50) NOT NULL,
	[AgentID] [int] NOT NULL,
	[ProfileID] [int] NOT NULL,
	[AgentLogin] [nvarchar](50) NOT NULL,
	[AgentFirstName] [nvarchar](50) NOT NULL,
	[AgentLastName] [nvarchar](50) NOT NULL,
	[AgentName] [nvarchar](50) NOT NULL,
	[TeamName] [nvarchar](50) NOT NULL,
	[JobTitle] [nvarchar](4000) NOT NULL,
	[Manager] [nvarchar](4000) NOT NULL,
	[EmailAddress] [nvarchar](4000) NOT NULL,
	[Department] [nvarchar](4000) NOT NULL,
	[Company] [nvarchar](4000) NOT NULL,
	[isActive] [bit] NOT NULL,
	[DateInactive] [datetime] NULL,
	[isAutoAvail] [bit] NOT NULL,
	[Extension] [nvarchar](50) NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisAgent_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cisAgent_BIRowID] ON [dbo].[cisAgent]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisAgent_AgentKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisAgent_AgentKey] ON [dbo].[cisAgent]
(
	[AgentKey] ASC
)
INCLUDE([AgentLogin],[AgentID],[AgentName],[TeamName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisAgent_AgentLogin]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisAgent_AgentLogin] ON [dbo].[cisAgent]
(
	[AgentLogin] ASC
)
INCLUDE([AgentKey],[AgentID],[AgentName],[TeamName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisAgent_Extension]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisAgent_Extension] ON [dbo].[cisAgent]
(
	[Extension] ASC,
	[DateInactive] ASC
)
INCLUDE([AgentLogin],[AgentID],[AgentName],[TeamName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
