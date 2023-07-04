-- TOMCART Internal Database
-- used for Reconciliation
-- ---
-- This script needs to be run on a user with the SQL Database Administrator.


-- ------------------------------------
-- -- DROP existing database objects --
-- ------------------------------------

USE [master]                                                                                                                                                                                     
GO                                                                                                                                                                                               

IF EXISTS(select * from sys.syslogins WHERE loginname='ReconUser')                                            
DROP LOGIN [ReconUser]
GO

IF EXISTS(select * from sys.databases where name='TestAutomation')
DROP DATABASE [TestAutomation]                                                                                                                                                                   
GO                                                                                                                                                                                               


-- --------------------------------------------------------
-- -- SETTING on the SQL Server (database-wide settings) --
-- --------------------------------------------------------                                                                                                                                                                                               


IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'show advanced options' AND value = 1)
BEGIN
    EXEC sp_configure 'show advanced options', 1
    RECONFIGURE WITH OVERRIDE
END

IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'xp_cmdshell' AND value = 1)
BEGIN
    EXEC sp_configure 'xp_cmdshell', 1
    RECONFIGURE WITH OVERRIDE
END

IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries' AND value = 1)
BEGIN
    EXEC sp_configure 'Ad Hoc Distributed Queries', 1
    RECONFIGURE WITH OVERRIDE
END



-- --------------------------------------
-- -- SETTING on the [master] database --
-- --------------------------------------
                                                                                                                                                                                                 
                                                                                                                                                                                                 
CREATE DATABASE [TestAutomation]                                                                                                                                                                 
 CONTAINMENT = NONE                                                                                                                                                                              
 ON  PRIMARY                                                                                                                                                                                     
( NAME = N'TestAutomation9', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\TestAutomation2.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )  
 LOG ON                                                                                                                                                                                          
( NAME = N'TestAutomation9_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\TestAutomation2_log.ldf' , SIZE = 1536KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET COMPATIBILITY_LEVEL = 120                                                                                                                                    
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))                                                                                                                                          
begin                                                                                                                                                                                            
EXEC [TestAutomation].[dbo].[sp_fulltext_database] @action = 'enable'                                                                                                                            
end                                                                                                                                                                                              
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET ANSI_NULL_DEFAULT OFF                                                                                                                                        
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET ANSI_NULLS OFF                                                                                                                                               
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET ANSI_PADDING OFF                                                                                                                                             
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET ANSI_WARNINGS OFF                                                                                                                                            
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET ARITHABORT OFF                                                                                                                                               
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET AUTO_CLOSE OFF                                                                                                                                               
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET AUTO_SHRINK OFF                                                                                                                                              
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET AUTO_UPDATE_STATISTICS ON                                                                                                                                    
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET CURSOR_CLOSE_ON_COMMIT OFF                                                                                                                                   
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET CURSOR_DEFAULT  GLOBAL                                                                                                                                       
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET CONCAT_NULL_YIELDS_NULL OFF                                                                                                                                  
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET NUMERIC_ROUNDABORT OFF                                                                                                                                       
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET QUOTED_IDENTIFIER OFF                                                                                                                                        
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET RECURSIVE_TRIGGERS OFF                                                                                                                                       
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET  DISABLE_BROKER                                                                                                                                              
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET AUTO_UPDATE_STATISTICS_ASYNC OFF                                                                                                                             
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET DATE_CORRELATION_OPTIMIZATION OFF                                                                                                                            
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET TRUSTWORTHY OFF                                                                                                                                              
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET ALLOW_SNAPSHOT_ISOLATION OFF                                                                                                                                 
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET PARAMETERIZATION SIMPLE                                                                                                                                      
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET READ_COMMITTED_SNAPSHOT OFF                                                                                                                                  
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET HONOR_BROKER_PRIORITY OFF                                                                                                                                    
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET RECOVERY SIMPLE                                                                                                                                              
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET  MULTI_USER                                                                                                                                                  
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET PAGE_VERIFY CHECKSUM                                                                                                                                         
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET DB_CHAINING OFF                                                                                                                                              
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF )                                                                                                                    
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET TARGET_RECOVERY_TIME = 0 SECONDS                                                                                                                             
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET DELAYED_DURABILITY = DISABLED                                                                                                                                
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
ALTER DATABASE [TestAutomation] SET  READ_WRITE                                                                                                                                                  
GO                                                                                                                                                                                               
                                                                                                                                                                                                 
                        
                        
                                                                                                                                                                                          
CREATE LOGIN [ReconUser] WITH PASSWORD=N'ReconUser1234', DEFAULT_DATABASE=[TestAutomation], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO                                                                                                                                                                                              
                                                                                                                                                                
ALTER LOGIN [ReconUser] ENABLE                                                                                                                                                                 
GO                                                                                                                                                                                              

                          

-- ----------------------------------------------
-- -- SETTING on the [TestAutomation] database --
-- ----------------------------------------------
                          
USE [TestAutomation]
GO

CREATE USER [ReconUser] FOR LOGIN [ReconUser] WITH DEFAULT_SCHEMA=[dbo]
GO

ALTER ROLE [db_datareader] ADD MEMBER [ReconUser]
GO
USE [TestAutomation]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [ReconUser]
GO
USE [TestAutomation]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [ReconUser]
GO
USE [TestAutomation]
GO
ALTER ROLE [db_owner] ADD MEMBER [ReconUser]
GO




                                                                                                                                                                      
                         
                         
                                                                                                                                                                                                