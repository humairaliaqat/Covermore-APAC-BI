USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrFCUSAPolicyFY16]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrFCUSAPolicyFY16](
	[ARC] [varchar](2000) NULL,
	[Agency ID] [varchar](2000) NULL,
	[Store] [varchar](2000) NULL,
	[Agency Name] [varchar](2000) NULL,
	[Period] [datetime] NULL,
	[Status] [varchar](2000) NULL,
	[Policy Number] [varchar](2000) NULL,
	[Agent Initials] [varchar](2000) NULL,
	[Agent Email] [varchar](2000) NULL,
	[Policy Sale Date] [date] NULL,
	[Policy Effective Date] [date] NULL,
	[Product Name] [varchar](2000) NULL,
	[Product Plan Name] [varchar](2000) NULL,
	[First Name] [varchar](2000) NULL,
	[Last Name] [varchar](2000) NULL,
	[City] [varchar](2000) NULL,
	[State] [varchar](2000) NULL,
	[Destination] [varchar](2000) NULL,
	[Departure Date] [date] NULL,
	[Return Date] [date] NULL,
	[Trip Cost] [real] NULL,
	[Cost Per Person?] [varchar](2000) NULL,
	[Number of Insureds] [bigint] NULL,
	[Gross Premium] [real] NULL,
	[OutletAlphaKey] [nvarchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_agentid]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_agentid] ON [dbo].[usrFCUSAPolicyFY16]
(
	[Agency ID] ASC
)
INCLUDE([OutletAlphaKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
