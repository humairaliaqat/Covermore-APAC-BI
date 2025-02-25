USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt_0837_orbit]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE proc [dbo].[rptsp_rpt_0837_orbit]  
    @DateRange varchar(30),  
    @StartDate date,  
    @EndDate date    
as  
/*This proc has been created based on exising 0837 rpt for Orbit Protect -----Siddhesh Shinde */  
begin  
  
   set nocount on  

declare 
   @rptStartDate date,  
        @rptEndDate date;
       
	    if @DateRange = '_User Defined'  
            select   
                @rptStartDate = @StartDate,   
                @rptEndDate = @EndDate  
        else  
            select   
                @rptStartDate = StartDate,  
                @rptEndDate = EndDate  
            from   
                [db-au-cmdwh].dbo.vDateRange  
            where   
                DateRange = @DateRange 
				  
if object_id('tempdb..#transaction') is not null  
        drop table #transaction  
  
    select   
        'NZ' Country,  
        'Policy' TransactionType,  
        p.Policy_Number TransactionReference,  
        p.Policy_start_date TransactionDate,  
        --p.PolicyKey,  
        --ptv.PolicyTravellerKey Reference,  
        p.Country CustomerName,  
        p.DOB
    into #transaction  
   from  
        [db-au-cmdwh].dbo.orbit_policies p with(nolock)  
    where  
        convert(date,p.insertion_date) >= @rptStartDate  and
		convert(date,p.insertion_date) <  dateadd(day, 1, @rptEndDate)
		  
  
    union all  
  
    select   
        'NZ' Country,  
        'Claim' TransactionType,  
        cp.Claim_Number TransactionReference,  
        cp.claim_created,  
        --pt.PolicyKey,  
        --cn.NameKey Reference,  
        cp.Customer_Name CustomerName,  
        cp.DOB   
    from  
        [db-au-cmdwh].dbo.orbit_claims cp with(nolock)  
    where  
        --convert(varchar(20),cp.insertion_date,23) = convert(varchar(20),GETDATE(),23)  
		convert(date,cp.insertion_date) >= @rptStartDate  and
		convert(date,cp.insertion_date) <  dateadd(day, 1, @rptEndDate)
		
  
    ;with  
    cte_transaction as  
    (  
        select   
            t.Country,  
            t.TransactionType,  
            t.TransactionReference,  
            t.TransactionDate,  
            --t.PolicyKey,  
            --t.Reference MDMReference,  
            t.CustomerName,  
            t.DOB,  
            ns.Reference,  
            ns.NameScore,  
            isnull(ds.DOBScore, 1) DOBScore,  --changed from 0 to 1
            ns.NameScore * ISNULL(ds.DOBScore,1) Score
			     
        from  
            #transaction t  
            outer apply  
            (  
                select  
                    esn.Country,  
                    esn.Reference,  
                    sum  
                    (  
                        case  
                            when esn.LastName = 1 and nf.LastName = 1 then 5  
                            else 1  
                        end   
                    ) NameScore  
                from  
                    (  
                        select  
                            NameFragment,  
                            max(LastName) LastName  
                        from  
                            (  
                                select  
                                    isnull([db-au-workspace].dbo.fn_RemoveSpecialChars(r.Item), r.Item) NameFragment,  
                                    case  
                                        when r.ItemNumber = max(r.ItemNumber) over () then 1  
                                        else 0  
                                    end LastName  
                                from  
                                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(replace(t.CustomerName, '-', ''), ' ')  r  
                            ) nf  
                        group by  
                            NameFragment  
                    ) nf  
                    inner join [db-au-cmdwh]..entSanctionedNames esn on  
                        esn.Country = t.Country and  
                        esn.NameFragment = nf.NameFragment  
                group by  
                    esn.Country,  
                    esn.Reference  
  
            ) ns  
            outer apply  
            (  
                select top 1  
                    case  
                        when datediff(day, t.DOB, esd.DOB) = 0 then 5  
                        when abs(datediff(day, t.DOB, esd.DOB)) = 1 then 3  
                        when datepart(month, t.DOB) = esd.MOB then 2  
                        else 1  
                    end DOBScore  
                from  
                    [db-au-cmdwh]..entSanctionedDOB esd   
                where  
                    esd.Country = ns.Country and  
                    esd.Reference = ns.Reference and  
                    esd.YOBStart <= datepart(year, t.DOB) and  
                    esd.YOBEnd >= datepart(year, t.DOB)  
                order by DOBScore desc  
            ) ds  
    ),  
    cte_customer as  
    (  
        select   
            Country,  
            TransactionType,  
            TransactionReference,  
            TransactionDate,  
            --PolicyKey,  
            --MDMReference,  
            CustomerName,  
            DOB,  
            max(Score) Score
			 
        from  
            cte_transaction  
        where  
            Score >= 5  
        group by  
            Country,  
            TransactionType,  
            TransactionDate,  
            TransactionReference,  
            --MDMReference,  
            --PolicyKey,  
            CustomerName,  
            DOB  
    ),  
    cte_highlight as  
    (  
        select   
            *,  
            (  
                select distinct  
                    Reference + ','  
                from  
                    cte_transaction r  
                where  
                    r.Country = t.Country and  
                    r.TransactionReference = t.TransactionReference and  
                    r.TransactionType = t.TransactionType and  
                    r.Score >= 5  
                for xml path('')  
            ) Refs  
        from  
            cte_customer t  
    )  
    select   
        *,  
        case  
            when Score < 10 then 'Low risk, matched last name and year of birth'  
            when Score < 15 then 'Low risk, matched last name, year and month of birth'  
            when Score < 25 then 'Low risk, matched combination of names, within 1 day variance of date of birth'  
            when Score < 30 then 'Medium risk, matched last name, same date of birth'  
            else 'High risk, matched combination of names, same data of birth'  
        end Risk,
		@rptStartDate as StartDate,  
        @rptEndDate as EndDate   
    from  
        cte_highlight t  
        --outer apply  
        --(  
        --    select top 1   
        --        CustomerID  
        --    from  
        --        entPolicy ep  
        --    where  
        --        ep.PolicyKey = t.PolicyKey and  
        --        ep.Reference = t.MDMReference  
        --) ep  
    order by  
        Country,  
        Score desc,  
        TransactionType,  
        TransactionReference desc  
  
end  
  
  
GO
