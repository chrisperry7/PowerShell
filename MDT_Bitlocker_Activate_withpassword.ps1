#Check BitLocker AD Key backup Registry values exist and if not, create them.
$BitLockerRegLoc = 'HKLM:\SOFTWARE\Policies\Microsoft'

New-Item -Path "$BitLockerRegLoc" -Name 'FVE'
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'EnableBDEWithNoTPM' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'ActiveDirectoryBackup' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'ActiveDirectoryInfoToStore' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSActiveDirectoryBackup' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSActiveDirectoryInfoToStore' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSHideRecoveryPage' -Value '00000000' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSManageDRA' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSRecovery' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSRecoveryKey' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSRecoveryPassword' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSRequireActiveDirectoryBackup' -Value '00000000' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'RequireActiveDirectoryBackup' -Value '00000000' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSPassphrase' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSPassphraseASCIIOnly' -Value '00000000' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSPassphraseComplexity' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'OSPassphraseLength' -Value '00000008' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVActiveDirectoryBackup' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVActiveDirectoryInfoToStore' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVEnforcePassphrase' -Value '00000000' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVHideRecoveryPage' -Value '00000000' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FRVManageDRA' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVPassphrase' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVPassphraseComplexity' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVPassphraseLength' -Value '00000008' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVRecovery' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVRecoveryKey' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVRecoveryPassword' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVRequireActiveDirectoryBackup' -Value '00000000' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'RDVEnforcePassphrase' -Value '00000000' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'RDVNoBitLockerToGoReader' -Value '00000000' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'RDVPassphrase' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'RDVPassphrasaeComplexity' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'RDVPassphraseLength' -Value '00000008' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'UseAdvancedStartup' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'UseEnhancedPin' -Value '00000001' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'UseTPM' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'UseTPMKey' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'UseTPMKeyPIN' -Value '00000002' -PropertyType DWORD
New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'UseTPMPIN' -Value '00000002' -PropertyType DWORD

$pin = ConvertTo-SecureString "Password_here" -AsPlainText -Force
Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -PasswordProtector $pin 
sleep(10)
manage-bde -protectors -add C: -recoverypassword
sleep(10)
$RecoveryKeyGUID = (Get-BitLockerVolume -MountPoint $env:SystemDrive).keyprotector | where {$_.Keyprotectortype -eq 'RecoveryPassword'} | Select-Object -ExpandProperty KeyProtectorID
manage-bde.exe  -protectors $env:SystemDrive -adbackup -id $RecoveryKeyGUID
