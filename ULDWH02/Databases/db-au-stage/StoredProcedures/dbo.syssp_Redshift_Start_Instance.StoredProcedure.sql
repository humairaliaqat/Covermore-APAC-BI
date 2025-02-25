USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[syssp_Redshift_Start_Instance]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[syssp_Redshift_Start_Instance]
as



/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160704
Prerequisite:   Requires AWSCLI installed and configured correctly on ULDWH01;
				Requires a final snapshot was created;
				Requires Redshift Cluster is not running                
Description:    This stored proc checks if Cluster is running or not. If it is not running, then start Redshift cluster using Finalsnapshot
Change History:
                20160704 - LT - Procedure created
 
*************************************************************************************************************************************/

declare @SQL varchar(8000)

if object_id('tempdb..##redshift_cluster_check') is not null drop table ##redshift_cluster_check
create table ##redshift_cluster_check (ClusterDescription varchar(8000) null)

select @SQL = 'master..xp_cmdshell ''"c:\program files\amazon\awscli\aws.exe" redshift describe-clusters --output text'''

insert ##redshift_cluster_check
exec(@SQL)


if (select top 1 * from ##redshift_cluster_check) is null
begin
	select @SQL = 'master..xp_cmdshell ''"c:\program files\amazon\awscli\aws.exe" redshift restore-from-cluster-snapshot --cluster-identifier cmdwh-redshift-prod --snapshot-identifier cmdwh-prod-finalsnapshot --cluster-subnet-group-name cm-dev-bi-red --no-publicly-accessible --vpc-security-group-ids sg-db3be9be'''
	exec(@SQL)
end
else
	raiserror('Cluster is active. Nothing to start',20,-1) with log

--drop temp table
drop table ##redshift_cluster_check


GO
