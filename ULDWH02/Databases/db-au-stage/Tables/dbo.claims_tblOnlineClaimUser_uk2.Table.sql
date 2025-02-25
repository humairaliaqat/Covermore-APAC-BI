USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_tblOnlineClaimUser_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_tblOnlineClaimUser_uk2](
	[UserId] [int] NOT NULL,
	[PolicyNumber] [varchar](25) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [date] NULL,
	[KLDOMAINID] [int] NOT NULL
) ON [PRIMARY]
GO
