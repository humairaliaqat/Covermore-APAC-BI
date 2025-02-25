USE [db-au-actuary]
GO
/****** Object:  Table [dataout].[~CoverMoreComplaints]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dataout].[~CoverMoreComplaints](
	[GroupType] [nvarchar](100) NULL,
	[Reference] [int] NULL,
	[ClaimNumber] [int] NULL,
	[SuperGroupName] [nvarchar](25) NULL,
	[GroupName] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[Underwriter] [varchar](10) NULL,
	[CreationDate] [datetime] NOT NULL,
	[CompletionDate] [datetime] NULL,
	[Age] [int] NULL,
	[CreationUser] [nvarchar](445) NULL,
	[CurrentEstimate] [money] NOT NULL,
	[CurrentPaid] [money] NOT NULL,
	[ReasonForComplaint] [nvarchar](400) NOT NULL,
	[PolicyExclusion] [nvarchar](400) NOT NULL,
	[ComplaintDateLodged] [datetime] NULL,
	[ReasonForDispute] [nvarchar](400) NOT NULL,
	[ClaimDecision] [nvarchar](400) NULL,
	[StatusName] [nvarchar](100) NULL,
	[IDROutcome] [nvarchar](400) NULL,
	[EDRReferral] [varchar](3) NOT NULL,
	[e5WorkURL] [varchar](319) NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NULL,
	[PolicyStatus] [nvarchar](50) NULL,
	[AreaType] [varchar](25) NULL,
	[Area] [nvarchar](100) NULL,
	[AreaName] [nvarchar](100) NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[MultiDestination] [nvarchar](max) NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[ProductCode] [nvarchar](50) NULL,
	[ProductName] [nvarchar](50) NULL,
	[Excess] [money] NULL,
	[PolicyStart] [datetime] NULL,
	[PolicyEnd] [datetime] NULL,
	[DaysCovered] [int] NULL,
	[MaxDuration] [int] NULL,
	[PlanCode] [nvarchar](50) NULL,
	[PlanName] [nvarchar](50) NULL,
	[TripType] [nvarchar](50) NULL,
	[CancellationCover] [nvarchar](50) NULL,
	[TripCost] [nvarchar](50) NULL,
	[TripDuration] [int] NULL,
	[SellPrice] [money] NULL,
	[Commission] [money] NULL,
	[NetPrice] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
