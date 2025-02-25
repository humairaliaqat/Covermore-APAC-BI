USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPaymentURL_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPaymentURL_autp](
	[UrlID] [int] NOT NULL,
	[PaymentURL] [varchar](200) NOT NULL,
	[URLDescription] [varchar](50) NOT NULL,
	[PolicyDomainID] [int] NULL
) ON [PRIMARY]
GO
