USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrRPT0370]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRPT0370](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyID] [int] NULL,
	[ReportSet] [int] NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Propagated] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrRPT0370_BIRowID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE UNIQUE CLUSTERED INDEX [idx_usrRPT0370_BIRowID] ON [dbo].[usrRPT0370]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrRPT0370_PolicyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0370_PolicyKey] ON [dbo].[usrRPT0370]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrRPT0370_Propagated]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0370_Propagated] ON [dbo].[usrRPT0370]
(
	[Propagated] ASC
)
INCLUDE([PolicyID],[ReportSet]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[usrRPT0370] ADD  DEFAULT (getdate()) FOR [CreateDateTime]
GO
ALTER TABLE [dbo].[usrRPT0370] ADD  DEFAULT (getdate()) FOR [UpdateDateTime]
GO
ALTER TABLE [dbo].[usrRPT0370] ADD  DEFAULT ((0)) FOR [Propagated]
GO
