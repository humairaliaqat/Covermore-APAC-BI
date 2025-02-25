USE [db-au-stage]
GO
/****** Object:  Table [dbo].[text_hloTicket]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[text_hloTicket](
	[Airline Name] [varchar](50) NULL,
	[Type Description] [varchar](50) NULL,
	[Original Tkt Document No] [varchar](50) NULL,
	[Ticket has been Refunded] [varchar](50) NULL,
	[Adult Child Infant] [varchar](50) NULL,
	[Return One way] [varchar](50) NULL,
	[Date of Issue] [varchar](50) NULL,
	[Gross Fare] [varchar](50) NULL,
	[Net Fare] [varchar](50) NULL,
	[Carrier] [varchar](50) NULL,
	[PNR] [varchar](50) NULL,
	[Tkt Orig Country] [varchar](50) NULL,
	[Turnaround Country] [varchar](50) NULL,
	[Customer ID] [varchar](50) NULL,
	[Ci Agent Name] [varchar](50) NULL,
	[Ci State] [varchar](50) NULL,
	[Document] [varchar](50) NULL,
	[Orig Date of Issue] [varchar](50) NULL,
	[YQ Levy] [varchar](50) NULL,
	[Ticket Class Group] [varchar](50) NULL,
	[First Flight Date] [varchar](50) NULL,
	[Stat] [varchar](50) NULL,
	[Source_File_ID] [int] NULL,
	[Load_Date] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_text_hloTicket]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_text_hloTicket] ON [dbo].[text_hloTicket]
(
	[Source_File_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
