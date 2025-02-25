USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penAssistanceFee]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penAssistanceFee](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[AssistanceFeeKey] [varchar](71) NULL,
	[JointVentureKey] [varchar](71) NULL,
	[AssistanceFeeId] [int] NOT NULL,
	[JointVentureId] [int] NOT NULL,
	[DomainID] [int] NULL,
	[Value] [numeric](18, 4) NOT NULL,
	[EffectiveFrom] [date] NOT NULL,
	[CRMUserID] [int] NULL,
	[IsPolicyCount] [bit] NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Status] [nvarchar](15) NOT NULL,
	[CreateDateTimeUTC] [datetime] NOT NULL,
	[UpdateDateTimeUTC] [datetime] NOT NULL
) ON [PRIMARY]
GO
