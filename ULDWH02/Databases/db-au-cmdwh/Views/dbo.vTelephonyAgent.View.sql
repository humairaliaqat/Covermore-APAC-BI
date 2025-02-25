USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vTelephonyAgent]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vTelephonyAgent]
as    
select 
    l.*
from
    usrLDAP l
where
    exists
    (
        select 
            null
        from
            verEmployee e 
        where
            e.UserName = l.UserName
    )
GO
