
#Array of registry DWORDS to loop through
$regarray0 = 'OSHideRecoveryPage','OSRequireActiveDirectoryBackup','RequireActiveDirectoryBackup','OSPassphraseASCIIOnly','FDVEnforcePassphrase','FDVHideRecoveryPage','FDVRequireActiveDirectoryBackup','RDVEnforcePassphrase','RDVNoBitLockerToGoReader'
$regarray1 = 'EnableBDEWithNoTPM','ActiveDirectoryBackup','OSActiveDirectoryBackup','OSManageDRA','OSRecovery','OSPassphrase','FDVActiveDirectoryBackup','FDVActiveDirectoryInfoToStore','FRVManageDRA','FDVPassphrase','FDVRecovery','RDVPassphrase','UseAdvancedStartup','UseEnhancedPin'
$regarray2 = 'ActiveDirectoryInfoToStore','OSActiveDirectoryInfoToStore','OSRecoveryKey','OSRecoveryPassword','OSPassphraseComplexity','FDVPassphraseComplexity','FDVRecoveryKey','FDVRecoveryPassword','RDVPassphrasaeComplexity','UseTPM','UseTPMKey','UseTPMKeyPIN','UseTPMPIN'



#Variable for registry key location
$BitLockerRegLoc = 'HKLM:\SOFTWARE\Policies\Microsoft'



#Check if registry key is created and create key if it doesn't exist
if (-not(get-itemproperty -path "$BitLockerRegLoc" -Name 'FVE' -ErrorAction SilentlyContinue)){
    New-Item -Path "$BitLockerRegLoc" -Name 'FVE' -ErrorAction SilentlyContinue
}


#Function to test if REG_DWORD exists
Function Test-RegistryValue {
    param(
        [Alias("PSPath")]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Path
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name
        ,
        [Switch]$PassThru
    ) 

    process {
        if (Test-Path $Path) {
            $Key = Get-Item -LiteralPath $Path
            if ($Key.GetValue($Name, $null) -ne $null) {
                if ($PassThru) {
                    Get-ItemProperty $Path $Name
                } else {
                    $true
                }
            } else {
                $false
            }
        } else {
            $false
        }
    }
}


#For loops that check if registry DWORD exists and either creates a new DWORD or edits an existing DWORD to the correct value
foreach ($i in $regarray0){
    if (-not(Test-RegistryValue -Path $BitLockerRegLoc\FVE -Name $i)){
        New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name $i -Value '00000000' -PropertyType DWORD -ErrorAction SilentlyContinue
    } 
    if (-not(get-itemproperty -Path "$BitLockerRegLoc\FVE" -name $i -ErrorAction SilentlyContinue).FDVPassphraseLength -ne 8){
        Set-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name $i -Value '00000000' -ErrorAction SilentlyContinue
    }
}

foreach ($i in $regarray1){
    if (-not(Test-RegistryValue -Path $BitLockerRegLoc\FVE -Name $i)){
        New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name $i -Value '00000001' -PropertyType DWORD -ErrorAction SilentlyContinue
    } 
    if (-not(get-itemproperty -Path "$BitLockerRegLoc\FVE" -name $i -ErrorAction SilentlyContinue).FDVPassphraseLength -ne 8){
        Set-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name $i -Value '00000001' -ErrorAction SilentlyContinue
    }
}

foreach ($i in $regarray2){
    if (-not(Test-RegistryValue -Path $BitLockerRegLoc\FVE -Name $i)){
        New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name $i -Value '00000002' -PropertyType DWORD -ErrorAction SilentlyContinue
    } 
    if (-not(get-itemproperty -Path "$BitLockerRegLoc\FVE" -name $i -ErrorAction SilentlyContinue).FDVPassphraseLength -ne 8){
        Set-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name $i -Value '00000002' -ErrorAction SilentlyContinue
    }
}


#Checks other registry DWORDs and creates or edits it depending on if it exists or not
if (-not(Test-RegistryValue -Path $BitLockerRegLoc\FVE -Name 'FDVPassphraseLength')){
    New-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVPassphraseLength' -Value '00000008' -PropertyType DWORD -ErrorAction SilentlyContinue
} 
if (-not(get-itemproperty -Path "$BitLockerRegLoc\FVE" -name 'FDVPassphraseLength' -ErrorAction SilentlyContinue).FDVPassphraseLength -ne 8){
    Set-ItemProperty -Path "$BitLockerRegLoc\FVE" -Name 'FDVPassphraseLength' -Value '00000008' -ErrorAction SilentlyContinue
}


#Enables bitlocker with a password, creating a backup key and storing it in Active Directory
$pin = ConvertTo-SecureString "Password here" -AsPlainText -Force
Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -PasswordProtector $pin 
sleep(10)
manage-bde -protectors -add C: -recoverypassword
sleep(10)
$RecoveryKeyGUID = (Get-BitLockerVolume -MountPoint $env:SystemDrive).keyprotector | where {$_.Keyprotectortype -eq 'RecoveryPassword'} | Select-Object -ExpandProperty KeyProtectorID
manage-bde.exe  -protectors $env:SystemDrive -adbackup -id $RecoveryKeyGUID