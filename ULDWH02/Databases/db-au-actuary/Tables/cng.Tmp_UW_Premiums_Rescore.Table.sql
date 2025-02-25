USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_UW_Premiums_Rescore]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_UW_Premiums_Rescore](
	[PolicyKey] [nvarchar](50) NOT NULL,
	[Domain Country] [nvarchar](400) NULL,
	[Issue Month] [date] NULL,
	[Policy Status] [nvarchar](400) NULL,
	[UW Rating Group] [nvarchar](400) NULL,
	[JV Description] [nvarchar](400) NULL,
	[JV Group] [nvarchar](400) NULL,
	[Product Code] [nvarchar](50) NOT NULL,
	[Product Name] [nvarchar](400) NULL,
	[GLM Segment] [nvarchar](400) NULL,
	[GLM Segment2] [nvarchar](400) NULL,
	[GLM Freq MED] [float] NULL,
	[GLM Freq CAN] [float] NULL,
	[GLM Freq ADD] [float] NULL,
	[GLM Freq LUG] [float] NULL,
	[GLM Freq MIS] [float] NULL,
	[GLM Freq UDL] [float] NULL,
	[GLM Size MED] [float] NULL,
	[GLM Size CAN] [float] NULL,
	[GLM Size ADD] [float] NULL,
	[GLM Size LUG] [float] NULL,
	[GLM Size MIS] [float] NULL,
	[GLM Size LGE] [float] NULL,
	[GLM Size ULD] [float] NULL,
	[GLM CPP MED] [float] NULL,
	[GLM CPP CAN] [float] NULL,
	[GLM CPP ADD] [float] NULL,
	[GLM CPP LUG] [float] NULL,
	[GLM CPP MIS] [float] NULL,
	[GLM CPP LGE] [float] NULL,
	[GLM CPP UDL] [float] NULL,
	[GLM CPP CAT] [float] NULL,
	[GLM CPP] [float] NULL,
	[GLM UWP MED] [float] NULL,
	[GLM UWP CAN] [float] NULL,
	[GLM UWP ADD] [float] NULL,
	[GLM UWP LUG] [float] NULL,
	[GLM UWP MIS] [float] NULL,
	[GLM UWP LGE] [float] NULL,
	[GLM UWP UDL] [float] NULL,
	[GLM UWP CAT] [float] NULL,
	[GLM UWP] [float] NULL,
	[UW_Premium] [float] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_UW_Premiums_Rescore_PolicyKeyProductCode]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_UW_Premiums_Rescore_PolicyKeyProductCode] ON [cng].[Tmp_UW_Premiums_Rescore]
(
	[PolicyKey] ASC,
	[Product Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
