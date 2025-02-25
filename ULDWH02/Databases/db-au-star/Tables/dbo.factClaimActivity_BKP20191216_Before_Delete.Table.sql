USE [db-au-star]
GO
/****** Object:  Table [dbo].[factClaimActivity_BKP20191216_Before_Delete]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factClaimActivity_BKP20191216_Before_Delete](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ActivityID] [varchar](50) NOT NULL,
	[Date_SK] [int] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[AreaSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[ClaimSK] [bigint] NOT NULL,
	[ClaimEventSK] [bigint] NOT NULL,
	[ClaimKey] [varchar](40) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[e5Reference] [int] NULL,
	[Activity] [nvarchar](100) NULL,
	[CompletionDate] [date] NULL,
	[CompletionUser] [nvarchar](100) NULL,
	[ActivityOutcome] [nvarchar](400) NULL,
	[CreateBatchID] [int] NULL
) ON [PRIMARY]
GO
