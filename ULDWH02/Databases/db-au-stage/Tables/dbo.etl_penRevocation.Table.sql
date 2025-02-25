USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penRevocation]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penRevocation](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[DomainKey] [varchar](41) NULL,
	[RevocationKey] [varchar](69) NULL,
	[OutletKey] [varchar](33) NOT NULL,
	[RevocationID] [bigint] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[CreateDateTimeUTC] [datetime] NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[UserId] [varchar](255) NULL,
	[UserName] [varchar](511) NULL,
	[TemplateName] [varchar](255) NULL
) ON [PRIMARY]
GO
