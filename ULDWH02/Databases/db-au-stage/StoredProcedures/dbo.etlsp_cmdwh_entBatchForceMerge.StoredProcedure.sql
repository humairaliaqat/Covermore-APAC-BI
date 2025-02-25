USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entBatchForceMerge]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entBatchForceMerge]
    @Mode varchar(max) = 'AllModes'

as
begin

    declare
        @customer nvarchar(max),
        @firstname nvarchar(max),
        @dob date,
        @email nvarchar(max),
        @contact nvarchar(max),
        @address nvarchar(max),
        @cids varchar(max),
        @policykey varchar(50),
        @idtype varchar(250),
        @idvalue varchar(250),
        @i int,
        @err varchar(max)


    if @Mode like '%AllModes%' or @Mode like '%NamePolicy%' 
    begin

        declare c_name_policy cursor local for
            select top 200
                ep.PolicyKey,
                ec.CustomerName
                --,count(distinct ec.CustomerID)
                --,sum(ec.PrimaryScore)
            from
                [db-au-cmdwh]..entCustomer ec with(nolock)
                inner join [db-au-cmdwh]..entPolicy ep with(nolock) on
                    ep.CustomerID = ec.CustomerID
            where
                ec.CustomerID = ec.MergedTo and
                ec.CUstomerName is not null and
                len(ec.CUstomerName) > 1 and
                ec.CUstomerName not in ('Premiers', 'Test', 'Group', 'UAT')
            group by
                ep.PolicyKey,
                ec.CustomerName
            having 
                count(distinct ec.CustomerID) > 1
            order by
                count(distinct ec.CustomerID) desc,
                sum(ec.PrimaryScore) desc

        open c_name_policy

        fetch next 
        from 
            c_name_policy 
        into 
            @policykey,
            @customer

        set @i = 1

        while @@fetch_status = 0
        begin

            set @cids = ''

            select
                @cids = @cids + convert(varchar(max), ec.CustomerID) + ','
            from
                [db-au-cmdwh]..entCustomer ec with(nolock)
                inner join [db-au-cmdwh]..entPolicy ep with(nolock) on
                    ep.CustomerID = ec.CustomerID
            where
                ec.CUstomerName = @customer and
                ep.PolicyKey = @policykey

            --print @cids

            exec [db-au-stage]..[etlsp_cmdwh_entMergeCustomer]
                @CIDs = @cids,
                @Batch = 1,
                @MergeOnly = 0

            set @err = convert(varchar, @i)
            raiserror(@err, 1, 1) with nowait
            set @i = @i + 1

            fetch next 
            from 
                c_name_policy 
            into 
                @policykey,
                @customer

        end

        close c_name_policy
        deallocate c_name_policy

    end

    if @Mode like '%AllModes%' or @Mode like '%NameIdentity%' 
    begin

        declare c_name_identity cursor local for
            select top 100
                ei.IDType,
                ei.IDValue,
                ec.CustomerName
                --,count(distinct ec.CustomerID)
                --,sum(ec.PrimaryScore)
            from
                [db-au-cmdwh]..entCustomer ec with(nolock)
                inner join [db-au-cmdwh]..entIdentity ei with(nolock) on
                    ei.CustomerID = ec.CustomerID
            where
                ec.CustomerID = ec.MergedTo and
                ec.CUstomerName is not null and
                len(ei.IDValue) > 1 and
                ec.CUstomerName not in ('Premiers', 'Test', 'Group', 'UAT', 'First Last') and
                (
                    IDType <> 'Companion' or
                    len(IDValue) > 4
                ) and
                IDValue not like '1234%' and
                IDValue not like '0000%'
            group by
                ei.IDType,
                ei.IDValue,
                ec.CustomerName
            having 
                count(distinct ec.CustomerID) > 1
            order by
                count(distinct ec.CustomerID) desc,
                sum(ec.PrimaryScore) desc

        open c_name_identity

        fetch next 
        from 
            c_name_identity 
        into 
            @idtype,
            @idvalue,
            @customer

        set @i = 1

        while @@fetch_status = 0
        begin

            set @cids = ''

            select
                @cids = @cids + convert(varchar(max), ec.CustomerID) + ','
            from
                [db-au-cmdwh]..entCustomer ec with(nolock)
                inner join [db-au-cmdwh]..entIdentity ei with(nolock) on
                    ei.CustomerID = ec.CustomerID
            where
                ei.IDType = @idtype and
                ei.IDValue = @idvalue and
                ec.CUstomerName = @customer

            --print @cids

            exec [db-au-stage]..[etlsp_cmdwh_entMergeCustomer]
                @CIDs = @cids,
                @Batch = 1,
                @MergeOnly = 0

            set @err = convert(varchar, @i)
            raiserror(@err, 1, 1) with nowait
            set @i = @i + 1

            fetch next 
            from 
                c_name_identity 
            into 
                @idtype,
                @idvalue,
                @customer

        end

        close c_name_identity
        deallocate c_name_identity

    end

    if @Mode like '%AllModes%' or @Mode like '%NameDOBContactEmail%' 
    begin

        declare c_dob_contact_email cursor local for
            select top 50
                CUstomerName,
                DOB,
                CurrentContact,
                CurrentEmail
                --,
                --count(CustomerID) RecCount
            from
                [db-au-cmdwh]..entCustomer with(nolock)
            where
                CustomerID = MergedTo and
                CustomerName not in ('Premiers', 'Test', 'Group', 'UAT') and
                MergedTo = CustomerID and
                len(CustomerName) > 1 and
                DOB is not null and
                (
                    datepart(day, DOB) <> 1 or
                    datepart(month, DOB) <> 1
                ) and
                CurrentContact <> '' and
                CurrentEmail <> ''
            group by
                CUstomerName,
                DOB,
                CurrentContact,
                CurrentEmail
            having
                count(CustomerID) > 1
            order by 
                count(CustomerID) desc,
                sum(PrimaryScore) desc

        open c_dob_contact_email

        fetch next 
        from 
            c_dob_contact_email 
        into 
            @customer,
            @dob,
            @contact,
            @email

        set @i = 1

        while @@fetch_status = 0
        begin

            set @cids = ''

            select
                @cids = @cids + convert(varchar(max), CustomerID) + ','
            from
                [db-au-cmdwh]..entCustomer with(nolock)
            where
                CUstomerName = @customer and
                DOB = @dob and
                CurrentContact = @contact and
                CurrentEmail = @email

            --print @cids

            exec [db-au-stage]..[etlsp_cmdwh_entMergeCustomer]
                @CIDs = @cids,
                @Batch = 1,
                @MergeOnly = 0

            set @err = convert(varchar, @i)
            raiserror(@err, 1, 1) with nowait
            set @i = @i + 1

            fetch next 
            from 
                c_dob_contact_email 
            into 
                @customer,
                @dob,
                @contact,
                @email

        end

        close c_dob_contact_email
        deallocate c_dob_contact_email

    end


    if @Mode like '%AllModes%' or @Mode like '%FirstNameDOBAddressContactEmail%' 
    begin
        declare c_firstname cursor local for
            select top 100
                Firstname,
                DOB,
                CurrentAddress,
                CurrentEmail,
                CurrentContact
                --,count(CustomerID) RecCount
            from
                [db-au-cmdwh]..entCustomer with(nolock)
            where
                CustomerID = MergedTo and
                MergedTo = CustomerID and
                FirstName is not null and
                DOB is not null and
                (
                    datepart(day, DOB) <> 1 or
                    datepart(month, DOB) <> 1
                ) and
                CurrentAddress <> '' and
                CurrentContact <> '' and
                CurrentEmail <> ''
            group by
                Firstname,
                DOB,
                CurrentAddress,
                CurrentEmail,
                CurrentContact
            having
                count(CustomerID) > 1
            order by
                count(CustomerID) desc,
                sum(PrimaryScore) desc

        open c_firstname

        fetch next 
        from 
            c_firstname 
        into 
            @firstname,
            @dob,
            @address,
            @email,
            @contact

        set @i = 1

        while @@fetch_status = 0
        begin

            set @cids = ''

            select
                @cids = @cids + convert(varchar(max), CustomerID) + ','
            from
                [db-au-cmdwh]..entCustomer with(nolock)
            where
                FirstName = @firstname and
                DOB = @dob and
                CurrentAddress = @address and
                CurrentContact = @contact and
                CurrentEmail = @email

            --print @cids

            exec [db-au-stage]..[etlsp_cmdwh_entMergeCustomer]
                @CIDs = @cids,
                @Batch = 1,
                @MergeOnly = 0

            set @err = convert(varchar, @i)
            raiserror(@err, 1, 1) with nowait
            set @i = @i + 1

            fetch next 
            from 
                c_firstname 
            into 
                @firstname,
                @dob,
                @address,
                @email,
                @contact

        end

        close c_firstname
        deallocate c_firstname

    end

    if @Mode like '%AllModes%' or @Mode like '%NameContactEmailAddress%' 
    begin

        declare c_non_dob cursor local for
	        select top 50
		        CUstomerName,
		        CurrentContact,
		        CurrentEmail,
		        CurrentAddress
		        --,
		        --count(CustomerID) RecCount
	        from
		        [db-au-cmdwh]..entCustomer with(nolock)
	        where
                CustomerID = MergedTo and
		        MergedTo = CustomerID and
		        CurrentContact <> '' and
		        CurrentEmail <> '' and
		        CurrentAddress <> ''
	        group by
		        CUstomerName,
		        CurrentContact,
		        CurrentEmail,
		        CurrentAddress
	        having
		        count(CustomerID) > 1
	        order by 
		        count(CustomerID) desc,
                sum(PrimaryScore) desc

        open c_non_dob

        fetch next 
        from 
            c_non_dob 
        into 
            @customer,
            @contact,
            @email,
	        @address

        set @i = 1

        while @@fetch_status = 0
        begin

            set @cids = ''

            select
                @cids = @cids + convert(varchar(max), CustomerID) + ','
            from
                [db-au-cmdwh]..entCustomer
            where
                CUstomerName = @customer and
                CurrentContact = @contact and
                CurrentEmail = @email and
		        CurrentAddress = @address

            --print @cids

            exec [db-au-stage]..[etlsp_cmdwh_entMergeCustomer]
                @CIDs = @cids,
                @Batch = 1,
                @MergeOnly = 0

            set @err = convert(varchar, @i)
            raiserror(@err, 1, 1) with nowait
            set @i = @i + 1

            fetch next 
            from 
                c_non_dob 
            into 
		        @customer,
		        @contact,
		        @email,
		        @address

        end

        close c_non_dob
        deallocate c_non_dob

    end

    if @Mode like '%AllModes%' or @Mode like '%NameDOBAddress%' 
    begin

        declare c_dob_address cursor local for
            select top 50
                CUstomerName,
                DOB,
                CurrentAddress
		        --,
                --count(CustomerID) RecCount
            from
                [db-au-cmdwh]..entCustomer with(nolock)
            where
                MergedTo = CustomerID and
                charindex(' ', CustomerName) > 0 and
                DOB is not null and
                (
                    datepart(day, DOB) <> 1 or
                    datepart(month, DOB) <> 1
                ) and
                CurrentAddress <> ''
            group by
                CUstomerName,
                DOB,
                CurrentAddress
            having
                count(CustomerID) > 1
            order by 
                count(CustomerID) desc,
                sum(PrimaryScore) desc

        open c_dob_address

        fetch next 
        from 
            c_dob_address 
        into 
            @customer,
            @dob,
	        @address

        set @i = 1

        while @@fetch_status = 0
        begin

            set @cids = ''

            select
                @cids = @cids + convert(varchar(max), CustomerID) + ','
            from
                [db-au-cmdwh]..entCustomer
            where
                CUstomerName = @customer and
                DOB = @dob and
		        CurrentAddress = @address

            --print @cids

            exec [db-au-stage]..[etlsp_cmdwh_entMergeCustomer]
                @CIDs = @cids,
                @Batch = 1,
                @MergeOnly = 0

            set @err = convert(varchar, @i)
            raiserror(@err, 1, 1) with nowait
            set @i = @i + 1

            fetch next 
            from 
                c_dob_address 
            into 
		        @customer,
		        @dob,
		        @address

        end

        close c_dob_address
        deallocate c_dob_address

    end


    if @Mode like '%AllModes%' or @Mode like '%NameDOBEmail%' 
    begin

        declare c_dob_email cursor local for
            select top 50
                CUstomerName,
                DOB,
                CurrentEmail
                --,
                --count(CustomerID) RecCount
            from
                [db-au-cmdwh]..entCustomer with(nolock)
            where
                MergedTo = CustomerID and
                charindex(' ', CustomerName) > 0 and
                DOB is not null and
                (
                    datepart(day, DOB) <> 1 or
                    datepart(month, DOB) <> 1
                ) and
                CurrentEmail <> ''
            group by
                CUstomerName,
                DOB,
                CurrentEmail
            having
                count(CustomerID) > 1
            order by 
                count(CustomerID) desc,
                sum(PrimaryScore) desc

        open c_dob_email

        fetch next 
        from 
            c_dob_email 
        into 
            @customer,
            @dob,
	        @email

        set @i = 1

        while @@fetch_status = 0
        begin

            set @cids = ''

            select
                @cids = @cids + convert(varchar(max), CustomerID) + ','
            from
                [db-au-cmdwh]..entCustomer
            where
                CUstomerName = @customer and
                DOB = @dob and
		        CurrentEmail = @email

            --print @cids

            exec [db-au-stage]..[etlsp_cmdwh_entMergeCustomer]
                @CIDs = @cids,
                @Batch = 1,
                @MergeOnly = 0

            set @err = convert(varchar, @i)
            raiserror(@err, 1, 1) with nowait
            set @i = @i + 1

            fetch next 
            from 
                c_dob_email 
            into 
		        @customer,
		        @dob,
		        @email

        end

        close c_dob_email
        deallocate c_dob_email

    end

    --exec [db-au-stage]..[etlsp_cmdwh_entMergeCustomer]
    --    @CIDs = @cids,
    --    @Batch = 0,
    --    @MergeOnly = 1

    --exec msdb.dbo.sp_start_job 
    --    @job_name = N'ETL073_MDM_Enterprise',
    --    @step_name = N'Create Batch'






    --select top 1000
    --    CUstomerName,
    --    DOB,
    --    CurrentContact
    --    ,
    --    count(CustomerID) RecCount
    --from
    --    entCustomer with(nolock)
    --where
    --    MergedTo = CustomerID and
    --    charindex(' ', CustomerName) > 0 and
    --    DOB is not null and
    --    (
    --        datepart(day, DOB) <> 1 or
    --        datepart(month, DOB) <> 1
    --    ) and
    --    CurrentContact <> ''
    --group by
    --    CUstomerName,
    --    DOB,
    --    CurrentContact
    --having
    --    count(CustomerID) > 1
    --order by 
    --    count(CustomerID) desc


    --select top 1000
    --    CUstomerName,
    --    CurrentContact,
    --    CurrentEmail,
    --    count(CustomerID) RecCount
    --from
    --    entCustomer with(nolock)
    --where
    --    MergedTo = CustomerID and
    --    charindex(' ', CustomerName) > 0 and
    --    CurrentContact <> '' and
    --    CurrentEmail <> ''
    --group by
    --    CUstomerName,
    --    CurrentContact,
    --    CurrentEmail
    --having
    --    count(CustomerID) > 1
    --order by 
    --    count(CustomerID) desc



end
GO
