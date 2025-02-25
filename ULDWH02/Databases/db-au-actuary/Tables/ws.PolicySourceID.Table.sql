USE [db-au-actuary]
GO
/****** Object:  Table [ws].[PolicySourceID]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[PolicySourceID](
	[Country] [varchar](2) NOT NULL,
	[PolicyNo] [int] NOT NULL,
	[OldPolicyNo] [int] NULL,
	[AgencyCode] [varchar](7) NULL,
	[PolicyID] [int] NOT NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[GroupPolicy] [bit] NOT NULL,
	[Destination] [varchar](50) NULL,
	[Suburb] [varchar](30) NULL,
	[State] [varchar](20) NULL,
	[PostCode] [varchar](50) NULL,
	[AddressCountry] [varchar](20) NULL,
	[BIRowID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_PolicySourceID] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
