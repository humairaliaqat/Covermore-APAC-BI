USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_dimConsultant]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[v_ic_dimConsultant]
as
select 
    dc.*,
    ltrim(rtrim(isnull(u.[ConsultantID], ''))) [ConsultantID]
from
    dimConsultant dc
    outer apply
    (
        select top 1 
            u.Login [ConsultantID]
        from
            [db-au-cmdwh].dbo.penUser u
        where
            u.UserKey = dc.ConsultantKey and
            u.UserStatus = 'Current'
    ) u

GO
