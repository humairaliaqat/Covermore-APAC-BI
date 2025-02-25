USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_e5WorkCaseNote]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_e5WorkCaseNote](
	[ClaimKey] [varchar](40) NULL,
	[CompletionDate] [datetime] NULL,
	[CaseNote] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_e5WorkCaseNote_ClaimNumber]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_e5WorkCaseNote_ClaimNumber] ON [cng].[Tmp_e5WorkCaseNote]
(
	[ClaimKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
