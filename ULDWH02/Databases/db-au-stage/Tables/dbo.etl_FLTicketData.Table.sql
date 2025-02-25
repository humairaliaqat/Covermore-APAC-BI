USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_FLTicketData]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_FLTicketData](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](2) NOT NULL,
	[OutletKey] [varchar](33) NULL,
	[OutletID] [int] NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[IssuedDate] [datetime] NULL,
	[ExtID] [nvarchar](255) NULL,
	[FLTicketCountINT] [float] NULL,
	[FLTicketCountDOM] [float] NULL,
	[CMPolicyCountINT] [float] NULL,
	[CMPolicyCountDOM] [float] NULL,
	[PCC] [nvarchar](20) NULL
) ON [PRIMARY]
GO
