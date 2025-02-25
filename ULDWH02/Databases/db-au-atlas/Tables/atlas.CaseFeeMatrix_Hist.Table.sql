USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[CaseFeeMatrix_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[CaseFeeMatrix_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[Account_c] [varchar](25) NULL,
	[CaseFeeType_c] [nvarchar](50) NULL,
	[CaseFee_c] [money] NULL,
	[Case_Type_c] [nvarchar](50) NULL,
	[Client_Code_c] [varchar](255) NULL,
	[GST_c] [decimal](5, 2) NULL,
	[Name] [varchar](255) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_CaseFeeMatrix_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE CLUSTERED INDEX [ix_CaseFeeMatrix_Hist] ON [atlas].[CaseFeeMatrix_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
