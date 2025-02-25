USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_ExperianData]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_ExperianData](
	[PolicyKey] [varchar](900) NULL,
	[SuperGroup] [varchar](250) NULL,
	[IssueDate] [datetime] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[PrimaryDestination] [varchar](250) NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[isPrimary] [bit] NULL,
	[Title] [varchar](250) NULL,
	[FirstName] [varchar](250) NULL,
	[LastName] [varchar](250) NULL,
	[DOB] [datetime] NULL,
	[AddressLine1] [varchar](250) NULL,
	[AddressLine2] [varchar](250) NULL,
	[Postcode] [varchar](250) NULL,
	[Suburb] [varchar](250) NULL,
	[State] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[EmailAddress] [varchar](250) NULL,
	[PlanType] [varchar](250) NULL,
	[ProductClassification] [varchar](250) NULL,
	[PrimaryTraveller] [varchar](50) NULL,
	[NonPrimaryTraveller] [varchar](50) NULL,
	[PaymentType] [varchar](50) NULL,
	[CalendarYear] [varchar](50) NULL,
	[DPID] [varchar](100) NULL,
	[HIN] [varchar](100) NULL,
	[h_mosaic_type] [varchar](100) NULL,
	[h_mosaic_group] [varchar](100) NULL,
	[Length_of_Residence_Code] [varchar](100) NULL,
	[HIN_Head_Of_HouseHold_Age_Code] [varchar](100) NULL,
	[Children_At_Address_Child0_11] [varchar](100) NULL,
	[Children_At_Address_Child12_18] [varchar](100) NULL,
	[Relations_Type] [varchar](100) NULL,
	[LifeStage_Code] [varchar](100) NULL,
	[Household_Income_Code] [varchar](100) NULL,
	[Affluence_Code] [varchar](100) NULL,
	[AdultsAtAddress] [varchar](100) NULL,
	[Factors_dec_1] [varchar](100) NULL,
	[Factors_dec_2] [varchar](100) NULL,
	[Factors_dec_3] [varchar](100) NULL,
	[Factors_dec_4] [varchar](100) NULL,
	[Factors_dec_5] [varchar](100) NULL,
	[Risk_Insight] [varchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_rpt0760_PolicyKey]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_rpt0760_PolicyKey] ON [dbo].[tmp_ExperianData]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
