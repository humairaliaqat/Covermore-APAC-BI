USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[etl_CTM_Cancellation]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_CTM_Cancellation](
	[QuoteReference] [nvarchar](225) NULL,
	[PartnerQuoteReference] [varchar](500) NULL,
	[CancellationDate] [datetime] NULL,
	[cancellationEffectiveDate] [varchar](1) NOT NULL,
	[commencementDate] [datetime] NULL,
	[comparisonBrand] [varchar](3) NOT NULL,
	[policyNumber] [varchar](50) NULL,
	[policyRiskNumber] [int] NOT NULL,
	[emailAddress] [nvarchar](255) NULL,
	[cancellationReason] [nvarchar](250) NULL,
	[brand] [varchar](4) NOT NULL,
	[TransactionDateTime] [varchar](20) NULL
) ON [PRIMARY]
GO
