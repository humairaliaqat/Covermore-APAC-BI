USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[hloTicket]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[hloTicket](
	[BIRowID] [int] IDENTITY(0,1) NOT NULL,
	[Date_Of_Issue] [date] NULL,
	[Flight_Date] [date] NULL,
	[Ticket_Type] [varchar](50) NULL,
	[Turnaround_Country] [varchar](50) NULL,
	[Origin_Country] [varchar](50) NULL,
	[Duration] [int] NULL,
	[Agent_Name] [varchar](50) NULL,
	[Agent_State] [varchar](50) NULL,
	[Document_No] [varchar](50) NULL,
	[Adult_Child_Infant] [varchar](50) NULL,
	[Return_One_Way] [varchar](50) NULL,
	[Gross_Fare] [numeric](16, 2) NULL,
	[Net_Fare] [numeric](16, 2) NULL,
	[Carrier] [varchar](50) NULL,
	[YQ_Levy] [numeric](16, 2) NULL,
	[Airline_Name] [varchar](50) NULL,
	[Original_Document_No] [varchar](50) NULL,
	[Customer_ID] [varchar](50) NULL,
	[Source_File_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_hloTicket_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE UNIQUE CLUSTERED INDEX [idx_hloTicket_BIRowID] ON [dbo].[hloTicket]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_hloTicket_Document]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_hloTicket_Document] ON [dbo].[hloTicket]
(
	[Document_No] ASC
)
INCLUDE([Customer_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
