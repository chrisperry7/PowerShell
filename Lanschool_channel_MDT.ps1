$computer = $(hostname)

if ($computer -like "computer-*")
{
    $channel_number = 100
    $hex = [Convert]::ToString($channel_number, 16)
    $final_hex = $hex
    while ($final_hex.Length -ne  8)
    {
        $final_hex = "0" + $final_hex
    }
}

elseif ($computer -like "laptop-*")
{
    $channel_number = 101
    $hex = [Convert]::ToString($channel_number, 16)
    $final_hex = $hex
    while ($final_hex.Length -ne  8)
    {
        $final_hex = "0" + $final_hex
    }
}


else {
    if ($channel_number.Length -lt 2){

        $new = $computer.Substring(1)
        $channel_number = $new.substring(0, $new.lastindexof('-'))
        $hex = [Convert]::ToString($channel_number, 16)
        $final_hex = $hex

        while ($final_hex.Length -ne  8)
        {
            $final_hex = "0" + $final_hex
        }
    }
}

$value = "'" + $final_hex + "'"

Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\LanSchool" -Name "Channel" -Value $value
