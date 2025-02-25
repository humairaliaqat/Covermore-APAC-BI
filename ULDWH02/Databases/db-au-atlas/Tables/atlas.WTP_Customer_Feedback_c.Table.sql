USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[WTP_Customer_Feedback_c]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[WTP_Customer_Feedback_c](
	[Carebase_Case_Number_C] [varchar](100) NULL,
	[Case_C] [varchar](25) NULL,
	[WTP_Comment_C] [varchar](max) NULL,
	[Complaints_ID_C] [varchar](25) NULL,
	[Complaint_Management_C] [nvarchar](100) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CurrencyISOCode] [nvarchar](50) NULL,
	[WTP_Email_C] [varchar](100) NULL,
	[Name] [varchar](200) NULL,
	[Feedback_Category_C] [nvarchar](50) NULL,
	[WTP_Feedback_Date_C] [datetime] NULL,
	[Feedback_Method_C] [nvarchar](50) NULL,
	[Feedback_Outcome_Notes_C] [varchar](2000) NULL,
	[Feedback_Source_C] [nvarchar](50) NULL,
	[Feedback_Outcome_C] [nvarchar](50) NULL,
	[Feedback_Sub_type_C] [nvarchar](50) NULL,
	[Feedback_type_c] [nvarchar](50) NULL,
	[LastModifiedByid] [varchar](20) NULL,
	[OwnerId] [nvarchar](50) NULL,
	[Policy_No_C] [varchar](100) NULL,
	[WTP_Provider_name] [nvarchar](50) NULL,
	[RecordTypeId] [nvarchar](50) NULL,
	[Severity_c] [nvarchar](50) NULL,
	[id] [varchar](25) NOT NULL,
 CONSTRAINT [PK_WTP_Customer_Feedback_c] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [atlas].[WTP_Customer_Feedback_c]  WITH CHECK ADD  CONSTRAINT [FK_WTP_Customer_Feedback_c_User] FOREIGN KEY([id])
REFERENCES [atlas].[WTP_Customer_Feedback_c] ([id])
GO
ALTER TABLE [atlas].[WTP_Customer_Feedback_c] CHECK CONSTRAINT [FK_WTP_Customer_Feedback_c_User]
GO
