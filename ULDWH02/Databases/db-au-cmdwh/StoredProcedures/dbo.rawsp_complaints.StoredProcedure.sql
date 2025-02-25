USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_complaints]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_complaints]
    @AgencyGroup varchar(400),
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null
  
as
begin  

/****************************************************************************************************/
--  Name:          rawsp_complaints
--  Author:        Leonardus Setyabudi
--  Date Created:  20111024
--  Description:   This stored procedure extract e5 complaint data for given parameters
--  Parameters:    @AgencyGroup: e5 agency group; e.g. Auspost
--                 @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History:  20111024 - LS - Created
--					 20160830 - PZ - Include AHM (groupcode = 'AH') in Medibank (groupcode = 'MB') extract 
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @AgencyGroup varchar(400)
declare @DateRange varchar(30)
declare @StartDate date
declare @EndDate date
select 
    @Country = 'Auspost', 
    @AgencyGroup = 'Auspost',
    @DateRange = 'Yesterday'
*/

    set nocount on 
  
    declare @dataStartDate date
    declare @dataEndDate date

    /* get dates */
    if @DateRange = '_User Defined'
        select 
            @dataStartDate = @StartDate,
            @dataEndDate = @EndDate
    
    else
        select 
            @dataStartDate = StartDate, 
            @dataEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @DateRange


    select 
        w.WorkType [Work Type],
        w.Reference,
        wp.ComplaintDateLodged [Date Complaint Lodged],
        w.CreationDate [Creation Date],
        w.StatusName, 
        w.CompletionDate [Completion Date], 
        w.GroupType [Group],
        (
            select 
                Name 
            from 
                e5WorkItems wi
            where 
                wi.ID = wp.ComplaintsDepartment
        ) [Department Responsible],
        (
            select 
                Name 
            from 
                e5WorkItems wi
            where 
                wi.ID = wp.ComplaintType
        ) [Complaint Type],
        (
            select 
                Name 
            from 
                e5WorkItems wi
            where 
                wi.ID = wp.ComplaintFrom
        ) [Complaint From],
        wp.ComplaintsFirstName [First Name],
        wp.ComplaintsSurname [Surname],  
        wp.ComplaintsStreet [Street],
        wp.ComplaintsSuburb [Suburb],
        wp.ComplaintsState [State],
        wp.ComplaintsPostCode [Post Code],
        wp.ComplaintsLinkedClaimNo [Linked Claim No],
        wp.ComplaintsEMCNumber [EMC Number],
        (
            select 
                Name 
            from 
                e5WorkItems wi
            where 
                wi.ID = wp.ComplaintsPolicyType
        ) [Policy Type],  
        wp.ComplaintsPolicyNumber [Policy Number],
        wp.ComplaintsAlphaCode [Alpha Code],
        w.AssignedUser
    from 
        e5Work w
        inner join ve5WorkProperties wp on
            wp.Work_ID = w.Work_ID
        inner join e5WorkItems wi on 
            wi.ID = wp.AgencyGroup
    where 
        WorkType = 'Complaints' and
		wi.Name in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
        (
            (
                w.CreationDate >= @dataStartDate and 
                w.CreationDate <  dateadd(day, 1, @dataEndDate)
            ) or
            (
                w.CompletionDate >= @dataStartDate and 
                w.CompletionDate <  dateadd(day, 1, @dataEndDate)
            )
        )
  
end

GO
