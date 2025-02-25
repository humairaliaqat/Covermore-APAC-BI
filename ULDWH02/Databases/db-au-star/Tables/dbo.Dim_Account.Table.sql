USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_Account]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Account](
	[Account_SK] [int] IDENTITY(0,1) NOT NULL,
	[Account_CODE] [varchar](50) NOT NULL,
	[Account_Desc] [varchar](200) NULL,
	[Account_Operator] [varchar](50) NOT NULL,
	[Account_Order] [int] NOT NULL,
	[Account_Hierarchy_Type] [varchar](200) NULL,
	[Parent_Account_SK] [int] NULL,
	[Create_Date] [datetime] NOT NULL,
	[Update_Date] [datetime] NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL,
	[Account_Category] [varchar](200) NULL,
	[Account_SID] [int] NOT NULL,
	[FIPAccount] [varchar](50) NULL,
	[SAPPE3Account] [varchar](50) NULL,
	[FIPTOB] [varchar](50) NULL,
	[SAPTOB] [varchar](50) NULL,
	[TOM] [varchar](50) NULL,
	[AccountType] [varchar](5) NULL,
	[StatutoryMapping] [nvarchar](255) NULL,
	[InternalMapping] [nvarchar](255) NULL,
	[Technical] [varchar](5) NULL,
	[Intercompany] [varchar](5) NULL,
 CONSTRAINT [Dim_Account_PK] PRIMARY KEY CLUSTERED 
(
	[Account_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx_Account_Code]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_Account_Code] ON [dbo].[Dim_Account]
(
	[Account_CODE] ASC,
	[Account_Hierarchy_Type] ASC
)
INCLUDE([Account_SK],[Account_Desc],[Account_Order],[Parent_Account_SK],[Account_SID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_Account_SK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_Account_SK] ON [dbo].[Dim_Account]
(
	[Account_SK] ASC
)
INCLUDE([Account_CODE],[Account_Desc],[Account_Order],[Parent_Account_SK]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_Parent_Account]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_Parent_Account] ON [dbo].[Dim_Account]
(
	[Parent_Account_SK] ASC
)
INCLUDE([Account_SK],[Account_CODE],[Account_Desc],[Account_Order]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX02_Dim_Account]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [IX02_Dim_Account] ON [dbo].[Dim_Account]
(
	[Account_SID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Dim_Account] ADD  DEFAULT (NEXT VALUE FOR [dbo].[AccountSID]) FOR [Account_SID]
GO
