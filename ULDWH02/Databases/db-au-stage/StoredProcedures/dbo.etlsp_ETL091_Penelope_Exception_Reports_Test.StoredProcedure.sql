USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL091_Penelope_Exception_Reports_Test]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[etlsp_ETL091_Penelope_Exception_Reports_Test] 
-- =============================================
-- Author:        Vincent Lam
-- Create date: 2017-08-18
-- Description:
--              20180528 - LL - REQ84, amendment request to exception logic   
--                              a whole lot of refactoring (except on #17, not sure if it's still in use)
--              20190205 - LL - REQ745, exception 10 document name changes
--              20190211 - SD - Changed the calculations to filter admin error records correctly from "3. No Cart Item on an event" section, as requested in JIRA REQ-1050
--                            - Also removed 'Development@Work' and 'worklifeAssist' service, from "6. Event Time not Equal to Cart Items Total Time" and "26. Travel Clinician without travel customer carting" sections, as requested by JIRA REQ-1035
--                            - Also removed service 'On-Site Services employeeAssist', from "11. No First Session Document" section, as requested in JIRA REQ-1046
--              20190306 - LL - REQ-1125, 11. No First Session Document, change "site name", "resource type" & "reports to" to refer to primary event worker 
--              20190312 - LL - 
--                              remove exception 17, trauma process
--                              add event id when looking up for first event (partition by sfid order by eventtime, eventid), so many 
--                              REQ-1125
--                                  12. No Agreement Document on First employeeAssist event, change "site name", "resource type" & "reports to" to refer to primary event worker 
--                                  19. No employeeAssist associate dataform
--                              REQ-1152 remove from exception if the only show event is administration 9, 11, 12, 19, 25
--              20190320 - LL - REQ-1212 add new exception, multiple workers on an event
--              
-- =============================================
AS
BEGIN
    
    -- 1. No Default Funder on Individual
    -- person responsible: Service file created by
    truncate table [db-au-dtc].test.EctnNoFunderOnIndividual 
    
    insert into [db-au-dtc].test.EctnNoFunderOnIndividual 
    select 
        Service_File_ID,
        Individual_ID,
        First_Name,
        Last_Name,
        cast(Created_At as datetime) Created_At,
        Created_By,
        [State],
        Email,
        Manager
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                "Service_File_ID",
                "Individual_ID",
                "First_Name",
                "Last_Name",
                "Created_At",
                "Created_By",
                "State",
                "Email",
                "Manager"
            from 
                (
                    select 
                        sf.kprogprovid "Service_File_ID",
                        i.kindid "Individual_ID",
                        trim(i.indfirstname) "First_Name",
                        trim(i.indlastname) "Last_Name", 
                        sf.slogin "Created_At",
                        trim(sfcu.usfirstname) || '' '' || trim(sfcu.uslastname) "Created_By",
                        st.provstateshort "State",
                        sfcu.usemail "Email",
                        trim(sfcurt.usfirstname) || '' '' || trim(sfcurt.uslastname) "Manager",
                        row_number() over(partition by i.kindid order by sf.kprogprovid) rn
                    from 
                        ctprogprov sf 
                        inner join aicprogmem sfm on 
                            sfm.kprogprovid = sf.kprogprovid 
                        inner join aiccasemembers cm on 
                            cm.kcasemembersid = sfm.kcasemembersid 
                        left join irindividualsetup s on 
                            s.kindid = cm.kindid 
                        left join irindividual i on 
                            i.kindid = cm.kindid 
                        left join wruser sfcu on 
                            sfcu.usloginid = sf.sloginby 
                        left join wruser sfcurt on 
                            sfcurt.kuserid = sfcu.krepuserid 
                        left join luprovstate st on 
                            st.luprovstateid = sfcu.luusprovstateid 
                    where 
                        cm.cmemprimary = true 
                        and s.kfunderid is null 
                        and sf.slogin >= ''2017-07-02''
                ) a
            where 
                rn = 1
            '
        )

    -- 2. No Policy on a Service File
    -- person responsible: Service file created by
    truncate table [db-au-dtc].test.EctnNoPolicyOnServiceFile
    
    insert into [db-au-dtc].test.EctnNoPolicyOnServiceFile 
    select 
         Case_ID,
         Service_File_ID,
         [Service],
         [Group],
         [Status],
         First_Event_Type,
         First_Event_Status,
         SF_Primary_Worker,
         Site_Name,
         Resource_Type,
         SF_Created_By,
         [State],
         convert(datetime, SF_Created_At) SF_Created_At,
         Manager
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                sf.kcaseid "Case_ID",
                sf.kprogprovid "Service_File_ID",
                s.asername "Service",
                sfg.proggroupname "Group",
                sfs.progprovstatus "Status",
                e.activitytypename "First_Event_Type",
                e.actstatus "First_Event_Status",
                trim(sfpwu.usfirstname) || '' '' || trim(sfpwu.uslastname) "SF_Primary_Worker",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type", 
                trim(sfcu.usfirstname) || '' '' || trim(sfcu.uslastname) "SF_Created_By",
                st.provstateshort "State",
                sf.slogin "SF_Created_At",
                trim(sfcurt.usfirstname) || '' '' || trim(sfcurt.uslastname) "Manager"
            from 
                ctprogprov sf 
                left join btbillseq bs on 
                    bs.kprogprovid = sf.kprogprovid 
                left join aifpolicymem pm on 
                    pm.kpolicymemid = bs.kpolicymemid 
                left join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                left join saproggroup sfg on 
                    sfg.kproggroupid = cp.kproggroupid 
                left join ssprogprovstatus sfs on 
                    sfs.kprogprovstatusid = sf.kprogprovstatusid 
                left join pragser s on 
                    s.kagserid = cp.kagserid
                left join wrcworker sfpw on 
                    sfpw.kcworkerid = sf.kcworkeridprim 
                left join wruser sfpwu on 
                    sfpwu.kuserid = sfpw.kuserid 
                left join irbookitem bi on 
                    bi.kbookitemid = sfpwu.kbookitemid  
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp ue on 
                    ue.kuserid = sfpwu.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
                left join wruser sfcu on 
                    sfcu.usloginid = sf.sloginby 
                left join wruser sfcurt on 
                    sfcurt.kuserid = sfcu.krepuserid 
                left join luprovstate st on 
                    st.luprovstateid = sfcu.luusprovstateid 
                left join 
                (
                    select 
                        se2.kprogprovid,
                        setype.activitytypename,
                        sestatus.actstatus,
                        row_number() over(partition by se2.kprogprovid order by se1.actstime, se1.kactid) rn
                    from 
                        etactcase se2 
                        inner join etact se1 on 
                            se1.kactid = se2.kactid 
                        inner join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        inner join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                ) e on 
                    e.kprogprovid = sf.kprogprovid 
            where 
                (
                    not exists 
                    (
                        select 1
                        from 
                            aicprogmem sfm 
                            inner join aiccasemembers cm on 
                                cm.kcasemembersid = sfm.kcasemembersid 
                        where 
                            sfm.kprogprovid = sf.kprogprovid 
                            and cm.kindid = pm.kindid
                    )
                    or bs.kpolicymemid is null
                ) 
                and sf.slogin >= ''2017-07-02'' 
                and e.rn = 1 
                and not 
                (
                    sf.kprogprovstatusid = 2 
                    and not exists 
                    (
                        select 1 
                        from 
                            etactline ea 
                            inner join etactcase e on 
                                e.kactid = ea.kactid 
                        where 
                            e.kprogprovid = sf.kprogprovid
                    )
                )
            order by 
                sf.kprogprovid
        '
    )

    -- 3. No Cart item on an Event
    /*
    1    Booked
    2    Show
    3    Cancelled
    4    No Show
    5    Late Cn; Billed As NoShow
    6    Cancelled by Therapist
    7    Late Cnl; Remove Billing
    8    Re-scheduled
    */
    -- person responsible: Event primary worker
    -- for trauma, look at case level, e.g. case 88652 on SB2
    truncate table [db-au-dtc].test.EctnNoCartItemOnEvent
    insert into [db-au-dtc].test.EctnNoCartItemOnEvent 
    
    select 
        t.Funder,
        t.Service_File_ID,
        t.[Service],
        t.Event_ID,
        cast(t.Event_Created_At as datetime) Event_Created_At,
        cast(t.Event_Time as datetime) Event_Time,
        t.Event_Status,
        t.Event_Type,
        t.Event_Description,
        t.Event_Primary_Worker,
        t.[State],
        t.Reports_To,
        t.Site_Name,
        t.Resource_Type
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            with sff as 
            (
                select 
                    sf.kprogprovid,
                    f.funorg "Funder",
                    row_number() over(partition by sf.kprogprovid order by bs.billseq) rn 
                from 
                    btbillseq bs 
                    inner join aifpolicymem pm on 
                        pm.kpolicymemid = bs.kpolicymemid 
                    inner join frpolicy p on 
                        p.kpolicyid = pm.kpolicyid 
                    inner join ctprogprov sf on 
                        sf.kprogprovid = bs.kprogprovid 
                    inner join frfunder f on 
                        f.kfunderid = p.kfunderid
            ) 
            select 
                sff."Funder",
                se2.kprogprovid "Service_File_ID",
                s.asername "Service",
                se1.kactid "Event_ID",
                se1.slogin "Event_Created_At",
                se1.actstime "Event_Time",
                sestatus.actstatus "Event_Status",
                setype.activitytypename "Event_Type",
                se1.acttitle "Event_Description",
                trim(u.usfirstname) || '' '' || trim(u.uslastname) "Event_Primary_Worker",
                st.provstateshort "State",
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type"
            from 
                etact se1 
                inner join 
                (
                    select 
                        t1.*,
                        t2.kprogprovid,
                        t2.kactivitytypeid,
                        t2.kactstatusid,
                        t2.kcworkeridprimact,
                        row_number() over(partition by t2.kprogprovid order by t1.actstime, t1.kactid) rn 
                    from 
                        etactcase t2 
                        inner join etact t1 on 
                            t1.kactid = t2.kactid 
                ) se2 on 
                    se1.kactid = se2.kactid 
                inner join ssactcat sec on 
                    sec.kactcatid = se1.kactcatid 
                inner join saacttype setype on 
                    setype.kactivitytypeid = se2.kactivitytypeid 
                inner join ssactstatus sestatus on 
                    sestatus.kactstatusid = se2.kactstatusid 
                inner join ctprogprov sf on 
                    se2.kprogprovid = sf.kprogprovid
                inner join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                inner join pragser s on 
                    s.kagserid = cp.kagserid
                left join wrcworker pw on 
                    pw.kcworkerid = se2.kcworkeridprimact  
                left join wruser u on 
                    u.kuserid = pw.kuserid 
                left join luprovstate st on 
                    st.luprovstateid = u.luusprovstateid 
                left join irbookitem bi on 
                    bi.kbookitemid = u.kbookitemid  
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp ue on 
                    ue.kuserid = u.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
                left join wruser rt on 
                    rt.kuserid = u.krepuserid 
                left join etactline sea on 
                    sea.kactid = se1.kactid 
                left join sff on 
                    sff.kprogprovid = se2.kprogprovid 
            where 
                sea.kactid is null 
                and se2.kactstatusid in (2,4,5)    -- only Show, No Show, and Late Cn; Billed As NoShow
                and se1.actetime < current_timestamp -- only past events
                and sec.actcatname = ''Case''
                and not
                (
                    upper(se1.acttitle) like ''%AD%M%N%ERR%'' 
                    or upper(se1.acttitle) like ''%A%MIN%ERR%'' 
                    or upper(se1.acttitle) like ''%ERRO%''
                )

                and not 
                (
                    s.asername = ''traumaAssist - Individual'' 
                    and exists
                    (
                        select
                            1
                        from
                            ctprogprov rsf
                            inner join prcaseprog rcp on 
                                rcp.kcaseprogid = rsf.kcaseprogid 
                            inner join pragser rs on 
                                rs.kagserid = rcp.kagserid
                            inner join etactcase rse2 on
                                rse2.kprogprovid = rsf.kprogprovid
                            inner join etact rse1 on
                                rse2.kactid = rse1.kactid
                            inner join etactline rsea on 
                                rsea.kactid = rse1.kactid
                        where
                            rsf.kcaseid = sf.kcaseid and
                            rs.asername = ''traumaAssist - Case Management'' and
                            rse1.actstime::date = se1.actstime::date
                    )
                )

                and sf.slogin >= ''2017-07-02'' 
                and 
                (
                    sff.rn = 1 
                    or sff.rn is null
                )
            order by 
                se2.kprogprovid
            '
        ) t



    -- 4. Duplicate Cart item on an Event
    -- person responsible: Event primary worker
    truncate table [db-au-dtc].test.EctnDuplicateCartItemOnEvent

    insert into [db-au-dtc].test.EctnDuplicateCartItemOnEvent 
    select 
        Funder,
        Service_File_ID,
        [Service],
        Event_ID,
        cast(Event_Created_At as datetime) Event_Created_At,
        Event_Type,
        Event_Description,
        cast(Event_Time as datetime) Event_Time,
        Item_Name,
        [Count],
        Event_Primary_Worker,
        [State],
        Reports_To,
        Site_Name,
        Resource_Type
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            with sff as 
            (
                select 
                    sf.kprogprovid,
                    f.funorg "Funder",
                    row_number() over(partition by sf.kprogprovid order by bs.billseq) rn 
                from 
                    btbillseq bs 
                    inner join aifpolicymem pm on 
                        pm.kpolicymemid = bs.kpolicymemid 
                    inner join frpolicy p on 
                        p.kpolicyid = pm.kpolicyid 
                    inner join ctprogprov sf on 
                        sf.kprogprovid = bs.kprogprovid 
                    inner join frfunder f on 
                        f.kfunderid = p.kfunderid
            ) 
            select 
                sff."Funder",
                se2.kprogprovid "Service_File_ID",
                s.asername "Service",
                sea.kactid "Event_ID",
                se1.slogin "Event_Created_At",
                setype.activitytypename "Event_Type",
                se1.acttitle "Event_Description",
                se1.actstime "Event_Time",
                i.itemname "Item_Name",
                count(*) "Count",
                trim(u.usfirstname) || '' '' || trim(u.uslastname) "Event_Primary_Worker",
                st.provstateshort "State",
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type" 
            from 
                etactline sea 
                inner join nritem i on 
                    i.kitemid = sea.kitemid 
                inner join etactcase se2 on 
                    se2.kactid = sea.kactid 
                inner join etact se1 on 
                    se1.kactid = se2.kactid 
                inner join saacttype setype on 
                    setype.kactivitytypeid = se2.kactivitytypeid 
                inner join ctprogprov sf on 
                    se2.kprogprovid = sf.kprogprovid 
                inner join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                inner join pragser s on 
                    s.kagserid = cp.kagserid 
                left join wrcworker pw on 
                    pw.kcworkerid = se2.kcworkeridprimact 
                left join wruser u on 
                    u.kuserid = pw.kuserid 
                left join luprovstate st on 
                    st.luprovstateid = u.luusprovstateid 
                left join wruser rt on 
                    rt.kuserid = u.krepuserid 
                left join irbookitem bi on 
                    bi.kbookitemid = u.kbookitemid  
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp ue on 
                    ue.kuserid = u.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
                left join sff on 
                    sff.kprogprovid = se2.kprogprovid 
            where 
                sf.slogin >= ''2017-07-02'' 
                and s.asername <> ''MentalWellbeing@Work''
                and 
                (
                    sff.rn = 1 
                    or sff.rn is null
                ) 
                and not exists 
                (
                    select 
                        null 
                    from 
                        etactline 
                    where 
                        kactlineidret = sea.kactlineid
                ) 
                and sea.lineqty > 0 
            group by 
                sff."Funder",
                se2.kprogprovid,
                s.asername,
                sea.kactid,
                se1.slogin,
                setype.activitytypename,
                se1.acttitle,
                se1.actstime,
                i.itemname,
                trim(u.usfirstname) || '' '' || trim(u.uslastname),
                st.provstateshort,
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname),
                site.sitename,
                lue.luuser1exp4 
            having 
                count(*) >  1
            order by 
                se2.kprogprovid,
                sea.kactid
            '
        )


    -- 6. Event Time not Equal to Cart Items Total Time
    -- person responsible: Event primary worker
    truncate table [db-au-dtc].test.EctnEventTimeNotEqualToCartItemTotal
    
    insert into [db-au-dtc].test.EctnEventTimeNotEqualToCartItemTotal 
    select 
        Funder,
        Service_File_ID,
        [Service],
        Event_ID,
        cast(Event_Created_At as datetime) Event_Created_At,
        Event_Type,
        Event_Description,
        cast(Event_Time as datetime) Event_Time,
        Event_Status,
        Event_Time_In_Hours,
        Cart_Item_Total_Hours,
        Event_Primary_Worker,
        [State],
        Reports_To,
        Site_Name,
        Resource_Type
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            with sff as 
            (
                select 
                    sf.kprogprovid,
                    f.funorg "Funder",
                    row_number() over(partition by sf.kprogprovid order by bs.billseq) rn 
                from 
                    btbillseq bs 
                    inner join aifpolicymem pm on 
                        pm.kpolicymemid = bs.kpolicymemid 
                    inner join frpolicy p on 
                        p.kpolicyid = pm.kpolicyid 
                    inner join ctprogprov sf on 
                        sf.kprogprovid = bs.kprogprovid 
                    inner join frfunder f on 
                        f.kfunderid = p.kfunderid
            ) 
            select 
                sff."Funder",
                a.kprogprovid "Service_File_ID",
                a."Service",
                a.kactid "Event_ID",
                a."Event_Created_At",
                a."Event_Type",
                a."Event_Description",
                a."Event_Time",
                a."Event_Status",
                a."Event_Time_In_Hours"::numeric(10,2), 
                b."Cart_Item_Total_Hours"::numeric(10,2),
                a."Event_Primary_Worker",
                a."State",
                a."Reports_To",
                a."Site_Name",
                a."Resource_Type"
            from 
                (
                    select 
                        se2.kprogprovid, 
                        se1.kactid,
                        se1.slogin "Event_Created_At",
                        s.asername "Service",
                        setype.activitytypename "Event_Type",
                        se1.acttitle "Event_Description",
                        se1.actstime "Event_Time",
                        sestatus.actstatus "Event_Status",
                        trim(u.usfirstname) || '' '' || trim(u.uslastname) "Event_Primary_Worker",
                        st.provstateshort "State",
                        trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                        site.sitename "Site_Name",
                        lue.luuser1exp4 "Resource_Type",
                        extract(epoch from se1.actetime - se1.actstime)/3600.0 "Event_Time_In_Hours"
                    from 
                        etact se1 
                        inner join etactcase se2 on 
                            se1.kactid = se2.kactid 
                        inner join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        inner join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid
                        inner join ctprogprov sf on 
                            se2.kprogprovid = sf.kprogprovid
                        inner join prcaseprog cp on 
                            cp.kcaseprogid = sf.kcaseprogid 
                        inner join pragser s on 
                            s.kagserid = cp.kagserid 
                        left join wrcworker pw on 
                            pw.kcworkerid = se2.kcworkeridprimact 
                        left join wruser u on 
                            u.kuserid = pw.kuserid 
                        left join luprovstate st on 
                            st.luprovstateid = u.luusprovstateid 
                        left join wruser rt on 
                            rt.kuserid = u.krepuserid 
                        left join irbookitem bi on 
                            bi.kbookitemid = u.kbookitemid  
                        left join sasite site on 
                            site.ksiteid = bi.ksiteid 
                        left join wruser1exp ue on 
                            ue.kuserid = u.kuserid 
                        left join luuser1exp4 lue on 
                            lue.luuser1exp4id = ue.user1exp4 
                    where 
                        sf.slogin >= ''2017-07-02'' 
                ) a
                inner join 
                (
                    select 
                        sea.kactid, 
                        sum(sea.lineqty * uom.equiv) "Cart_Item_Total_Hours"
                    from 
                        etactline sea 
                        left join nruom uom on 
                            uom.kuomid = sea.kuomid 
                        left join nritem i on 
                            i.kitemid = sea.kitemid 
                    where 
                        uom.kuomsid = 1 and
                        not exists 
                        (
                            select 
                                null 
                            from 
                                etactline 
                            where 
                                kactlineidret = sea.kactlineid
                        ) 
                        and sea.lineqty > 0 
                    group by
                        sea.kactid
                ) b on 
                    a.kactid = b.kactid 
                left join sff on 
                    sff.kprogprovid = a.kprogprovid
            where 
                (
                    sff.rn = 1 
                    or sff.rn is null
                )
                and
                (
                    (
                        (
                            a."Service" like ''Risk@Work%'' or
                            a."Service" like ''Dev@Work%'' or
                            a."Service" like ''Development@Work%'' or
                            a."Service" like ''Change@Work'' or
                            a."Service" like ''Stress@Work%'' or
                            a."Service" like ''Dignity@Work%'' or
                            a."Service" like ''Conflict@Work%''
                        ) and
                        (
                            (a."Event_Time_In_Hours" <= 2 and b."Cart_Item_Total_Hours" >= 4) or
                            (a."Event_Time_In_Hours" <= 4 and b."Cart_Item_Total_Hours" >= 6) or
                            (a."Event_Time_In_Hours" <= 8 and b."Cart_Item_Total_Hours" >= 12)
                        )
                    )

                    or

                    (
                        not (
                            a."Service" like ''Risk@Work%'' or
                            a."Service" like ''Dev@Work%'' or
                            a."Service" like ''Development@Work%'' or
                            a."Service" like ''Change@Work'' or
                            a."Service" like ''Stress@Work%'' or
                            a."Service" like ''Dignity@Work%'' or
                            a."Service" like ''Conflict@Work%''
                        ) and
                        a."Service" <> ''MentalWellbeing@Work'' and
                        a."Event_Type" <> ''Onsite'' and
                        a."Event_Time_In_Hours" <> b."Cart_Item_Total_Hours" 
                    )

                )
                and
                a."Service" not in (''Development@Work'', ''worklifeAssist'')
                and
                a."Service" not like ''Dev@Work%''
            order by 
                a.kprogprovid, 
                a.kactid
            '
        )

    -- 7. Cart items do not match the 'standard hours' contracted for
    -- person responsible: Event primary worker
    truncate table [db-au-dtc].test.EctnCartItemOverThreshold
    
    insert into [db-au-dtc].test.EctnCartItemOverThreshold
    select 
        Service_File_ID,
        SF_Primary_Worker,
        SF_PW_Reports_To,
        [Service],
        Event_Type,
        Event_Status,
        Event_Description,
        convert(datetime, Event_Time) Event_Time,
        Item_Name,
        Quantity,
        Event_Primary_Worker,
        [State],
        Reports_To,
        Site_Name,
        Resource_Type,
        Event_ID
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                sf.kprogprovid "Service_File_ID",
                trim(sfpwu.usfirstname) || '' '' || trim(sfpwu.uslastname) "SF_Primary_Worker",
                trim(sfpwrt.usfirstname) || '' '' || trim(sfpwrt.uslastname) "SF_PW_Reports_To",
                s.asername "Service",
                setype.activitytypename "Event_Type",
                sestatus.actstatus "Event_Status",
                se1.acttitle "Event_Description",
                se1.actstime "Event_Time",
                ci.itemname "Item_Name",
                ci.lineqty "Quantity",
                trim(epwu.usfirstname) || '' '' || trim(epwu.uslastname) "Event_Primary_Worker",
                st.provstateshort "State",
                trim(epwrt.usfirstname) || '' '' || trim(epwrt.uslastname) "Reports_To",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type",
                se2.kactid "Event_ID"
            from 
                etactline ci 
                inner join nritem i on 
                    i.kitemid = ci.kitemid 
                inner join etactcase se2 on 
                    se2.kactid = ci.kactid 
                inner join etact se1 on 
                    se1.kactid = se2.kactid 
                left join saacttype setype on 
                    setype.kactivitytypeid = se2.kactivitytypeid 
                left join ssactstatus sestatus on 
                    sestatus.kactstatusid = se2.kactstatusid 
                inner join ctprogprov sf on 
                    sf.kprogprovid = se2.kprogprovid 
                inner join wrcworker sfpw on 
                    sfpw.kcworkerid = sf.kcworkeridprim 
                inner join wruser sfpwu on 
                    sfpwu.kuserid = sfpw.kuserid 
                inner join wruser sfpwrt on 
                    sfpwrt.kuserid = sfpwu.krepuserid 
                inner join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                inner join pragser s on 
                    s.kagserid = cp.kagserid 
                left join wrcworker epw on 
                    epw.kcworkerid = se2.kcworkeridprimact 
                left join wruser epwu on 
                    epwu.kuserid = epw.kuserid 
                left join luprovstate st on 
                    st.luprovstateid = epwu.luusprovstateid 
                left join wruser epwrt on 
                    epwrt.kuserid = epwu.krepuserid 
                left join irbookitem bi on 
                    bi.kbookitemid = epwu.kbookitemid 
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp epwue on 
                    epwue.kuserid = epwu.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = epwue.user1exp4
            where 
                (
                    ci.lineqty > 1.5 
                    and s.asername in 
                    (
                        ''employeeAssist'', 
                        ''managerAssist'',
                        ''legalAssist'',
                        ''Nutrition@DTC'',
                        ''moneyAssist'',
                        ''DFV Support'',
                        ''DFV Support - managerAssist''
                    )
                )
                or 
                (
                    ci.lineqty > 1.5 
                    and s.asername in (''Psychological Counselling'') 
                    and i.itemnameshort not in (''ONSITE'',''TRAVCLIN'',''CONSUL'')
                )
                or 
                (
                    ci.lineqty > 10 
                    and s.asername in (''Psychological Counselling'') 
                    and i.itemnameshort in (''ONSITE'',''TRAVCLIN'',''CONSUL'')
                )
                or 
                (
                    ci.lineqty > 10 
                    and s.asername not in 
                    (
                        ''employeeAssist'', 
                        ''managerAssist'', 
                        ''legalAssist'', 
                        ''Nutrition@DTC'', 
                        ''moneyAssist'', 
                        ''DFV Support'', 
                        ''DFV Support - managerAssist'', 
                        ''On-site Services''
                    )
                )
                or 
                (
                    ci.lineqty > 16
                    and s.asername in (''On-site Services'')
                )
            '
        )


    -- 8. Event with Status Booked in the Past
    -- person responsible: Event primary worker
    truncate table [db-au-dtc].test.EctnBookedEventInThePast

    insert into [db-au-dtc].test.EctnBookedEventInThePast 
    select 
        Funder,
        First_Name,
        Last_Name,
        Service_File_ID,
        [Service],
        Event_ID,
        cast(Event_Created_At as datetime) Event_Created_At,
        Event_Type,
        Event_Description,
        cast(Event_Time as datetime) Event_Time,
        Event_Status,
        Event_Primary_Worker,
        [State],
        Reports_To,
        Site_Name,
        Resource_Type
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            with sff as 
            (
                select 
                    sf.kprogprovid,
                    f.funorg "Funder",
                    i.indfirstname "First_Name",
                    i.indlastname "Last_Name",
                    row_number() over(partition by sf.kprogprovid order by bs.billseq) rn 
                from 
                    btbillseq bs 
                    inner join aifpolicymem pm on 
                        pm.kpolicymemid = bs.kpolicymemid 
                    inner join irindividual i on 
                        i.kindid = pm.kindid 
                    inner join frpolicy p on 
                        p.kpolicyid = pm.kpolicyid 
                    inner join ctprogprov sf on 
                        sf.kprogprovid = bs.kprogprovid 
                    inner join frfunder f on 
                        f.kfunderid = p.kfunderid
            ) 
            select 
                sff."Funder",
                sff."First_Name",
                sff."Last_Name",
                se2.kprogprovid "Service_File_ID", 
                s.asername "Service",
                se1.kactid "Event_ID", 
                se1.slogin "Event_Created_At",
                setype.activitytypename "Event_Type",
                se1.acttitle "Event_Description",
                se1.actstime "Event_Time", 
                sestatus.actstatus "Event_Status",
                trim(u.usfirstname) || '' '' || trim(u.uslastname) "Event_Primary_Worker",
                st.provstateshort "State",
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type"
            from 
                etact se1 
                inner join etactcase se2 on 
                    se1.kactid = se2.kactid 
                inner join saacttype setype on 
                    setype.kactivitytypeid = se2.kactivitytypeid 
                inner join ssactstatus sestatus on 
                    sestatus.kactstatusid = se2.kactstatusid 
                inner join ctprogprov sf on 
                    se2.kprogprovid = sf.kprogprovid
                inner join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                inner join pragser s on 
                    s.kagserid = cp.kagserid
                left join wrcworker pw on 
                    pw.kcworkerid = se2.kcworkeridprimact 
                left join wruser u on 
                    u.kuserid = pw.kuserid 
                left join luprovstate st on 
                    st.luprovstateid = u.luusprovstateid 
                left join wruser rt on 
                    rt.kuserid = u.krepuserid 
                left join irbookitem bi on 
                    bi.kbookitemid = u.kbookitemid  
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp ue on 
                    ue.kuserid = u.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
                left join sff on 
                    sff.kprogprovid = se2.kprogprovid 
            where 
                se2.kactstatusid = 1 
                and se1.actetime < current_timestamp 
                and sf.slogin >= ''2017-07-02'' 
                and sff.rn = 1 
            order by 
                se2.kprogprovid
            '
        )

    -- 9. No Presenting Issue
    -- person responsible: First event primary worker
    truncate table [db-au-dtc].test.EctnNoPresentingIssue

    insert into [db-au-dtc].test.EctnNoPresentingIssue 
    select 
         Service_File_ID,
         [Service],
         Funder,
         First_Event_Type,
         cast(First_Event_Date as datetime) First_Event_Date,
         Event_Primary_Worker,
         [State],
         convert(date, Event_Created) Event_Created,
         SF_Primary_Worker,
         Site_Name,
         Resource_Type, 
         Email, 
         Reports_To
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                sf.kprogprovid "Service_File_ID",
                s.asername "Service",
                f.funorg "Funder",
                e.activitytypename "First_Event_Type",
                e.actstime "First_Event_Date",
                e."Event_Primary_Worker",
                e."State",
                e.slogin "Event_Created",
                trim(u.usfirstname) || '' '' || trim(u.uslastname) "SF_Primary_Worker",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type",
                u.usemail "Email",
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To"
            from 
                ctprogprov sf 
                left join aicprogmem sfm on 
                    sfm.kprogmemid = sf.kprogmemidpres
                left join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                left join pragser s on 
                    s.kagserid = cp.kagserid
                left join wrcworker pw on 
                    pw.kcworkerid = sf.kcworkeridprim 
                left join wruser u on 
                    u.kuserid = pw.kuserid 
                left join wruser rt on 
                    rt.kuserid = u.krepuserid 
                left join irbookitem bi on 
                    bi.kbookitemid = u.kbookitemid  
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp ue on 
                    ue.kuserid = u.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
                inner join 
                (
                    select 
                        se2.kprogprovid,
                        setype.activitytypename,
                        se1.actstime,
                        se1.slogin,
                        trim(u.usfirstname) || '' '' || trim(u.uslastname) "Event_Primary_Worker",
                        st.provstateshort "State",
                        row_number() over(partition by se2.kprogprovid order by se1.actstime, se1.kactid) rn
                    from 
                        etactcase se2 
                        inner join etact se1 on 
                            se1.kactid = se2.kactid 
                        inner join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        inner join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                        left join wrcworker pw on 
                            pw.kcworkerid = se2.kcworkeridprimact 
                        left join wruser u on 
                            u.kuserid = pw.kuserid 
                        left join luprovstate st on 
                            st.luprovstateid = u.luusprovstateid 
                    where 
                        sestatus.actstatus = ''Show''
                ) e on 
                    e.kprogprovid = sf.kprogprovid 
                left join aiccasemembers cm on 
                    cm.kcaseid = sf.kcaseid and cm.cmemprimary = true 
                left join irindividualsetup indsetup on 
                    indsetup.kindid = cm.kindid
                left join frfunder f on 
                    f.kfunderid = indsetup.kfunderid 
            where 
                e.actstime < (current_date - interval ''1 day'')::date 
                and sfm.lupresissueid1 is null 
                and sfm.lupresissueid2 is null 
                and sfm.lupresissueid3 is null 
                and s.asername ~* ''.*(employeeassist|moneyassist|legalassist|nutrition|psychological counselling).*'' 
                and e.rn = 1 
                and e.actstime < current_timestamp 
                and sf.kcworkeridprim <> 1847 
                and sf.slogin >= ''2017-07-02'' 
                and exists
                (
                    select 
                        1
                    from 
                        etactcase se2 
                        inner join etact se1 on 
                            se1.kactid = se2.kactid 
                        inner join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        inner join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                    where
                        se2.kprogprovid = sf.kprogprovid and
                        sestatus.actstatus = ''Show'' and
                        setype.activitytypename <> ''Administration''
                ) 

            order by 
                sf.kprogprovid
            '
        )

    -- 10. CSO (KPI) Document Not Completed
    -- person responsible: Service file created by
    truncate table [db-au-dtc].test.EctnCSODocumentNotCompleted

    insert into [db-au-dtc].test.EctnCSODocumentNotCompleted 
    select 
         Service_File_ID,
         [Service],
         SF_Primary_Worker,
         Site_Name,
         Resource_Type, 
         Reports_To,
         SF_Created_By,
         [State],
         convert(datetime, SF_Created_At) SF_Created_At
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                sf.kprogprovid "Service_File_ID",
                s.asername "Service",
                trim(u.usfirstname) || '' '' || trim(u.uslastname) "SF_Primary_Worker",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type", 
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                trim(cu.usfirstname) || '' '' || trim(cu.uslastname) "SF_Created_By",
                st.provstateshort "State",
                sf.slogin "SF_Created_At"
            from 
                ctprogprov sf 
                left join dtcomdoc cd on 
                    cd.kprogprovid = sf.kprogprovid 
                    and 
                    (
                        cd.cdoctitle = ''[CSO] EAP Intake Document'' or
                        cd.cdoctitle = ''[CSO] EAP Client Intake Document''
                    )
                left join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                left join pragser s on 
                    s.kagserid = cp.kagserid
                left join wrcworker pw on 
                    pw.kcworkerid = sf.kcworkeridprim 
                left join wruser u on 
                    u.kuserid = pw.kuserid 
                left join irbookitem bi on 
                    bi.kbookitemid = u.kbookitemid  
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp ue on 
                    ue.kuserid = u.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
                left join wruser cu on 
                    cu.usloginid = sf.sloginby 
                left join wruser rt on 
                    rt.kuserid = cu.krepuserid 
                left join luprovstate st on 
                    st.luprovstateid = cu.luusprovstateid 
            where 
                sf.slogin >= ''2017-07-02'' 
                and cd.kcomdocid is null 
                and s.asername ~* ''.*(employeeassist|psychological counselling).*'' 
                and exists 
                (
                    select 1 
                    from 
                        etactcase 
                    where 
                        kprogprovid = sf.kprogprovid
                )    -- exclude files with no events 
                and not 
                (
                    sf.kprogprovstatusid = 2 
                    and not exists 
                    (
                        select 1 
                        from 
                            etactline ea 
                            inner join etactcase e on 
                                e.kactid = ea.kactid 
                        where e.kprogprovid = sf.kprogprovid
                    )
                )    -- exclude closed file with no cart items 
                and not exists 
                (
                    select null 
                    from 
                        (
                            select 
                                t2.kprogprovid, 
                                t2.kactivitytypeid,    -- 32 Online    35 After Hours Support
                                ue.user1exp4,    -- 14 Associate 
                                row_number() over(partition by t2.kprogprovid order by t1.actstime, t1.kactid) rn 
                            from 
                                etactcase t2 
                                inner join etact t1 on 
                                    t1.kactid = t2.kactid 
                                left join wrcworker pw on 
                                    pw.kcworkerid = kcworkeridprimact 
                                left join wruser1exp ue on 
                                    ue.kuserid = pw.kuserid 
                        ) a 
                    where 
                        kprogprovid = sf.kprogprovid
                        and rn = 1 
                        and 
                        (
                            kactivitytypeid in (32, 35) 
                            or user1exp4 = 14
                        )
                )    -- exclude service files where the first event type is after hours and/or online and exclude all service files where the first event is with an associate
            order by 
                sf.kprogprovid
            '
        )

    -- 11. No First Session Document
    /*
    document title on the FIRST service event is called 
        [Clinical] EAP 1st Session (Long), OR 
        [Clinical] EAP 1st Session (Short)
    */    
    -- person responsible: First event primary worker
    truncate table [db-au-dtc].test.EctnNoFirstSessionDocument

    insert into [db-au-dtc].test.EctnNoFirstSessionDocument 
    select 
         Service_file_ID,
         [Service],
         First_Event_ID,
         Event_Type,
         Event_Description,
         cast(Event_Time as datetime) Event_Time,
         Event_Status,
         SF_Primary_Worker,
         Site_Name,
         Resource_Type,
         Reports_To,
         Event_Primary_Worker,
         [State]
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                x.kprogprovid "Service_file_ID",
                x.asername "Service",
                x.kactid "First_Event_ID",
                x."Event_Type",
                x."Event_Description",
                x."Event_Time",
                x."Event_Status",
                x."SF_Primary_Worker",
                x."Site_Name",
                x."Resource_Type",
                x."Reports_To",
                x."Event_Primary_Worker",
                x."State"
            from 
                (
                    select 
                        se2.kprogprovid,
                        s.asername,
                        se1.kactid,
                        setype.activitytypename "Event_Type",
                        se1.acttitle "Event_Description",
                        se1.actstime "Event_Time", 
                        sestatus.actstatus "Event_Status",
                        trim(u.usfirstname) || '' '' || trim(u.uslastname) "SF_Primary_Worker",
                        site.sitename "Site_Name",
                        lue.luuser1exp4 "Resource_Type",
                        trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                        trim(epwu.usfirstname) || '' '' || trim(epwu.uslastname) "Event_Primary_Worker",
                        st.provstateshort "State",
                        se2.kactstatusid,
                        row_number() over(partition by se2.kprogprovid order by se1.actstime, se1.kactid) rn
                    from 
                        etact se1
                        inner join etactcase se2 on 
                            se1.kactid = se2.kactid
                        inner join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                        left join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        left join ctprogprov sf on 
                            sf.kprogprovid = se2.kprogprovid 
                        left join prcaseprog cp on 
                            cp.kcaseprogid = sf.kcaseprogid 
                        left join pragser s on 
                            s.kagserid = cp.kagserid
                        left join wrcworker pw on 
                            pw.kcworkerid = sf.kcworkeridprim 
                        left join wruser u on 
                            u.kuserid = pw.kuserid 
                        left join wrcworker epw on 
                            epw.kcworkerid = se2.kcworkeridprimact 
                        left join wruser epwu on 
                            epwu.kuserid = epw.kuserid 
                        left join wruser rt on 
                            rt.kuserid = epwu.krepuserid 
                        left join luprovstate st on 
                            st.luprovstateid = epwu.luusprovstateid 
                        left join irbookitem bi on 
                            bi.kbookitemid = epwu.kbookitemid  
                        left join sasite site on 
                            site.ksiteid = bi.ksiteid 
                        left join wruser1exp ue on 
                            ue.kuserid = epwu.kuserid 
                        left join luuser1exp4 lue on 
                            lue.luuser1exp4id = ue.user1exp4 
                    where 
                        sestatus.actstatus = ''Show''
                        and s.asername ~* ''.*(employeeassist|psychological counselling).*'' 
                        and sf.slogin >= ''2017-07-02'' 
                        and lue.luuser1exp4 <> ''Associate''
                ) x 
            where 
                rn = 1 -- First event
                and x.asername <> ''On-Site Services employeeAssist''
                and x."Event_Type" not in (''After Hours Support'', ''Online'')
                and not exists 
                (
                    select
                        1
                    from
                        dtcomdoc cd
                    where
                        cd.kprogprovid = x.kprogprovid and 
                        cd.cdoctitle in (''[Clinical] EAP 1st Session (Long)'', ''[Clinical] EAP 1st Session (Short)'')
                )
                and /*ISA is not the only event*/
                (
                    not exists
                    (
                        select
                            1
                        from
                            etact rse
                            inner join etactcase rse2 on 
                                rse.kactid = rse2.kactid
                        where
                            rse.acttitle = ''ISA Establishment Fee'' and
                            rse2.kprogprovid = x.kprogprovid
                    ) 
                    or exists
                    (
                        select
                            1
                        from
                            etact rse
                            inner join etactcase rse2 on 
                                rse.kactid = rse2.kactid
                        where
                            rse.acttitle <> ''ISA Establishment Fee'' and
                            rse2.kprogprovid = x.kprogprovid
                    )
                )

                and exists
                (
                    select 
                        1
                    from 
                        etactcase se2 
                        inner join etact se1 on 
                            se1.kactid = se2.kactid 
                        inner join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        inner join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                    where
                        se2.kprogprovid = x.kprogprovid and
                        sestatus.actstatus = ''Show'' and
                        setype.activitytypename <> ''Administration''
                ) 

            order by 
                x.kprogprovid
            '
        )

    -- 12. No Agreement Document on First employeeAssist event
    /*
    is there an event? 
        if so does the document exist in the service file?
            [DTC] Agreement to Undertake Support & Privacy Notice 
        If service type is on-site Services- employeeAssist look for the document: 
            [On-site] Agreement to Undertake Support & Privacy Notice
    */
    -- person responsible: First event primary worker
    truncate table [db-au-dtc].test.EctnNoAgreementDocumentOnFirstEAEvent

    insert into [db-au-dtc].test.EctnNoAgreementDocumentOnFirstEAEvent 
    select 
        Service_file_ID,
        [Service],
        Funder,
        First_Event_ID,
        Event_Type,
        Event_Description,
        cast(Event_Time as datetime) Event_Time,
        Event_Status,
        convert(datetime, Event_Created) Event_Created,
        SF_Primary_Worker,
        Site_Name,
        Resource_Type,
        Reports_To,
        Event_Primary_Worker,
        [State],
        Email,
        Event_PW_Reports_To
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                x.kprogprovid "Service_file_ID",
                x.asername "Service",
                x."Funder",
                x.kactid "First_Event_ID",
                x."Event_Type",
                x."Event_Description",
                x."Event_Time",
                x."Event_Status",
                x."Event_Created",
                x."SF_Primary_Worker",
                x."Site_Name",
                x."Resource_Type",
                x."Reports_To",
                x."Event_Primary_Worker",
                x."State",
                x."Email",
                x."Event_PW_Reports_To"
            from 
                (
                    select 
                        se2.kprogprovid,
                        f.funorg "Funder",
                        s.asername,
                        se1.kactid,
                        setype.activitytypename "Event_Type",
                        se1.acttitle "Event_Description",
                        se1.actstime "Event_Time", 
                        sestatus.actstatus "Event_Status",
                        se1.slogin "Event_Created",
                        trim(u.usfirstname) || '' '' || trim(u.uslastname) "SF_Primary_Worker",
                        site.sitename "Site_Name",
                        lue.luuser1exp4 "Resource_Type",
                        trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                        trim(epwu.usfirstname) || '' '' || trim(epwu.uslastname) "Event_Primary_Worker",
                        st.provstateshort "State",
                        epwu.usemail "Email",
                        trim(epwrt.usfirstname) || '' '' || trim(epwrt.uslastname) "Event_PW_Reports_To",
                        se2.kactstatusid,
                        row_number() over(partition by se2.kprogprovid order by se1.actstime, se1.kactid) rn
                    from 
                        etact se1
                        inner join etactcase se2 on 
                            se1.kactid = se2.kactid
                        left join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        left join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                        left join ctprogprov sf on 
                            sf.kprogprovid = se2.kprogprovid 
                        left join prcaseprog cp on 
                            cp.kcaseprogid = sf.kcaseprogid 
                        left join pragser s on 
                            s.kagserid = cp.kagserid
                        left join wrcworker pw on 
                            pw.kcworkerid = sf.kcworkeridprim 
                        left join wruser u on 
                            u.kuserid = pw.kuserid 
                        left join wrcworker epw on 
                            epw.kcworkerid = se2.kcworkeridprimact 
                        left join wruser epwu on 
                            epwu.kuserid = epw.kuserid 
                        left join wruser rt on 
                            rt.kuserid = epwu.krepuserid 
                        left join luprovstate st on 
                            st.luprovstateid = epwu.luusprovstateid 
                        left join aiccasemembers cm on 
                            cm.kcaseid = sf.kcaseid and cm.cmemprimary = true 
                        left join irindividualsetup indsetup on 
                            indsetup.kindid = cm.kindid
                        left join frfunder f on 
                            f.kfunderid = indsetup.kfunderid 
                        left join wruser epwrt on 
                            epwrt.kuserid = epwu.krepuserid 
                        left join irbookitem bi on 
                            bi.kbookitemid = epwu.kbookitemid  
                        left join sasite site on 
                            site.ksiteid = bi.ksiteid 
                        left join wruser1exp ue on 
                            ue.kuserid = epwu.kuserid 
                        left join luuser1exp4 lue on 
                            lue.luuser1exp4id = ue.user1exp4 
                    where 
                        sestatus.actstatus = ''Show''
                        and se1.actstime < (current_date - interval ''1 day'')::date 
                        and s.asername ~* ''.*(employeeassist|psychological counselling).*'' 
                        and s.asername <> ''On-Site Services employeeAssist'' 
                        and sf.slogin >= ''2017-07-02'' 
                ) x 
            left join dtcomdoc cd on
                cd.kprogprovid = x.kprogprovid 
                and 
                (
                    cd.cdoctitle = ''[DTC] Agreement to Undertake Support & Privacy Notice'' or
                    cd.cdoctitle = ''[Benestar] Agreement to Undertake Support & Privacy Notice''
                )
            where 
                rn = 1 -- First show event
                and cd.kcomdocid is null 
                and x."Resource_Type" <> ''Associate'' 
                and x."Event_Type" <> ''Online'' 

                and exists
                (
                    select 
                        1
                    from 
                        etactcase se2 
                        inner join etact se1 on 
                            se1.kactid = se2.kactid 
                        inner join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        inner join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                    where
                        se2.kprogprovid = x.kprogprovid and
                        sestatus.actstatus = ''Show'' and
                        setype.activitytypename <> ''Administration''
                ) 

            '
        )

    insert into [db-au-dtc].test.EctnNoAgreementDocumentOnFirstEAEvent 
    select 
        Service_file_ID,
        [Service],
        Funder,
        First_Event_ID,
        Event_Type,
        Event_Description,
        cast(Event_Time as datetime) Event_Time,
        Event_Status,
        convert(datetime, Event_Created) Event_Created,
        SF_Primary_Worker,
        Site_Name,
        Resource_Type,
        Reports_To,
        Event_Primary_Worker,
        [State],
        Email,
        Event_PW_Reports_To
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                x.kprogprovid "Service_file_ID",
                x.asername "Service",
                x."Funder",
                x.kactid "First_Event_ID",
                x."Event_Type",
                x."Event_Description",
                x."Event_Time",
                x."Event_Status",
                x."Event_Created",
                x."SF_Primary_Worker",
                x."Site_Name",
                x."Resource_Type",
                x."Reports_To",
                x."Event_Primary_Worker",
                x."State",
                x."Email",
                x."Event_PW_Reports_To"
            from 
                (
                    select 
                        se2.kprogprovid,
                        f.funorg "Funder",
                        s.asername,
                        se1.kactid,
                        setype.activitytypename "Event_Type",
                        se1.acttitle "Event_Description",
                        se1.actstime "Event_Time", 
                        sestatus.actstatus "Event_Status",
                        se1.slogin "Event_Created",
                        trim(u.usfirstname) || '' '' || trim(u.uslastname) "SF_Primary_Worker",
                        site.sitename "Site_Name",
                        lue.luuser1exp4 "Resource_Type",
                        trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                        trim(epwu.usfirstname) || '' '' || trim(epwu.uslastname) "Event_Primary_Worker",
                        st.provstateshort "State",
                        epwu.usemail "Email",
                        trim(epwrt.usfirstname) || '' '' || trim(epwrt.uslastname) "Event_PW_Reports_To",
                        se2.kactstatusid,
                        row_number() over(partition by se2.kprogprovid order by se1.actstime, se1.kactid) rn
                    from 
                        etact se1
                        inner join etactcase se2 on 
                            se1.kactid = se2.kactid
                        left join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        left join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                        left join ctprogprov sf on 
                            sf.kprogprovid = se2.kprogprovid 
                        left join prcaseprog cp on 
                            cp.kcaseprogid = sf.kcaseprogid 
                        left join pragser s on 
                            s.kagserid = cp.kagserid
                        left join wrcworker pw on 
                            pw.kcworkerid = sf.kcworkeridprim 
                        left join wruser u on 
                            u.kuserid = pw.kuserid 
                        left join wrcworker epw on 
                            epw.kcworkerid = se2.kcworkeridprimact 
                        left join wruser epwu on 
                            epwu.kuserid = epw.kuserid 
                        left join wruser rt on 
                            rt.kuserid = epwu.krepuserid 
                        left join luprovstate st on 
                            st.luprovstateid = epwu.luusprovstateid 
                        left join aiccasemembers cm on 
                            cm.kcaseid = sf.kcaseid and cm.cmemprimary = true 
                        left join irindividualsetup indsetup on 
                            indsetup.kindid = cm.kindid
                        left join frfunder f on 
                            f.kfunderid = indsetup.kfunderid 
                        left join wruser epwrt on 
                            epwrt.kuserid = epwu.krepuserid 
                        left join irbookitem bi on 
                            bi.kbookitemid = epwu.kbookitemid  
                        left join sasite site on 
                            site.ksiteid = bi.ksiteid 
                        left join wruser1exp ue on 
                            ue.kuserid = epwu.kuserid 
                        left join luuser1exp4 lue on 
                            lue.luuser1exp4id = ue.user1exp4 
                    where 
                        sestatus.actstatus = ''Show''
                        and se1.actstime < (current_date - interval ''1 day'')::date 
                        and s.asername = ''On-Site Services employeeAssist'' 
                        and sf.slogin >= ''2017-07-02'' 
                ) x 
            left join dtcomdoc cd on 
                cd.kprogprovid = x.kprogprovid and 
                cd.cdoctitle = ''[On-site] Agreement to Undertake Support & Privacy Notice''
            where 
                rn = 1 -- First show event
                and cd.kcomdocid is null 
                and x."Resource_Type" <> ''Associate'' 
                and x."Event_Type" <> ''Online'' 
            '
        )

    -- 13. No ORS on an employeeAssist Service event
    /*
    document for ORS is on the event under outcome assessment – could be any of the below: 
        Outcome Rating Scale (ORS) – Initial
        Outcome Rating Scale (ORS) - Progress
        Outcome Rating Scale (ORS) – Close
    */
    -- person responsible: Event primary worker
    truncate table [db-au-dtc].test.EctnNoORSDocumentOnEAEvent

    insert into [db-au-dtc].test.EctnNoORSDocumentOnEAEvent 
    select 
         Service_file_ID,
         [Service],
         Event_ID,
         Event_Type,
         Event_Description,
         cast(Event_Time as datetime) Event_Time,
         Event_Status,
         Event_Primary_Worker,
         [State],
         Site_Name,
         Resource_Type,
         Reports_To
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                se2.kprogprovid "Service_file_ID",
                s.asername "Service",
                se1.kactid "Event_ID",
                setype.activitytypename "Event_Type",
                se1.acttitle "Event_Description",
                se1.actstime "Event_Time", 
                sestatus.actstatus "Event_Status",
                trim(u.usfirstname) || '' '' || trim(u.uslastname) "Event_Primary_Worker",
                st.provstateshort "State",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type",
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To"
            from 
                etact se1
                inner join etactcase se2 on 
                    se1.kactid = se2.kactid 
                left join saacttype setype on 
                    setype.kactivitytypeid = se2.kactivitytypeid 
                left join ssactstatus sestatus on 
                    sestatus.kactstatusid = se2.kactstatusid 
                left join ctprogprov sf on 
                    sf.kprogprovid = se2.kprogprovid 
                left join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                left join pragser s on 
                    s.kagserid = cp.kagserid
                left join wrcworker pw on 
                    pw.kcworkerid = se2.kcworkeridprimact 
                left join wruser u on 
                    u.kuserid = pw.kuserid 
                left join luprovstate st on 
                    st.luprovstateid = u.luusprovstateid 
                left join wruser rt on 
                    rt.kuserid = u.krepuserid 
                left join dtcomdoc cd on 
                    cd.kactid = se1.kactid 
                    and cd.cdoctitle in 
                    (
                        ''Outcome Rating Scale (ORS) – Initial'', 
                        ''Outcome Rating Scale (ORS) - Progress'',
                        ''Outcome Rating Scale (ORS) – Close''
                    )
                left join irbookitem bi on 
                    bi.kbookitemid = u.kbookitemid 
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp ue on 
                    ue.kuserid = u.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
            where 
                s.asername ~* ''.*(employeeassist|psychological counselling).*'' 
                and se2.kactstatusid = 2 -- Show only 
                and cd.kcomdocid is null 
                and sf.slogin >= ''2017-07-02'' 
            order by 
                se2.kprogprovid 
        '
    )

    -- 14. No SRS on an employeeAssist Service event
    /*
    document for SRS is on the event under outcome assessment – could be any of the below: 
        Session Rating Scale (SRS) - Initial
        Session Rating Scale (SRS) – Progress
        Session Rating Scale (SRS) - Close
    */
    -- person responsible: Event primary worker
    truncate table [db-au-dtc].test.EctnNoSRSDocumentOnEAEvent

    insert into [db-au-dtc].test.EctnNoSRSDocumentOnEAEvent 
    select 
        Service_file_ID,
        [Service],
        Event_ID,
        Event_Type,
        Event_Description,
        cast(Event_Time as datetime) Event_Time,
        Event_Status,
        Event_Primary_Worker,
        [State],
        Site_Name,
        Resource_Type,
        Reports_To
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                se2.kprogprovid "Service_file_ID",
                s.asername "Service",
                se1.kactid "Event_ID",
                setype.activitytypename "Event_Type",
                se1.acttitle "Event_Description",
                se1.actstime "Event_Time", 
                sestatus.actstatus "Event_Status",
                trim(u.usfirstname) || '' '' || trim(u.uslastname) "Event_Primary_Worker",
                st.provstateshort "State",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type",
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To"
            from 
                etact se1
                inner join etactcase se2 on 
                    se1.kactid = se2.kactid 
                left join saacttype setype on 
                    setype.kactivitytypeid = se2.kactivitytypeid 
                left join ssactstatus sestatus on 
                    sestatus.kactstatusid = se2.kactstatusid 
                left join ctprogprov sf on 
                    sf.kprogprovid = se2.kprogprovid 
                left join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                left join pragser s on 
                    s.kagserid = cp.kagserid
                left join wrcworker pw on 
                    pw.kcworkerid = se2.kcworkeridprimact 
                left join wruser u on 
                    u.kuserid = pw.kuserid 
                left join luprovstate st on 
                    st.luprovstateid = u.luusprovstateid 
                left join wruser rt on 
                    rt.kuserid = u.krepuserid 
                left join dtcomdoc cd on 
                    cd.kactid = se1.kactid 
                    and cd.cdoctitle in 
                    (
                        ''Session Rating Scale (SRS) - Initial'', 
                        ''Session Rating Scale (SRS) – Progress'',
                        ''Session Rating Scale (SRS) - Close''
                    )
                left join irbookitem bi on 
                    bi.kbookitemid = u.kbookitemid 
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp ue on 
                    ue.kuserid = u.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
            where 
                s.asername ~* ''.*(employeeassist|psychological counselling).*'' 
                and se2.kactstatusid = 2 -- Show only 
                and cd.kcomdocid is null 
                and sf.slogin >= ''2017-07-02'' 
            order by 
                se2.kprogprovid 
            '
        )    


    -- 18. Events with cart item hours > 10 
    -- person responsible: Event primary worker
    truncate table [db-au-dtc].test.EctnCartItemHoursMoreThan

    insert into [db-au-dtc].test.EctnCartItemHoursMoreThan 
    select 
        Event_ID,
        Event_Primary_Worker,
        [State],
        Reports_To,
        Resource_Type,
        Site_Name,
        cast(Event_Time as datetime) Event_Time,
        Event_Duration_In_Hours,
        Cart_Item_Hours,
        Event_Type,
        Event_Description,
        Event_Status,
        convert(datetime, Event_Created) Event_Created,
        Service_File_ID,
        [Service],
        SF_Primary_Worker,
        SF_PW_Reports_To
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                se1.kactid "Event_ID",
                trim(epwu.usfirstname) || '' '' || trim(epwu.uslastname) "Event_Primary_Worker",
                st.provstateshort "State",
                trim(epwrt.usfirstname) || '' '' || trim(epwrt.uslastname) "Reports_To",
                epwlu.luuser1exp4 "Resource_Type",
                site.sitename "Site_Name",
                se1.actstime "Event_Time",
                extract(epoch from se1.actetime - se1.actstime)/3600.0::numeric(10,2) "Event_Duration_In_Hours",
                b."Cart_Item_Hours"::numeric(10,2) "Cart_Item_Hours",
                setype.activitytypename "Event_Type",
                se1.acttitle "Event_Description",
                sestatus.actstatus "Event_Status",
                se1.slogin "Event_Created",
                se2.kprogprovid "Service_File_ID",
                s.asername "Service",
                trim(sfpwu.usfirstname) || '' '' || trim(sfpwu.uslastname) "SF_Primary_Worker",
                trim(sfpwrt.usfirstname) || '' '' || trim(sfpwrt.uslastname) "SF_PW_Reports_To"
            from 
                etact se1 
                inner join etactcase se2 on 
                    se1.kactid = se2.kactid 
                inner join saacttype setype on 
                    setype.kactivitytypeid = se2.kactivitytypeid -- event type 
                inner join ssactstatus sestatus on 
                    sestatus.kactstatusid = se2.kactstatusid -- event status 
                inner join ctprogprov sf on 
                    se2.kprogprovid = sf.kprogprovid    -- service file
                inner join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                inner join pragser s on 
                    s.kagserid = cp.kagserid -- service
                inner join wrcworker epw on 
                    epw.kcworkerid = se2.kcworkeridprimact -- event primary worker 
                inner join wruser epwu on 
                    epwu.kuserid = epw.kuserid 
                left join luprovstate st on 
                    st.luprovstateid = epwu.luusprovstateid 
                left join irbookitem epwbi on 
                    epwbi.kbookitemid = epwu.kbookitemid 
                left join sasite site on 
                    site.ksiteid = epwbi.ksiteid 
                left join wruser1exp epwue on 
                    epwue.kuserid = epwu.kuserid 
                left join luuser1exp4 epwlu on 
                    epwlu.luuser1exp4id = epwue.user1exp4  
                left join wruser epwrt on 
                    epwrt.kuserid = epwu.krepuserid 
                left join wrcworker sfpw on 
                    sfpw.kcworkerid = sf.kcworkeridprim 
                left join wruser sfpwu on 
                    sfpwu.kuserid = sfpw.kuserid 
                left join wruser sfpwrt on 
                    sfpwrt.kuserid = sfpwu.krepuserid 
                inner join 
                (
                    select 
                        sea.kactid, 
                        sum(sea.lineqty * uom.equiv) "Cart_Item_Hours",
                        sum
                        (
                            case
                                when i.itemnameshort in (''ONSITE'', ''TRAVCLIN'', ''CONSUL'') then sea.lineqty * uom.equiv
                                else 0
                            end 
                        ) "Cart_Specific_Item_Hours",
                        sum
                        (
                            case
                                when i.itemnameshort in (''ONSITE'', ''TRAVCLIN'', ''CONSUL'') then 0
                                else sea.lineqty * uom.equiv
                            end 
                        ) "Cart_NonSpecific_Item_Hours"
                    from 
                        etactline sea 
                        inner join nruom uom on 
                            uom.kuomid = sea.kuomid 
                        inner join nritem i on
                            i.kitemid = sea.kitemid
                    where 
                        uom.kuomsid = 1 
                    group by
                        sea.kactid
                ) b
                    on se1.kactid = b.kactid
            where 
                sf.slogin >= ''2017-07-02''
                and
                (
                    (
                        s.asername in 
                        (
                            ''employeeAssist'', 
                            ''managerAssist'', 
                            ''legalAssist'', 
                            ''Nutrition@DTC'', 
                            ''moneyAssist'', 
                            ''DFV Support'', 
                            ''DFV Support - managerAssist''
                        )
                        and b."Cart_Item_Hours" > 1.5
                    )
                    or 
                    (
                        s.asername in 
                        (
                            ''Psychological Counselling''
                        )
                        and b."Cart_NonSpecific_Item_Hours" > 1.5
                    )
                    or 
                    (
                        s.asername in 
                        (
                            ''Psychological Counselling''
                        )
                        and b."Cart_Specific_Item_Hours" > 10
                    )
                    or 
                    (
                        s.asername in 
                        (
                            ''On-Site Services''
                        )
                        and b."Cart_Item_Hours" > 16
                    )
                    or
                    (
                        s.asername not in 
                        (
                            ''employeeAssist'', 
                            ''managerAssist'', 
                            ''legalAssist'', 
                            ''Nutrition@DTC'', 
                            ''moneyAssist'', 
                            ''DFV Support'', 
                            ''DFV Support - managerAssist'',
                            ''Psychological Counselling'',
                            ''On-Site Services''
                        )
                        and b."Cart_Item_Hours" > 10
                    )
                )
            order by 
                b."Cart_Item_Hours" desc
            '
        )


    -- 19. No employeeAssist associate dataform
    -- person responsible: First event primary worker
    truncate table [db-au-dtc].test.EctnNoEmployeeAssistAssociateDataform

    insert into [db-au-dtc].test.EctnNoEmployeeAssistAssociateDataform
    select 
        First_Event_ID,
        kprogprovid Service_File_ID,
        [Service],
        Event_Type,
        Event_Description,
        convert(datetime, Event_Time) Event_Time,
        Event_Status,
        convert(datetime, Event_Created) Event_Created,
        SF_Primary_Worker,
        Email,
        Site_Name,
        Resource_Type,
        Reports_To,
        Event_Primary_Worker,
        [State]
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                e.*
            from 
                (
                    select 
                        se2.kprogprovid,
                        s.asername "Service",
                        se1.kactid "First_Event_ID",
                        setype.activitytypename "Event_Type",
                        se1.acttitle "Event_Description",
                        se1.actstime "Event_Time", 
                        sestatus.actstatus "Event_Status",
                        se1.slogin "Event_Created",
                        trim(u.usfirstname) || '' '' || trim(u.uslastname) "SF_Primary_Worker",
                        u.usemail "Email",
                        site.sitename "Site_Name",
                        lue.luuser1exp4 "Resource_Type",
                        trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                        trim(epwu.usfirstname) || '' '' || trim(epwu.uslastname) "Event_Primary_Worker",
                        st.provstateshort "State",
                        selue.luuser1exp4,
                        row_number() over(partition by se2.kprogprovid order by se1.actstime, se1.kactid) rn
                    from 
                        etact se1
                        join etactcase se2 on 
                            se1.kactid = se2.kactid
                        left join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        left join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                        left join ctprogprov sf on 
                            sf.kprogprovid = se2.kprogprovid 
                        left join prcaseprog cp on 
                            cp.kcaseprogid = sf.kcaseprogid 
                        left join pragser s on 
                            s.kagserid = cp.kagserid
                        left join wrcworker pw on 
                            pw.kcworkerid = sf.kcworkeridprim 
                        left join wruser u on 
                            u.kuserid = pw.kuserid 
                        left join wruser rt on 
                            rt.kuserid = u.krepuserid 
                        left join wrcworker sepw on 
                            sepw.kcworkerid = se2.kcworkeridprimact 
                        left join wruser epwu on 
                            epwu.kuserid = sepw.kuserid 
                        left join luprovstate st on 
                            st.luprovstateid = epwu.luusprovstateid 
                        -- join to all presenting users 
                        left join(
                            select 
                                sea.kactid,
                                u.kuserid
                            from 
                                aecactmem sea 
                                join wruser u on u.kbookitemid = sea.kbookitemid 
                        ) sew on 
                            sew.kactid = se2.kactid         
                        left join wruser1exp seue on 
                            seue.kuserid = sew.kuserid 
                        left join luuser1exp4 selue on 
                            selue.luuser1exp4id = seue.user1exp4 
                        left join irbookitem bi on 
                            bi.kbookitemid = epwu.kbookitemid  
                        left join sasite site on 
                            site.ksiteid = bi.ksiteid 
                        left join wruser1exp ue on 
                            ue.kuserid = epwu.kuserid 
                        left join luuser1exp4 lue on 
                            lue.luuser1exp4id = ue.user1exp4 
                    where 
                        sestatus.actstatus = ''Show'' 
                        and s.asername = ''employeeAssist'' 
                        and sf.slogin >= ''2017-07-02'' 
                ) e 
                left join 
                (
                    select 
                        rsf.kprogprovid
                    from 
                        dtcomdoc cd 
                        join adcservfileassign rsf on rsf.kcomdocid = cd.kcomdocid
                    where 
                        cd.cdoctitle = ''[Associate] employeeAssist Dataform''
                ) d on 
                    d.kprogprovid = e.kprogprovid
            where 
                e.rn = 1 
                and e.luuser1exp4 = ''Associate''
                and d.kprogprovid is null 

                and exists
                (
                    select 
                        1
                    from 
                        etactcase se2 
                        inner join etact se1 on 
                            se1.kactid = se2.kactid 
                        inner join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        inner join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                    where
                        se2.kprogprovid = e.kprogprovid and
                        sestatus.actstatus = ''Show'' and
                        setype.activitytypename <> ''Administration''
                ) 

            '
        )


    -- 20. Service Events Not Covered 
    -- person responsible: Service File created by

    --Mod 20180423: DM Individual not having a funder should not matter in this case of Service Events not covered
    ---- get the service files where the individual has no default funder
    --if object_id('tempdb.test.#sf') is not null drop table #sf 
    --select 
    --    Service_File_ID 
    --into #sf 
    --from openquery(PENELOPEPROD, '
    --    select 
    --        distinct sf.kprogprovid "Service_File_ID"
    --    from 
    --        ctprogprov sf 
    --        join aicprogmem sfm on sfm.kprogprovid = sf.kprogprovid 
    --        join aiccasemembers cm on cm.kcasemembersid = sfm.kcasemembersid 
    --        left join irindividualsetup s on s.kindid = cm.kindid 
    --        left join irindividual i on i.kindid = cm.kindid 
    --        left join wruser sfcu on sfcu.usloginid = sf.sloginby 
    --        left join wruser sfcurt on sfcurt.kuserid = sfcu.krepuserid 
    --        left join luprovstate st on st.luprovstateid = sfcu.luusprovstateid 
    --    where 
    --        cm.cmemprimary = true 
    --        and s.kfunderid is null 
    --        and sf.slogin >= ''2017-07-02''
    --')


    --Mod 20180423: adjusted query to take into account the ETACTLINENOTE table having an entry
    truncate table [db-au-dtc].test.EctnServiceEventsNotCovered

    insert into [db-au-dtc].test.EctnServiceEventsNotCovered
    select 
        Service_File_ID,
        --change owner to be the one creating adding cart item
        SF_Created_by,
        Reports_To,
        [State],
        Resource_Type,
        Service_Type,
        Login_ID,
        Event_Created_by,
        Event_ID,
        convert(datetime, Event_Created) Event_Created,
        convert(datetime, Event_Start) Event_Start,
        convert(datetime, Event_End) Event_End,
        Event_Status,
        Individual_First_Name,
        Individual_Last_Name,
        Customer,
        Cart_Item_Count,
        Event_Length,
        Cart_Item_Qty_in_Hours,
        Cart_Item_Qty_in_Minutes
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                se2.kprogprovid "Service_File_ID",
                s.asername "Service_Type",
                se1.sloginby "Login_ID",
                trim(sec.usfirstname) || '' '' || trim(sec.uslastname) "Event_Created_by",
                se1.kactid "Event_ID",
                se1.slogin "Event_Created",
                se1.actstime "Event_Start",
                se1.actetime "Event_End",
                sestatus.actstatus "Event_Status",
                i.indfirstname "Individual_First_Name", 
                i.indlastname "Individual_Last_Name",
                f.funorg "Customer",
                trim(cu.usfirstname) || '' '' || trim(cu.uslastname) "SF_Created_by",
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                st.provstateshort "State",
                lue.luuser1exp4 "Resource_Type",
                sum(case when ci.kactlineid is not null then 1 else 0 end) "Cart_Item_Count",
                to_char(se1.actetime - se1.actstime, ''HH24:MI:SS'') "Event_Length",
                sum(case when uom.kuomsid = 1 then ci.lineqty * uom.equiv else 0 end)::numeric(10,2) "Cart_Item_Qty_in_Hours",
                (sum(case when uom.kuomsid = 1 then ci.lineqty * uom.equiv else 0 end) * 60)::numeric(10,2) "Cart_Item_Qty_in_Minutes",
                ci.sloginby "Cart_Item_Created_By"
            from 
                etactline ci 
                left join btinvline il on 
                    il.kactlineid = ci.kactlineid 
                left join etactcase se2 on 
                    ci.kactid = se2.kactid 
                left join etact se1 on 
                    se1.kactid = se2.kactid 
                left join ssactstatus sestatus on 
                    sestatus.kactstatusid = se2.kactstatusid 
                left join nritem on 
                    nritem.kitemid = ci.kitemid 
                left join wruser sec on 
                    sec.usloginid = se1.sloginby 
                left join ctprogprov sf on 
                    sf.kprogprovid = se2.kprogprovid 
                left join wruser cu on 
                    cu.usloginid = ci.sloginby
                left join wruser1exp ue on 
                    ue.kuserid = cu.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
                left join wruser rt on 
                    rt.kuserid = cu.krepuserid 
                left join luprovstate st on 
                    st.luprovstateid = cu.luusprovstateid 
                left join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                left join pragser s on 
                    s.kagserid = cp.kagserid 
                left join aiccasemembers cm on 
                    cm.kcaseid = sf.kcaseid and cm.cmemprimary = true 
                left join irindividual i on 
                    i.kindid = cm.kindid 
                left join irindividualsetup ist on 
                    ist.kindid = cm.kindid 
                left join frfunder f on 
                    f.kfunderid = ist.kfunderid  
                left join nruom uom on 
                    uom.kuomid = ci.kuomid 
            where 
                il.kinvlineid is null 
                or exists 
                (
                    select 
                        1 
                    from 
                        etactlinenote en 
                    where 
                        ci.kactlineid = en.kactlineid
                )
            group by 
                1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,21
    ')

    -- remove from EctnServiceEventsNotCovered where the individual has no default funder
    --Mod 20180423: DM Individual not having a funder should not matter in this case
    --delete e 
    --from 
    --    [db-au-dtc].test.EctnServiceEventsNotCovered e 
    --    join #sf on #sf.Service_File_ID = e.Service_File_ID


    -- 21. Policies without payable-to-site id 
    truncate table [db-au-dtc].test.EctnPoliciesNoPayableSite

    insert into [db-au-dtc].test.EctnPoliciesNoPayableSite
    select 
        Individual_ID,
        Policy_ID,
        Billing_Sequence,
        Funder_ID,
        Funder,
        Class,
        [Type],
        Policy_Name,
        [Status],
        Service_Files,
        Service_File_IDs
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                pm.kindid "Individual_ID",
                p.kpolicyid "Policy_ID", 
                bs.billseq "Billing_Sequence",
                f.kfunderid "Funder_ID", 
                f.funorg "Funder", 
                pc.policyclass "Class", 
                pt.policytype "Type", 
                p.policyname "Policy_Name", 
                case when p.policystatus = true then ''Active'' else ''Inactive'' end "Status", 
                count(distinct sf.kprogprovid) "Service_Files",
                string_agg(sf.kprogprovid::varchar, '', '')::varchar(1000000) "Service_File_IDs"
            from  
                frpolicy p 
                left join sspolicyclass pc on pc.kpolicyclassid = p.kpolicyclassid 
                left join sapolicytype pt on pt.kpolicytypeid = p.kpolicytypeid 
                left join frpublicpolicy pp on pp.kpublicpolicyid = p.kpublicpolicyid 
                left join aifpolicymem pm on pm.kpolicyid = p.kpolicyid 
                left join btbillseq bs on bs.kpolicymemid = pm.kpolicymemid 
                left join ctprogprov sf on sf.kprogprovid = bs.kprogprovid 
                left join aicprogmem sfm on sfm.kprogprovid = sf.kprogprovid 
                left join aiccasemembers cm on cm.kcasemembersid = sfm.kcasemembersid 
                left join irindividualsetup i on i.kindid = cm.kindid 
                left join frfunder f on f.kfunderid = p.kfunderid 
            where 
                p.payabletositeid is null
            group by 
                1,2,3,4,5,6,7,8
    
            UNION ALL

            select 
                null::int "Individual_ID",
                p.kpublicpolicyid "Policy_ID", 
                bs.billseq "Billing_Sequence",
                f.kfunderid "Funder_ID", 
                f.funorg "Funder", 
                ''Public'' "Class", 
                pt.policytype "Type", 
                p.pubpolname "Policy_Name", 
                case when p.pubpolstatus = true then ''Active'' else ''Inactive'' end "Status", 
                count(distinct sf.kprogprovid) "Service_Files",
                string_agg(sf.kprogprovid::varchar, '', '')::varchar(1000000) "Service_File_IDs"
            from  
                frpublicpolicy p 
                --left join sspolicyclass pc on pc.kpolicyclassid = p.kpolicyclassid 
                left join sapolicytype pt on pt.kpolicytypeid = p.kpolicytypeid 
                left join frpolicy pp on p.kpublicpolicyid = pp.kpublicpolicyid
                left join aifpolicymem pm on pm.kpolicyid = pp.kpolicyid 
                left join btbillseq bs on bs.kpolicymemid = pm.kpolicymemid 
                left join ctprogprov sf on sf.kprogprovid = bs.kprogprovid 
                left join aicprogmem sfm on sfm.kprogprovid = sf.kprogprovid 
                left join aiccasemembers cm on cm.kcasemembersid = sfm.kcasemembersid 
                left join irindividualsetup i on i.kindid = cm.kindid 
                left join frfunder f on f.kfunderid = p.kfunderid 
            where 
                p.payabletositeid is null 
            group by 
                1,2,3,4,5,6,7,8
            '
        )


    -- 22. Policy funder not matching individual profile 
    truncate table [db-au-dtc].test.EctnPolicyFunderNotMatchIndividualProfile

    insert into [db-au-dtc].test.EctnPolicyFunderNotMatchIndividualProfile
    select 
        Policy_ID,
        Policy_Name,
        Individual_ID,
        Policy_Holder,
        Policy_Funder,
        Individual_Funder,
        convert(datetime, Policy_Created) Policy_Created
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                p.kpolicyid "Policy_ID",
                p.policyname "Policy_Name",
                pm.kindid "Individual_ID",
                trim(i.indfirstname) || '' '' || trim(i.indlastname) "Policy_Holder",
                f1.funorg "Policy_Funder",
                f2.funorg "Individual_Funder",
                p.slogin "Policy_Created"
            from  
                frpolicy p 
                join aifpolicymem pm on pm.kpolicyid = p.kpolicyid 
                left join irindividual i on i.kindid = pm.kindid 
                left join irindividualsetup ist on ist.kindid = i.kindid 
                left join frfunder f1 on f1.kfunderid = p.kfunderid 
                left join frfunder f2 on f2.kfunderid = ist.kfunderid 
        
            where 
                (f1.kfunderid is null and f2.kfunderid is not null) 
                or (f1.kfunderid is not null and f2.kfunderid is null) 
                or (f1.kfunderid <> f2.kfunderid)
            '
        )


    -- 23. Multiple Funders in Billing Sequence
    truncate table [db-au-dtc].test.EctnMultipleFundersInBillSeq 

    insert into [db-au-dtc].test.EctnMultipleFundersInBillSeq 
    select 
        Service_File_ID 
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                kprogprovid "Service_File_ID" 
            from (
                select 
                    bs.kprogprovid,
                    p.kfunderid
                from 
                    btbillseq bs 
                    join aifpolicymem pm on pm.kpolicymemid = bs.kpolicymemid 
                    join frpolicy p on p.kpolicyid = pm.kpolicyid 
                    join ctprogprov sf on sf.kprogprovid = bs.kprogprovid 
                where 
                    exists (select null from aicprogmem sfm join aiccasemembers cm on cm.kcasemembersid = sfm.kcasemembersid where cm.kindid = pm.kindid and sfm.kprogprovid = bs.kprogprovid)
                    and sf.kprogprovstatusid <> 2 
                    and p.policystatus = true 
                    and pm.polmemstatus = true 
                group by 
                    bs.kprogprovid,
                    p.kfunderid
            ) a 
            group by 
                kprogprovid 
            having 
                count(*) > 1
            '
        )


    -- 24. No funder department on the policy 
    truncate table [db-au-dtc].test.EctnNoFunderDepartmentOnPolicy 

    insert into [db-au-dtc].test.EctnNoFunderDepartmentOnPolicy 
    select 
        Case_ID,
        Service_File_ID,
        [Service],
        [Group],
        [Status],
        SF_Primary_Worker,
        Site_Name,
        Resource_Type, 
        SF_Created_By,
        [State],
        convert(datetime, SF_Created_At) SF_Created_At,
        Manager 
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            with a as 
            (
                select 
                    sf.kcaseid "Case_ID",
                    sf.kprogprovid "Service_File_ID",
                    s.asername "Service",
                    sfg.proggroupname "Group",
                    sfs.progprovstatus "Status",
                    trim(sfpwu.usfirstname) || '' '' || trim(sfpwu.uslastname) "SF_Primary_Worker",
                    site.sitename "Site_Name",
                    lue.luuser1exp4 "Resource_Type", 
                    trim(sfcu.usfirstname) || '' '' || trim(sfcu.uslastname) "SF_Created_By",
                    st.provstateshort "State",
                    sf.slogin "SF_Created_At",
                    trim(sfcurt.usfirstname) || '' '' || trim(sfcurt.uslastname) "Manager",
                    pm.kfunderdeptid,
                    row_number() over(partition by bs.kprogprovid order by bs.billseq) rn  
                from 
                    btbillseq bs 
                    join ctprogprov sf on sf.kprogprovid = bs.kprogprovid 
                    join aifpolicymem pm on pm.kpolicymemid = bs.kpolicymemid 
                    join aiccasemembers cm on cm.kindid = pm.kindid and cm.kcaseid = sf.kcaseid 
                    left join prcaseprog cp on cp.kcaseprogid = sf.kcaseprogid 
                    left join saproggroup sfg on sfg.kproggroupid = cp.kproggroupid 
                    left join ssprogprovstatus sfs on sfs.kprogprovstatusid = sf.kprogprovstatusid 
                    left join pragser s on s.kagserid = cp.kagserid 
                    left join wrcworker sfpw on sfpw.kcworkerid = sf.kcworkeridprim 
                    left join wruser sfpwu on sfpwu.kuserid = sfpw.kuserid 
                    left join irbookitem bi on bi.kbookitemid = sfpwu.kbookitemid  
                    left join sasite site on site.ksiteid = bi.ksiteid 
                    left join wruser1exp ue on ue.kuserid = sfpwu.kuserid 
                    left join luuser1exp4 lue on lue.luuser1exp4id = ue.user1exp4 
                    left join wruser sfcu on sfcu.usloginid = sf.sloginby 
                    left join wruser sfcurt on sfcurt.kuserid = sfcu.krepuserid 
                    left join luprovstate st on st.luprovstateid = sfcu.luusprovstateid 
                where 
                    sf.slogin >= current_date - interval ''7'' day
                )
            select *
            from a 
            where rn = 1 and kfunderdeptid is null
            ')




    -- 25. No Presenting Issue - managerAssist
    -- person responsible: First event primary worker
    truncate table [db-au-dtc].test.EctnNoPresentingIssueMA

    insert into [db-au-dtc].test.EctnNoPresentingIssueMA
    select 
         Service_File_ID,
         [Service],
         Funder,
         First_Event_Type,
         cast(First_Event_Date as datetime) First_Event_Date,
         Event_Primary_Worker,
         [State],
         convert(date, Event_Created) Event_Created,
         SF_Primary_Worker,
         Site_Name,
         Resource_Type, 
         Email, 
         Reports_To 
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                sf.kprogprovid "Service_File_ID",
                s.asername "Service",
                f.funorg "Funder",
                e.activitytypename "First_Event_Type",
                e.actstime "First_Event_Date",
                e."Event_Primary_Worker",
                e."State",
                e.slogin "Event_Created",
                trim(u.usfirstname) || '' '' || trim(u.uslastname) "SF_Primary_Worker",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type",
                u.usemail "Email",
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To"
            from 
                ctprogprov sf 
                left join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                left join pragser s on 
                    s.kagserid = cp.kagserid
                left join wrcworker pw on 
                    pw.kcworkerid = sf.kcworkeridprim 
                left join wruser u on 
                    u.kuserid = pw.kuserid 
                left join wruser rt on 
                    rt.kuserid = u.krepuserid 
                left join irbookitem bi on 
                    bi.kbookitemid = u.kbookitemid  
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp ue on 
                    ue.kuserid = u.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
                inner join 
                (
                    select 
                        se2.kprogprovid,
                        setype.activitytypename,
                        se1.actstime,
                        se1.slogin,
                        trim(u.usfirstname) || '' '' || trim(u.uslastname) "Event_Primary_Worker",
                        st.provstateshort "State",
                        row_number() over(partition by se2.kprogprovid order by se1.actstime, se1.kactid) rn
                    from 
                        etactcase se2 
                        inner join etact se1 on 
                            se1.kactid = se2.kactid 
                        inner join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        inner join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                        left join wrcworker pw on 
                            pw.kcworkerid = se2.kcworkeridprimact 
                        left join wruser u on 
                            u.kuserid = pw.kuserid 
                        left join luprovstate st on 
                            st.luprovstateid = u.luusprovstateid 
                    where 
                        sestatus.actstatus = ''Show''
                ) e on 
                    e.kprogprovid = sf.kprogprovid 
                left join aiccasemembers cm on 
                    cm.kcaseid = sf.kcaseid and cm.cmemprimary = true 
                left join irindividualsetup indsetup on 
                    indsetup.kindid = cm.kindid
                left join frfunder f on 
                    f.kfunderid = indsetup.kfunderid 
            where 
                e.actstime < (current_date - interval ''1 day'')::date 
                and s.asername = ''managerAssist'' 
                and e.rn = 1 
                and e.actstime < current_timestamp 
                and sf.kcworkeridprim <> 1847 /*exclude Stratos*/
                and sf.slogin >= ''2017-07-02'' 
                /*no manager assist data form doc - presenting issues*/ 
                and not exists
                (
                    select
                        1
                    from
                        dtcomdoc cd
                        inner join dtcomdocrev cdr on
                            cdr.kcomdocid = cd.kcomdocid
                        inner join dtcomdocrevbody cdrb on
                            cdrb.kcomdocrevid = cdr.kcomdocrevid
                        inner join dtcomanswer ca on
                            ca.kcomdocrevbodyid = cdrb.kcomdocrevbodyid
                        inner join drdoc d on 
                            d.kdocid = cd.kdocid
                        inner join drdocmast dm on 
                            dm.kdocmastid = d.kdocmastid
                        inner join drpartques pq on 
                            pq.kpartid = ca.kpartidques
                        inner join drpart p on 
                            p.kpartid = pq.kpartid
                    where
                        cd.kprogprovid = sf.kprogprovid and 
                        cd.cdoctitle = ''[Clinical] managerAssist Service File Data Form'' and
                        p.partname like ''%Presenting Issue''
                )

                and exists
                (
                    select 
                        1
                    from 
                        etactcase se2 
                        inner join etact se1 on 
                            se1.kactid = se2.kactid 
                        inner join saacttype setype on 
                            setype.kactivitytypeid = se2.kactivitytypeid 
                        inner join ssactstatus sestatus on 
                            sestatus.kactstatusid = se2.kactstatusid 
                    where
                        se2.kprogprovid = sf.kprogprovid and
                        sestatus.actstatus = ''Show'' and
                        setype.activitytypename <> ''Administration''
                ) 

            order by 
                sf.kprogprovid desc
            '
        )

    -- 26. Travel Clinician without travel customer carting
    -- person responsible: primary worker on travel clinician carting
    truncate table [db-au-dtc].test.EctnNoTravelCustomer

    insert into [db-au-dtc].test.EctnNoTravelCustomer
    select 
        Event_ID,
        Event_Primary_Worker,
        [State],
        Reports_To,
        Resource_Type,
        Site_Name,
        cast(Event_Time as datetime) Event_Time,
        Event_Duration_In_Hours,
        Cart_Item_Hours,
        Event_Type,
        Event_Description,
        Event_Status,
        convert(datetime, Event_Created) Event_Created,
        Service_File_ID,
        [Service],
        SF_Primary_Worker,
        SF_PW_Reports_To
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            select 
                se1.kactid "Event_ID",
                trim(epwu.usfirstname) || '' '' || trim(epwu.uslastname) "Event_Primary_Worker",
                st.provstateshort "State",
                trim(epwrt.usfirstname) || '' '' || trim(epwrt.uslastname) "Reports_To",
                epwlu.luuser1exp4 "Resource_Type",
                site.sitename "Site_Name",
                se1.actstime "Event_Time",
                extract(epoch from se1.actetime - se1.actstime)/3600.0::numeric(10,2) "Event_Duration_In_Hours",
                b."Travel_Clinician_Hours"::numeric(10,2) "Cart_Item_Hours",
                setype.activitytypename "Event_Type",
                se1.acttitle "Event_Description",
                sestatus.actstatus "Event_Status",
                se1.slogin "Event_Created",
                se2.kprogprovid "Service_File_ID",
                s.asername "Service",
                trim(sfpwu.usfirstname) || '' '' || trim(sfpwu.uslastname) "SF_Primary_Worker",
                trim(sfpwrt.usfirstname) || '' '' || trim(sfpwrt.uslastname) "SF_PW_Reports_To"
            from 
                etact se1 
                inner join etactcase se2 on 
                    se1.kactid = se2.kactid 
                inner join saacttype setype on 
                    setype.kactivitytypeid = se2.kactivitytypeid -- event type 
                inner join ssactstatus sestatus on 
                    sestatus.kactstatusid = se2.kactstatusid -- event status 
                inner join ctprogprov sf on 
                    se2.kprogprovid = sf.kprogprovid    -- service file
                inner join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                inner join pragser s on 
                    s.kagserid = cp.kagserid -- service
                inner join wrcworker epw on 
                    epw.kcworkerid = se2.kcworkeridprimact -- event primary worker 
                inner join wruser epwu on 
                    epwu.kuserid = epw.kuserid 
                left join luprovstate st on 
                    st.luprovstateid = epwu.luusprovstateid 
                left join irbookitem epwbi on 
                    epwbi.kbookitemid = epwu.kbookitemid 
                left join sasite site on 
                    site.ksiteid = epwbi.ksiteid 
                left join wruser1exp epwue on 
                    epwue.kuserid = epwu.kuserid 
                left join luuser1exp4 epwlu on 
                    epwlu.luuser1exp4id = epwue.user1exp4  
                left join wruser epwrt on 
                    epwrt.kuserid = epwu.krepuserid 
                left join wrcworker sfpw on 
                    sfpw.kcworkerid = sf.kcworkeridprim 
                left join wruser sfpwu on 
                    sfpwu.kuserid = sfpw.kuserid 
                left join wruser sfpwrt on 
                    sfpwrt.kuserid = sfpwu.krepuserid 
                inner join 
                (
                    select 
                        sea.kactid, 
                        sum(sea.lineqty * uom.equiv) "Travel_Clinician_Hours"
                    from 
                        etactline sea 
                        inner join nruom uom on 
                            uom.kuomid = sea.kuomid 
                        inner join nritem i on
                            i.kitemid = sea.kitemid
                    where 
                        uom.kuomsid = 1 and
                        i.itemnameshort in (''TRAVCLIN'')
                    group by
                        sea.kactid
                ) b
                    on se1.kactid = b.kactid
                left join 
                (
                    select 
                        tcse.kprogprovid, 
                        tce.actstime::date EventDate,
                        sum(sea.lineqty * uom.equiv) "Travel_Customer_Hours"
                    from 
                        etactcase tcse
                        inner join etact tce on
                            tce.kactid = tcse.kactid
                        inner join etactline sea on
                            sea.kactid = tcse.kactid 
                        inner join nruom uom on 
                            uom.kuomid = sea.kuomid 
                        inner join nritem i on
                            i.kitemid = sea.kitemid
                    where 
                        uom.kuomsid = 1 and
                        i.itemnameshort in (''TRAVEL'')
                    group by
                        tcse.kprogprovid,
                        tce.actstime::date
                ) tc on 
                    se2.kprogprovid = tc.kprogprovid and
                    tc.EventDate = se1.actstime::date
            where 
                sf.slogin >= ''2017-07-02'' and
                b."Travel_Clinician_Hours" > 0 and
                coalesce(tc."Travel_Customer_Hours", 0) = 0 and
                s.asername not in (''Development@Work'',''worklifeAssist'')
        and
                s.asername not like ''Dev@Work%''
            order by
                se2.kprogprovid desc
            '
        )

    -- 27. Multiple worker on event
    -- person responsible: event creator
    truncate table [db-au-dtc].test.EctnMultipleWorkerOnEvent

    insert into [db-au-dtc].test.EctnMultipleWorkerOnEvent
    select 
        t.Funder,
        t.Service_File_ID,
        t.[Service],
        t.Event_ID,
        cast(t.Event_Created_At as datetime) Event_Created_At,
        cast(t.Event_Time as datetime) Event_Time,
        t.Event_Status,
        t.Event_Type,
        t.Event_Description,
        t.Event_Creator,
        t.[State],
        t.Reports_To,
        t.Site_Name,
        t.Resource_Type,
        t.Worker_Count 
    from 
        openquery
        (
            PENELOPEPROD, 
            '
            with sff as 
            (
                select 
                    sf.kprogprovid,
                    f.funorg "Funder",
                    row_number() over(partition by sf.kprogprovid order by bs.billseq) rn 
                from 
                    btbillseq bs 
                    inner join aifpolicymem pm on 
                        pm.kpolicymemid = bs.kpolicymemid 
                    inner join frpolicy p on 
                        p.kpolicyid = pm.kpolicyid 
                    inner join ctprogprov sf on 
                        sf.kprogprovid = bs.kprogprovid 
                    inner join frfunder f on 
                        f.kfunderid = p.kfunderid
            ) 
            select 
                sff."Funder",
                se2.kprogprovid "Service_File_ID",
                s.asername "Service",
                se1.kactid "Event_ID",
                se1.slogin "Event_Created_At",
                se1.actstime "Event_Time",
                sestatus.actstatus "Event_Status",
                setype.activitytypename "Event_Type",
                se1.acttitle "Event_Description",
                trim(u.usfirstname) || '' '' || trim(u.uslastname) "Event_Creator",
                st.provstateshort "State",
                trim(rt.usfirstname) || '' '' || trim(rt.uslastname) "Reports_To",
                site.sitename "Site_Name",
                lue.luuser1exp4 "Resource_Type",
                seat.Worker_Count,
				seat.Attending_Worker_count
            from 
                etact se1 
                inner join 
                (
                    select 
                        t1.*,
                        t2.kprogprovid,
                        t2.kactivitytypeid,
                        t2.kactstatusid,
                        t2.kcworkeridprimact,
                        row_number() over(partition by t2.kprogprovid order by t1.actstime, t1.kactid) rn 
                    from 
                        etactcase t2 
                        inner join etact t1 on 
                            t1.kactid = t2.kactid 
                ) se2 on 
                    se1.kactid = se2.kactid 
                inner join ssactcat sec on 
                    sec.kactcatid = se1.kactcatid 
                inner join saacttype setype on 
                    setype.kactivitytypeid = se2.kactivitytypeid 
                inner join ssactstatus sestatus on 
                    sestatus.kactstatusid = se2.kactstatusid 
                inner join ctprogprov sf on 
                    se2.kprogprovid = sf.kprogprovid
                inner join prcaseprog cp on 
                    cp.kcaseprogid = sf.kcaseprogid 
                inner join pragser s on 
                    s.kagserid = cp.kagserid
                inner join 
                (
                    select
                        seat.kactid,
                        count
                        (
                            distinct seatw.kcworkerid
                        ) Worker_Count,
                        count
                        (
						    distinct 
                            case
                                when seat.amemshow = true then seatw.kcworkerid
								else null
							end
                        ) Attending_Worker_Count
                    from
                        aecactmem seat
                        inner join wruser seatu on
                            seatu.kbookitemid = seat.kbookitemid
                        inner join wrcworker seatw on
                            seatw.kuserid = seatu.kuserid
                    group by
                        seat.kactid
                ) seat on
                    seat.kactid = se1.kactid
                left join urlogin ul on 
                    ul.usloginid = se1.sloginby
                left join irbookitem bi on 
                    bi.kbookitemid = ul.kbookitemid
                left join wruser u on 
                    bi.kbookitemid = u.kbookitemid  
                left join luprovstate st on 
                    st.luprovstateid = u.luusprovstateid 
                left join sasite site on 
                    site.ksiteid = bi.ksiteid 
                left join wruser1exp ue on 
                    ue.kuserid = u.kuserid 
                left join luuser1exp4 lue on 
                    lue.luuser1exp4id = ue.user1exp4 
                left join wruser rt on 
                    rt.kuserid = u.krepuserid 
                left join etactline sea on 
                    sea.kactid = se1.kactid 
                left join sff on 
                    sff.kprogprovid = se2.kprogprovid 
            where 
                seat.Worker_Count > 1 
                and se1.actetime < current_timestamp -- only past events
                and sf.slogin >= ''2017-07-02'' 
                and 
                (
                    sff.rn = 1 
                    or sff.rn is null
                )
            order by 
                se2.kprogprovid desc
            '
        ) t

END
GO
