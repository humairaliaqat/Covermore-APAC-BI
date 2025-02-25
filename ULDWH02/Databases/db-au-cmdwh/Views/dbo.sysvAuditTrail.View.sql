USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[sysvAuditTrail]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[sysvAuditTrail] 
as
select
    ae.Event_ID,
    ae.Server_CUID, 
    ae.Object_CUID,
    User_Name,
    Start_Timestamp,
    Object_Type,
    Event_Type_Description,
    Detail_Text,
    Detail_Type_Description,
    ad.Detail_Type_ID
from
    [db-au-bobjaudit].dbo.AUDIT_EVENT ae
    inner join [db-au-bobjaudit].dbo.EVENT_TYPE et on
        et.Event_Type_ID = ae.Event_Type_ID /*and
        (
            Event_Type_Description like '%refresh%' or
            Event_Type_Description like '%saved%' or    
            Event_Type_Description like '%edited%' or
            Event_Type_Description like '%created%' or
            Event_Type_Description like '%modified%' or
            Event_Type_Description like '%viewing%'
        )*/
    inner join [db-au-bobjaudit].dbo.AUDIT_DETAIL ad on
        ad.Event_ID = ae.Event_ID and 
        ad.Server_CUID = ae.Server_CUID
    inner join [db-au-bobjaudit].dbo.DETAIL_TYPE dt on
        dt.Detail_Type_ID = ad.Detail_Type_ID /*and
        dt.Detail_Type_ID in (3, 8, 21, 22, 63, 68, 69, 43, 44, 91)*/
GO
