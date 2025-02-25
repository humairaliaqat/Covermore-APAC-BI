USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0148]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0148]
    @Country varchar(2),
    @CompanyGroup varchar(5) = 'All',
    @AgencyGroup varchar(50) = 'All',
    @AgencyCode varchar(25) = 'All',
    @CourseCode varchar(255),
    @LimitCourseByDate varchar(3) = 'No', 
    @EndDate date = null

as
begin

/***********************************************************************************************************/
--Name:           rptsp_rpt0148
--Author:         Leonardus Setyabudi
--Date Created:   20130531
--Description:    This stored procedure lists all active consultant and last training results.
--Parameters:     
--
--Change History:    
--                20130531 - LS - reuse rptsp_rpt0148, case 18474
--                20130612 - LS - Add Company Group parameter
--                20131001 - LS - case 19181, add end date parameter to limit consultant created before it
--                20160530 - PZ - Show consultants with any access level (filter commented)
/************************************************************************************************************/

--uncomment to debug
--declare 
--    @Country varchar(2),  
--    @CompanyGroup varchar(5),
--    @AgencyGroup varchar(3),
--    @AgencyCode varchar(25),
--    @CourseCode varchar(255),
--    @LimitCourseByDate varchar(3), 
--    @EndDate date
--select
--    @Country = 'AU',  
--    @CompanyGroup = 'All',
--    @AgencyGroup = 'All',
--    @AgencyCode = 'All',
--    @CourseCode = 'RF122012',
--    @LimitCourseByDate = 'No'

    set nocount on 

    select
        o.CountryKey,
        o.CompanyKey,
        o.BDMName,
        o.GroupName,
        o.SubGroupName,
        o.StateSalesArea,
        o.AlphaCode,
        o.OutletName,
        o.Branch,
        o.FSRType,
        u.UserKey,
        u.FirstName,
        u.LastName,
        u.FirstName + ' ' + u.LastName,
        u.AccessLevelName,
        u.Login,
        u.CreateDateTime UserCreateDate,
        u.LastLoggedin,
        ls.LastSellDate,
        u.Status,
        u.Email,
        u.AccreditationNumber,
        u.AccreditationDate,
        t.CourseCode,
        t.CourseName,
        t.CourseAgencyGroup,
        t.CourseCreateDate,
        t.CourseStartDate,
        t.CourseEndDate,
        t.ExamStartTime,
        t.ExamResult
    from
        penOutlet o
        inner join penUser u on 
            u.OutletKey = o.OutletKey
        outer apply
        (
            select
                max(IssueDate) LastSellDate
            from
                penPolicyTransSummary pt
            where
                pt.UserKey = u.UserKey and
                (
                    @LimitCourseByDate = 'No' or
                    pt.IssueDate < @EndDate
                )
        ) ls
        outer apply
        (
            select top 1
                t.CourseCode,
                t.CourseName,
                t.CourseAgencyGroup,
                t.CourseCreateDate,
                t.CourseStartDate,
                t.CourseEndDate,
                t.ExamStartTime,
                t.ExamResult
            from
                penTraining t
            where
                t.CourseCode = @CourseCode and
                t.UserKey = u.UserKey and
                (
                    @LimitCourseByDate = 'No' or
                    t.ExamStartTime < @EndDate
                )
            order by
                t.ExamFinishTime desc
            
        ) t
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
        u.UserStatus = 'Current' and
        u.Status = 'Active' and
        --u.AccessLevelName in ('User (accredited)', 'Administrator (accredited)') and
        (
            isnull(@CompanyGroup, 'All') = 'All' or
            o.CompanyKey = @CompanyGroup
        ) and
        (
            isnull(@AgencyGroup, 'All') = 'All' or
            o.GroupName = @AgencyGroup
        ) and
        (
            isnull(@AgencyCode, 'All') = 'All' or
            o.AlphaCode = @AgencyCode
        ) and
        u.FirstName not like 'webuser%' and
        u.FirstName not like 'ozgold%' and
        (
            @LimitCourseByDate = 'No' or
            u.CreateDateTime < @EndDate
        )
        
end 
GO
