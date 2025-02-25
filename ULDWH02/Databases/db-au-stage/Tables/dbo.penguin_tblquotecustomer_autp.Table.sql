USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblquotecustomer_autp]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblquotecustomer_autp](
	[QuoteCustomerID] [int] NOT NULL,
	[CustomerID] [int] NULL,
	[QuoteID] [int] NOT NULL,
	[IsPrimary] [bit] NOT NULL,
	[Age] [int] NULL,
	[IsAdult] [bit] NOT NULL,
	[HasEMC] [bit] NOT NULL,
	[EmcCoverLimit] [numeric](18, 2) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblQuoteCustomer_autp_QuoteCustomerID]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblQuoteCustomer_autp_QuoteCustomerID] ON [dbo].[penguin_tblquotecustomer_autp]
(
	[QuoteCustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblQuoteCustomer_autp_CustomerID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblQuoteCustomer_autp_CustomerID] ON [dbo].[penguin_tblquotecustomer_autp]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
