USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[snow_Incident]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[snow_Incident](
	[business_stc] [int] NULL,
	[calendar_stc] [int] NULL,
	[caller_id] [nvarchar](161) NULL,
	[caller_id.link] [nvarchar](120) NULL,
	[caller_id.value] [nvarchar](32) NULL,
	[caused_by] [nvarchar](161) NULL,
	[caused_by.link] [nvarchar](120) NULL,
	[caused_by.value] [nvarchar](32) NULL,
	[child_incidents] [int] NULL,
	[incident_state] [int] NULL,
	[notify] [int] NULL,
	[parent_incident] [nvarchar](161) NULL,
	[parent_incident.link] [nvarchar](120) NULL,
	[parent_incident.value] [nvarchar](32) NULL,
	[problem_id] [nvarchar](161) NULL,
	[problem_id.link] [nvarchar](120) NULL,
	[problem_id.value] [nvarchar](32) NULL,
	[reopen_count] [int] NULL,
	[resolved_at] [datetime] NULL,
	[resolved_by] [nvarchar](161) NULL,
	[resolved_by.link] [nvarchar](120) NULL,
	[resolved_by.value] [nvarchar](32) NULL,
	[severity] [int] NULL,
	[sys_id] [nvarchar](32) NULL,
	[u_area] [nvarchar](1024) NULL,
	[u_integration_method] [nvarchar](40) NULL,
	[u_major_incident] [bit] NULL,
	[u_major_incident_manager] [nvarchar](161) NULL,
	[u_major_incident_manager.link] [nvarchar](120) NULL,
	[u_major_incident_manager.value] [nvarchar](32) NULL,
	[u_pir] [nvarchar](max) NULL,
	[u_reference_number] [nvarchar](40) NULL,
	[u_release_number] [nvarchar](40) NULL,
	[u_release_state] [nvarchar](40) NULL,
	[u_resolver_group_list] [nvarchar](4000) NULL,
	[u_resolver_watch_list] [nvarchar](4000) NULL,
	[u_stakeholder_communications] [nvarchar](4000) NULL,
	[u_stakeholder_group_list] [nvarchar](4000) NULL,
	[u_stakeholder_watch_list] [nvarchar](4000) NULL,
	[u_type] [nvarchar](40) NULL,
	[u_url] [nvarchar](1024) NULL,
	[vendor] [nvarchar](161) NULL,
	[vendor.link] [nvarchar](120) NULL,
	[vendor.value] [nvarchar](32) NULL,
	[vendor_closed_at] [datetime] NULL,
	[vendor_opened_at] [datetime] NULL,
	[vendor_point_of_contact] [nvarchar](60) NULL,
	[vendor_resolved_at] [datetime] NULL,
	[vendor_ticket] [nvarchar](40) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
