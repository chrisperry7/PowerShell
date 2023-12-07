$admin = Get-ADComputer -Filter "Name -like '*'" -searchbase "OU={ou}, OU={ou},DC={dc1},DC=local" -searchscope subtree
foreach ($laptop in $admin.name){
	If (!(test-connection $laptop -Count 1 -Quiet)){	
		$failed = Get-ADComputer -Filter "Name -Like '$laptop'"
		Write-Host "Adding" $laptop "to fail list"
		$failed | export-csv "C:\temp\BitLocklftFail1.csv" -append -notypeinformation	
		Continue
	}
    if (!(ipconfig | select-string "Windows IP Configuration" -Quiet)) {
			write-host "Attempting to add BitLocker on" $laptop "to AD"
			$failed = Get-ADComputer -Filter "Name -Like '$laptop'"
			Write-Host "Adding" $laptop "to fail list"
			$failed | export-csv "C:\temp\BitLocklftFail1.csv" -append -notypeinformation
			continue
	}
    If (Invoke-Command -ComputerName $laptop -ScriptBlock {$RecoveryKeyGUID = (Get-BitLockerVolume -MountPoint $env:SystemDrive).keyprotector | where {$_.Keyprotectortype -eq 'RecoveryPassword'} | Select-Object -ExpandProperty KeyProtectorID;
        manage-bde.exe  -protectors $env:SystemDrive -adbackup -id $RecoveryKeyGUID} | select-string "ERROR" -Quiet) {
        $failed = Get-ADComputer -Filter "Name -Like '$laptop'"
        Write-Host "Adding" $laptop "to fail list"
        $failed | export-csv "C:\temp\BitLocklftFail1.csv" -append -notypeinformation
    }
	else {
		Write-Host "***"$laptop "BitLocker recovery added to AD***"
	}
}

$admin = import-csv "C:\temp\BitLocklftFail2.csv"
