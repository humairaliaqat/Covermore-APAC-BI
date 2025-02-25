USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[maDemographics]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[maDemographics](
	[cbFirstName] [nvarchar](100) NULL,
	[cbSurname] [nvarchar](100) NULL,
	[cbSex] [nvarchar](1) NULL,
	[cbDOB] [datetime] NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[CaseNo] [nvarchar](15) NULL,
	[AdmDate] [nvarchar](max) NULL,
	[DscDate] [nvarchar](max) NULL,
	[LOS] [float] NULL,
	[LowerBound] [float] NULL,
	[UpperBound] [float] NULL,
	[SameDay] [float] NULL,
	[ALOS] [float] NULL,
	[PCCL] [int] NULL,
	[PCCLDesc] [varchar](12) NULL,
	[ECCSRaw] [float] NULL,
	[ECCSRounded] [float] NULL,
	[MDC] [int] NULL,
	[MDCDesc] [nvarchar](max) NULL,
	[DRG] [nvarchar](max) NULL,
	[DRGDesc] [nvarchar](max) NULL,
	[PrinDiag] [nvarchar](max) NULL,
	[PrinDiagDesc] [nvarchar](max) NULL,
	[PrinProc] [int] NULL,
	[PrinProcDesc] [nvarchar](max) NULL,
	[NationalEfficientPrice] [float] NULL,
	[ABF_NWAU] [float] NULL,
	[VIC_NWAU] [float] NULL,
	[ABF_TotalFund] [float] NULL,
	[VIC_TotalFund] [float] NULL,
	[ABF_BaseWeight] [float] NULL,
	[VIC_BaseWeight] [float] NULL,
	[ABF_GrossWeightedActivityUnit] [float] NULL,
	[VIC_GrossWeightedActivityUnit] [float] NULL,
	[Age] [int] NULL,
	[Gender] [nvarchar](max) NULL,
	[CareType] [nvarchar](max) NULL,
	[CareTypeDesc] [nvarchar](max) NULL,
	[IndigenousStatus] [nvarchar](max) NULL,
	[IndigenousStatusDesc] [nvarchar](max) NULL,
	[FundingSource] [nvarchar](max) NULL,
	[FundingSourceDesc] [nvarchar](max) NULL,
	[HoursOfMechanicalVentilation] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
