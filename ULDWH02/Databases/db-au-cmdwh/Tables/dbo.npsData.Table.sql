USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[npsData]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[npsData](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[DomainCountry] [varchar](5) NOT NULL,
	[NPSCode] [nvarchar](100) NULL,
	[SuperGroup] [nvarchar](255) NULL,
	[Policy No] [nvarchar](50) NULL,
	[Claim No] [nvarchar](50) NULL,
	[MA Case No] [nvarchar](50) NULL,
	[S1a# Last policy purchased via] [nvarchar](max) NULL,
	[S2# Have you commenced your trip?] [nvarchar](max) NULL,
	[S3a# Regions spend most of your time during the trip?] [nvarchar](max) NULL,
	[S3b# Main reason for trip] [nvarchar](max) NULL,
	[S4# Need to make claim] [nvarchar](max) NULL,
	[Q1# Taking everything into account would you say that your Insur] [nvarchar](max) NULL,
	[Q2# Overall Score] [nvarchar](max) NULL,
	[Q2a#  Score reason] [nvarchar](max) NULL,
	[Q3# And how likely are you to recommend to family, friends and c] [nvarchar](max) NULL,
	[C1# Did travel insurance pay the claim?] [nvarchar](max) NULL,
	[C1a#  - To what extent would you say you understood the reason w] [nvarchar](max) NULL,
	[C2# Claim Satisfaction _ - Responsiveness to my queries and call] [nvarchar](max) NULL,
	[C2# Claim Satisfaction _ - Engagement of the claims staff with m] [nvarchar](max) NULL,
	[C2# Claim Satisfaction _ - The knowledge of the claims staff who] [nvarchar](max) NULL,
	[C2# Claim Satisfaction _ - The time it took for the claim to be] [nvarchar](max) NULL,
	[C2# Claim Satisfaction _ - The overall outcome of the claim] [nvarchar](max) NULL,
	[C3# Which of these would best describe the nature of your claim?] [nvarchar](max) NULL,
	[C3# Which of these would best describe the nature of your claim1] [nvarchar](max) NULL,
	[C4#  How long did it take for your claim to be settled/decision] [nvarchar](max) NULL,
	[C5# Claim comment] [nvarchar](max) NULL,
	[M1# You mentioned before that you needed to contact your travel] [nvarchar](max) NULL,
	[M1# You mentioned before that you needed to contact your travel1] [nvarchar](max) NULL,
	[M2# How satisfied were you with each of these aspects in the han] [nvarchar](max) NULL,
	[M2# How satisfied were you with each of these aspects in the ha1] [nvarchar](max) NULL,
	[M2# How satisfied were you with each of these aspects in the ha2] [nvarchar](max) NULL,
	[M3# Case comment] [nvarchar](max) NULL,
	[P1# They offer peace of mind] [nvarchar](max) NULL,
	[P1# They have a good reputation] [nvarchar](max) NULL,
	[P1# I am confident they would pay my claim if needed] [nvarchar](max) NULL,
	[P1# They offer problem free travel insurance] [nvarchar](max) NULL,
	[P1# They have good service] [nvarchar](max) NULL,
	[P1# They are available if I need them] [nvarchar](max) NULL,
	[P1# It was easy to buy] [nvarchar](max) NULL,
	[P1# It was easy to understand] [nvarchar](max) NULL,
	[P1# The cover has good inclusions] [nvarchar](max) NULL,
	[P1# They provide special cover if you need it] [nvarchar](max) NULL,
	[P1# They provide flexible cover] [nvarchar](max) NULL,
	[P1# It was good value for money] [nvarchar](max) NULL,
	[P1# The staff were knowledgeable and helpful] [nvarchar](max) NULL,
	[P3# Do you recall (@S4IN@) travel insurance offering the chance] [nvarchar](max) NULL,
	[P3a# How did the Global SIM influence the way you thought about] [nvarchar](max) NULL,
	[P3b# Overall how satisfied would you say you are with the Global] [nvarchar](max) NULL,
	[P3c# And how likely are you to recommend the Global SIM offer to] [nvarchar](max) NULL,
	[P3d# Which of these best describes your use of the Global SIM?] [nvarchar](max) NULL,
	[P3d# Which of these best describes your use of the Global SIM? -] [nvarchar](max) NULL,
	[Is there anything else about your experience with the Global SIM] [nvarchar](max) NULL,
	[P1# The claim process is easy] [nvarchar](max) NULL,
	[P1# Claims are handled in a timely fashion] [nvarchar](max) NULL,
	[P1# The cover was what I had anticipated] [nvarchar](max) NULL,
	[P1# The staff  are helpful] [nvarchar](max) NULL,
	[P1# The staff  are knowledgeable] [nvarchar](max) NULL,
	[P1# The staff  are empathetic] [nvarchar](max) NULL,
	[P1# The staff are available when I need them] [nvarchar](max) NULL,
	[P5# How did you lodge your claim or request for assistance?] [nvarchar](max) NULL,
	[P6# At what stage did you first lodge the claim or assistance re] [nvarchar](max) NULL,
	[P6# At what stage did you first lodge the claim or assistance r1] [nvarchar](max) NULL,
	[Z1# Please indicate your gender] [nvarchar](max) NULL,
	[Z2# Which of these best describe the household you live in?] [nvarchar](max) NULL,
	[Z3# Which of the following describes your current employment sit] [nvarchar](max) NULL,
	[Z4# In an average year, how many times would you take a trip whe] [nvarchar](max) NULL,
	[Classification] [nvarchar](max) NULL,
	[Topic] [nvarchar](max) NULL,
	[Sentiment] [nvarchar](max) NULL,
	[FileName] [varchar](50) NULL,
	[OverallScore] [int] NULL,
	[RecommendedScore] [int] NULL,
	[ClmSFScore_Response] [int] NULL,
	[ClmSFScore_Engagement] [int] NULL,
	[ClmSFScore_StaffKnowledge] [int] NULL,
	[ClmSFScore_Timing] [int] NULL,
	[ClmSFScore_Overall] [int] NULL,
	[GlobalSIMSFScore] [int] NULL,
	[GlobalSIMRecScore] [int] NULL,
	[ResponsiveSFScore] [int] NULL,
	[EngagementSFScore] [int] NULL,
	[OverallSFScore] [int] NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[ClmScore_NotApproved] [int] NULL,
	[M1# It appears you received assistance from (@BRANDCODE@) trave2] [nvarchar](max) NULL,
	[M2# Assistance Rating -  - I was kept informed on the progress o] [nvarchar](max) NULL,
	[M2# Assistance Rating -  - The staff understood my needs] [nvarchar](max) NULL,
	[M2# Assistance Rating -  - The response met my needs] [nvarchar](max) NULL,
	[M3# Are there any particular member(s) of the Assistance Team t1] [nvarchar](max) NULL,
	[C3# Claim Rating -  - I was kept informed of the process at each] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - The policy covered less] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - The excess I had to pay] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - The depreciation applie] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - I had to resend documen] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - I did not receive a cal] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - Communication from the ] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - I was unhappy with the ] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - Assurances were given b] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - I was expected to provi] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - The claims process took] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - The claims process was ] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - Something else (Please ] [nvarchar](max) NULL,
	[C3a# Reasons for Claim Dissatisfaction - Something else (Please1] [nvarchar](max) NULL,
	[C2# How did you lodge your claim? - Phone (1)] [nvarchar](max) NULL,
	[C2# How did you lodge your claim? - Online (2)] [nvarchar](max) NULL,
	[C2# How did you lodge your claim? - Email (3)] [nvarchar](max) NULL,
	[C2# How did you lodge your claim? - Through the travel agent (4)] [nvarchar](max) NULL,
	[C2# How did you lodge your claim? - Post/fax (5)] [nvarchar](max) NULL,
	[C2# How did you lodge your claim? - Unsure (6)] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_npsData_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_npsData_BIRowID] ON [dbo].[npsData]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_npsData_ClaimNo]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_npsData_ClaimNo] ON [dbo].[npsData]
(
	[Claim No] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_npsData_Date]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_npsData_Date] ON [dbo].[npsData]
(
	[UpdateDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_npsData_FileName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_npsData_FileName] ON [dbo].[npsData]
(
	[FileName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_npsData_NPSCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_npsData_NPSCode] ON [dbo].[npsData]
(
	[NPSCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_npsData_PolicyNo]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_npsData_PolicyNo] ON [dbo].[npsData]
(
	[Policy No] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[npsData] ADD  DEFAULT ('AU') FOR [DomainCountry]
GO
ALTER TABLE [dbo].[npsData] ADD  DEFAULT (getdate()) FOR [UpdateDateTime]
GO
