USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penAutoComment]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penAutoComment](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[AutoCommentKey] [varchar](71) NULL,
	[OutletKey] [varchar](71) NULL,
	[CSRKey] [varchar](71) NULL,
	[DomainID] [int] NULL,
	[AutoCommentID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[CSRID] [int] NOT NULL,
	[AlphaCode] [nvarchar](50) NOT NULL,
	[AutoComments] [nvarchar](max) NOT NULL,
	[CommentDate] [datetime] NULL,
	[CommentDateUTC] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
