
USE AdventureWorks2019
GO

--Creacion de dispositivo
EXEC sp_addumpdevice 'disk', 'AwDv_AAreas',
'C:\1er Examen\AdventureWorks2019_Full.bak';
GO
---- Borrar el dispositivo
--EXEC sp_dropdevice 'AwDv_AAreas'
--GO

-- Nombre para el backups de forma dinamica
DECLARE @NameBackupsFull NVARCHAR(40) ='  ' + CONVERT(NVARCHAR(40), GETDATE(), 103) + '_Full'

-- Primer Backups 
BACKUP DATABASE AdventureWorks2019
TO AwDv_AAreas
WITH INIT, FORMAT, 
NAME = @NameBackupsFull,
DESCRIPTION  = 'AdventureWork_Backup_Full'
GO

sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

-- Create a Database Mail profile  
EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'Anielka',  
    @description = 'Perfil de Notificaciones administrador' ;  
GO

-- Grant access to the profile to the DBMailUsers role  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'Anielka',  
    @principal_name = 'public',  
    @is_default = 1 ;
GO

-- Create a Database Mail account  
EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'Anielka Areas',  
    @description = 'Correo de notificaciones',  
    @email_address = '27larios10raquel99@gmail.com',  
    @display_name = 'Administrador',  
    @mailserver_name = 'smtp-mail.outlook.com',
    @port = 587,
    @enable_ssl = 1,
    @username = '27larios10raquel99@gmail.com',
    @password = '' ;  
GO

-- Add the account to the profile  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'Anielka',  
    @account_name = 'Anielka Areas',  
    @sequence_number =1 ;
GO

--Trigger active alert change 

CREATE TRIGGER alert
ON production.ProductCategory 
AFTER INSERT, UPDATE, DELETE 
AS 
   EXEC msdb.dbo.sp_send_dbmail 
                        @profile_name = 'AnielkaRaquel', 
                        @recipients = 'williamjsg@gmail.com' , 
                        @body = 'Data in AdventureWorks2012 is changed', 
                        @subject = 'Your records have been changed' 
GO
