USE [db-au-stage]
GO
/****** Object:  Table [dbo].[eFrontOfficeDW_DTC_Telstra_BankOfHoursDetail_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eFrontOfficeDW_DTC_Telstra_BankOfHoursDetail_audtc](
	[id] [int] NOT NULL,
	[trx_ctrl_num] [varchar](30) NOT NULL,
	[jobNumber] [nvarchar](50) NULL,
	[Company] [varchar](80) NULL,
	[serviceTypeDesc] [nvarchar](50) NULL,
	[RateMethod] [nchar](1) NULL,
	[transactionDate] [int] NULL,
	[QTY] [money] NULL,
	[nonchargable] [int] NULL,
	[Billable_Qty] [money] NULL,
	[activityCode] [nvarchar](50) NOT NULL,
	[activityDesc] [nvarchar](100) NOT NULL,
	[regionName] [nvarchar](50) NULL,
	[stateCode] [nvarchar](50) NULL,
	[stateName] [nvarchar](50) NULL,
	[GLApplyDate] [int] NULL,
	[Country] [varchar](50) NULL,
	[CountryRegion] [varchar](50) NULL,
	[RateID] [int] NULL,
	[Override_Rate_Value] [money] NULL,
	[BankHours] [money] NULL,
	[EquivalentEAPHoursMultiplier] [money] NULL,
	[Amount] [money] NULL,
	[Duplicated_Key] [tinyint] NULL,
	[Status_Booked] [tinyint] NULL,
	[Deleted_From_Source] [tinyint] NULL,
	[Deleted_Date] [smalldatetime] NULL,
	[Current_Line] [tinyint] NULL,
	[PolicyType] [varchar](30) NULL,
	[Insert_Date] [smalldatetime] NULL
) ON [PRIMARY]
GO
