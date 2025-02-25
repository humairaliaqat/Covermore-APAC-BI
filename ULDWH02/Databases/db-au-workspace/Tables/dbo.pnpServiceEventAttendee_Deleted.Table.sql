USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[pnpServiceEventAttendee_Deleted]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pnpServiceEventAttendee_Deleted](
	[BIRowID] [int] NOT NULL,
	[BookItemSK] [int] NULL,
	[ServiceEventSK] [int] NULL,
	[IndividualSK] [int] NULL,
	[UserSK] [int] NULL,
	[BookItemID] [int] NULL,
	[ServiceEventID] [varchar](50) NULL,
	[IndividualID] [varchar](50) NULL,
	[UserID] [varchar](50) NULL,
	[WorkerID] [varchar](50) NULL,
	[Name] [nvarchar](100) NULL,
	[Role] [nvarchar](50) NULL,
	[amemshow] [varchar](5) NULL,
	[CreatedDatetime] [datetime2](7) NULL,
	[UpdatedDatetime] [datetime2](7) NULL,
	[amemcode] [int] NULL,
	[kexempttypeid] [int] NULL,
	[DeletedDatetime] [datetime2](7) NULL
) ON [PRIMARY]
GO
