USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Case_Fee_Mtx_Excel]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Case_Fee_Mtx_Excel](
	[Underwriter_Group] [varchar](255) NULL,
	[Program_Name] [varchar](255) NULL,
	[Channel] [varchar](255) NULL,
	[Case_Type] [varchar](255) NULL,
	[Case_Fee] [numeric](10, 2) NULL,
	[GST] [int] NULL,
	[SUN_Client_Code] [varchar](20) NULL,
	[SUN Channel] [varchar](12) NULL,
	[Rec_Id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
