USE [db-au-actuary]
GO
/****** Object:  Table [dbo].[~claim_approvals_22_24]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[~claim_approvals_22_24](
	[CountryKey] [varchar](5) NULL,
	[ClaimKey] [varchar](40) NULL,
	[Date] [datetime] NULL,
	[User] [nvarchar](455) NULL,
	[Action] [nvarchar](100) NULL,
	[Status] [nvarchar](100) NULL,
	[Detail] [nvarchar](400) NULL
) ON [PRIMARY]
GO
