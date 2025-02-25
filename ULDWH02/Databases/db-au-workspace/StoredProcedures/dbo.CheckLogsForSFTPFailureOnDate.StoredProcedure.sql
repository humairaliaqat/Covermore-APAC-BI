USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[CheckLogsForSFTPFailureOnDate]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[CheckLogsForSFTPFailureOnDate]
	@dayoffset int = 0,
	@specificDate date = NULL
AS
BEGIN
	-- 
	DECLARE @date date

	-- for debugging, lets you specify a date to check the logs
	IF @specificDate IS NOT NULL
		SET @date = @specificDate
	ELSE
		SET @date = GETDATE() - @dayoffset

	PRINT CONCAT('Checking logs on the following day: ', @date)

	/*
	=============================================
	Author:		Oscar Gardner
	Create date: 27 Sep 2022
	Description: Detects SFTP transfer fails that occured on a specified day
	Update Log:
		27 Sep 2022 - OG - Initial working stored procedure.
	=============================================
	
	The @dayoffset input parameter determines which day to check the logfiles for. 
	For example: 
	- default @dayoffset of 0 means that the stored procedure checks Today's logs
	- offset of 1 checks yesterday's logs

	The @specificDate input paramater is for debugging to check the logs for a specific date. Example could be the value: '2022-05-05'

	It detects SFTP failures this by searching the logs (located at \\ulwibs01.aust.dmz.local\SFTPLog) for the 'SFTP Failure' string. 
	For future reference, the logs are generated based on the output of the WINSCPAutomateUpload.js script. Also note that there is a 
		version of this script for every customer but they all output the same messages when SFTP failures occur.

	'SFTP Failure' string indicates a specific edge-case:
	- one or more files could not be transfered due to either a connection issue or an authentication issue to the destination server

	This code is designed to be used as part of a TSQL job step. Here's the 3 possible states:
	1. command successfully ran, no SFTP failures found
	- Job step SUCCEEDS
	2. command successfully ran, 1 or more SFTP failures found
	- Job step FAILS, and error message indicates which files (e.g. IAG_NZ\20220905.log) to investigate further
	3. command fails to run
	- Job step FAILS, and error message indicates why the command failed
	*/


	-- creates the command string, which will find any logfiles for yesterday that contain the "SFTP Failure" message 
	DECLARE @command varchar(500) = 'pushd \\ulwibs01.aust.dmz.local\SFTPLog && findstr /I /M /S /C:"SFTP Failure" ' + convert(varchar, @date, 112) + '.log & popd'

	-- temp table used for storing standard output from the executed command
	IF OBJECT_ID(N'tempdb..#tmpSFTPResultTable') IS NOT NULL
		DROP TABLE #tmpSFTPResultTable

	CREATE TABLE #tmpSFTPResultTable (output varchar(1000))
	DECLARE @exitCode int;  

	-- runs the command, loading standard output into a table and saving the exit code to a variable
	INSERT INTO #tmpSFTPResultTable 
	EXEC @exitCode = xp_cmdshell @command


	DECLARE @successMessage VARCHAR(500) = 'No errors occurred during the SFTP transfers, or no transfers occurred.'

	DECLARE @errorMessageStart VARCHAR(500) = '
	\\ulwibs01.aust.dmz.local\SFTPLog
	The following customers have had errors appear, indicating that the SFTP transfer failed on that day either due to a connection issue or an authentication issue to the destination server:

	'
	DECLARE @cmdOutputLinesAsString VARCHAR(8000)

	-- the command output turns standard output into an [output] column where each row is a line. 
	-- The following code turns this into a single string that contains all the lines joined by a newline character. 
	-- This was the best way I could find in TSQL to do this
	SELECT 
		@cmdOutputLinesAsString = SUBSTRING(
			(
				SELECT [output] + CHAR(10) -- line feed character, \n
				FROM #tmpSFTPResultTable
				FOR XML PATH('')
			)
			,
			0,99999999)

		

	-- if the command failed to execute successfully, halt and print debug information
	IF (@exitCode != 0)
		BEGIN
			PRINT 'The command failed to execute correctly. See error message for more details.';
			THROW 50000, @cmdOutputLinesAsString, 1;
		END
	
	-- count how many non-null lines were output from the command
	DECLARE @resultCount int

	SELECT @resultCount = COUNT([output]) 
	FROM #tmpSFTPResultTable
	WHERE [output] IS NOT NULL

	-- if there's one or more non-null lines output by the command, it indicates that the command found at least one logfile that contains a record of a SFTP transfer failure. 
	IF @resultCount > 0
		BEGIN
			PRINT @errorMessageStart;
			THROW 50000, @cmdOutputLinesAsString, 1;
		END
	ELSE
		PRINT @successMessage;

END
GO
