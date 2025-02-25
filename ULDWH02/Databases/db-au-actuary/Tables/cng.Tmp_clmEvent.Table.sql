USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_clmEvent]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_clmEvent](
	[CountryKey] [varchar](2) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[EventKey] [varchar](40) NOT NULL,
	[EventID] [int] NOT NULL,
	[ClaimNo] [int] NULL,
	[EMCID] [int] NULL,
	[PerilCode] [varchar](3) NULL,
	[PerilDesc] [nvarchar](65) NULL,
	[EventCountryCode] [varchar](3) NULL,
	[EventCountryName] [nvarchar](45) NULL,
	[EventDate] [datetime] NULL,
	[EventDesc] [nvarchar](100) NULL,
	[CreateDate] [datetime] NULL,
	[CreatedBy] [nvarchar](150) NULL,
	[CaseID] [varchar](15) NULL,
	[CatastropheCode] [varchar](3) NULL,
	[CatastropheShortDesc] [nvarchar](20) NULL,
	[CatastropheLongDesc] [nvarchar](60) NULL,
	[BIRowID] [int] NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[EventDateTimeUTC] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NULL,
	[OnlineClaimKey] [varchar](40) NULL,
	[OnlineClaimID] [int] NULL,
	[EventDateTime] [datetime] NULL,
	[EventCountry] [nvarchar](50) NULL,
	[EventLocation] [nvarchar](200) NULL,
	[PerilDescription] [varchar](65) NULL,
	[Detail] [nvarchar](max) NULL,
	[AdditionalDetail] [nvarchar](max) NULL,
	[IllnessPreviousOccurence] [bit] NULL,
	[IllnessOtherTraveller] [bit] NULL,
	[LossHasHCInsurance] [bit] NULL,
	[LossHCClaimable] [bit] NULL,
	[LossHCInsurer] [nvarchar](max) NULL,
	[LossConfirmInsurer] [bit] NULL,
	[LossWithTransportProvider] [bit] NULL,
	[LossConfirmProvider] [bit] NULL,
	[LossType] [varchar](max) NULL,
	[LossWithOthers] [bit] NULL,
	[LossOtherFirstName] [varchar](max) NULL,
	[LossOtherSurname] [varchar](max) NULL,
	[LossOtherTelephone] [varchar](max) NULL,
	[LossOtherEmail] [varchar](max) NULL,
	[LossAuthorityNotified] [bit] NULL,
	[LossAuthorityReference] [varchar](max) NULL,
	[LossAuthorityExplanation] [varchar](max) NULL,
	[CanxUnforseenReason] [varchar](max) NULL,
	[CanxOutOfControlReason] [varchar](max) NULL,
	[DelayPlannedDepartDate] [datetime] NULL,
	[DelayActualDepartDate] [datetime] NULL,
	[DelayDueToWeather] [bit] NULL,
	[LuggageFlightArriveDate] [datetime] NULL,
	[LuggageReceivedDate] [datetime] NULL,
	[LuggageCount] [int] NULL,
	[LuggageDelayedCount] [int] NULL,
	[LuggageReturned] [bit] NULL,
	[VehicleExcess] [money] NULL,
	[VehiclePerilType] [varchar](max) NULL,
	[VehicleOnUnsealedSurface] [bit] NULL,
	[VehicleCost] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmEvent_EventKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_clmEvent_EventKey] ON [cng].[Tmp_clmEvent]
(
	[EventKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmEvent_ClaimKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_clmEvent_ClaimKey] ON [cng].[Tmp_clmEvent]
(
	[ClaimKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
