USE [master]
GO
/****** Object:  Database [db-au-bobj]    Script Date: 21/02/2025 11:29:09 AM ******/
CREATE DATABASE [db-au-bobj]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'db-au-bobj', FILENAME = N'H:\SQLData\db-au-bobj.mdf' , SIZE = 1318912KB , MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB )
 LOG ON 
( NAME = N'db-au-bobj_log', FILENAME = N'F:\SQLLog\db-au-bobj_log.ldf' , SIZE = 1048576KB , MAXSIZE = 2048GB , FILEGROWTH = 131072KB )
GO
ALTER DATABASE [db-au-bobj] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [db-au-bobj].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [db-au-bobj] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [db-au-bobj] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [db-au-bobj] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [db-au-bobj] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [db-au-bobj] SET ARITHABORT OFF 
GO
ALTER DATABASE [db-au-bobj] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [db-au-bobj] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [db-au-bobj] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [db-au-bobj] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [db-au-bobj] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [db-au-bobj] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [db-au-bobj] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [db-au-bobj] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [db-au-bobj] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [db-au-bobj] SET  DISABLE_BROKER 
GO
ALTER DATABASE [db-au-bobj] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [db-au-bobj] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [db-au-bobj] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [db-au-bobj] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [db-au-bobj] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [db-au-bobj] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [db-au-bobj] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [db-au-bobj] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [db-au-bobj] SET  MULTI_USER 
GO
ALTER DATABASE [db-au-bobj] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [db-au-bobj] SET DB_CHAINING OFF 
GO
ALTER DATABASE [db-au-bobj] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [db-au-bobj] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [db-au-bobj] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'db-au-bobj', N'ON'
GO
ALTER DATABASE [db-au-bobj] SET QUERY_STORE = OFF
GO
USE [db-au-bobj]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE [db-au-bobj] SET  READ_WRITE 
GO
