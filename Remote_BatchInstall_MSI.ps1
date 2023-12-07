$admin = Get-ADComputer -Filter "Name -like 'laptop*'"
foreach ($laptop in $admin.name){
	write-host "Testing " $laptop
	if (test-connection $laptop -Count 1 -Quiet){
		write-host $laptop
		Invoke-Command -ComputerName $laptop -ScriptBlock {mkdir "C:\Users\ITtemp"}
		copy-item "C:\temp\WGClient\WGClient.msi" -destination "\\$laptop\C$\Users\ITtemp"
		Invoke-Command -ComputerName $laptop -ScriptBlock {msiexec /i "C:\Users\ITtemp\WGClient.msi" /qn /norestart}
		Invoke-Command -ComputerName $laptop -ScriptBlock {rm "C:\Users\ITtemp" -r -force}
		}
	else {
		$failed = Get-ADComputer -Filter "Name -Like '$laptop'"
		$failed | export-csv "C:\temp\failedlft.csv" -append -notypeinformation
	}
}

$admin = import-csv "C:\temp\failedlft7.csv"
foreach ($laptop in $admin.name){
	write-host "Testing " $laptop
	if (test-connection $laptop -Count 1 -Quiet){
		write-host $laptop
		Invoke-Command -ComputerName $laptop -ScriptBlock {mkdir "C:\Users\ITtemp"}
		copy-item "C:\temp\WGClient\WGClient.msi" -destination "\\$laptop\C$\Users\ITtemp"
		Invoke-Command -ComputerName $laptop -ScriptBlock {msiexec /i "C:\Users\ITtemp\WGClient.msi" /qn /norestart}
		Invoke-Command -ComputerName $laptop -ScriptBlock {rm "C:\Users\ITtemp" -r -force}
		}
	else {
		$failed = Get-ADComputer -Filter "Name -Like '$laptop'"
		$failed | export-csv "C:\temp\failedlft8.csv" -append -notypeinformation
	}
}
