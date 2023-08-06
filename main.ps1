# -----------------------------------------------------------------------------------
# Header
# -----------------------------------------------------------------------------------
# Programname: PS-MountNetworkDrive
# Current version: v0.1
# Owner: C. Huebner
# Creation date: 2023-08-06
# -----------------------------------------------------------------------------------
# Changes
#
# -----------------------------------------------------------------------------------
# Parameters
# -----------------------------------------------------------------------------------
# As network drive is Z choosen by default, you can changed this what you like
[string]$networkDrive = "Z:"
# Set the full path to your shared directoy to the server
[string]$remotePath = "\\<servername>\<share directory>";
# Enter you server ip address
[string]$ipNetworkDrive = "<server IP>";
# Debug flag: only messages, no actions
[boolean]$DEBUG = $true;
# -----------------------------------------------------------------------------------
# Main function
# -----------------------------------------------------------------------------------
function main() {


    Write-Host "Start to mount the networkdrive $($networkDrive) on the remote path $($remotePath)...`n" -ForegroundColor Magenta;

    # Check the ethernet connection to the network drive
    Write-Host "Test the connection to $($ipNetworkDrive)..." -ForegroundColor White;
    if (!$DEBUG) {

        if (!(Test-Connection -ComputerName $ipNetworkDrive -Quiet)) {
    
            Write-Host "The network drive with the ip adresse: $($ipNetworkDrive) is unreachable, please check the connection." -ForegroundColor DarkRed;
            return $false;
        }
    }
    Write-Host "The connection to $($ipNetworkDrive) is stable." -ForegroundColor DarkGreen;

    # Mount the network drive
    Write-Host "Start to map the networkdrive and collect the credentials..." -ForegroundColor White;
    if (!$DEBUG) {

        [string]$networkDriveLetter = ($networkDrive).Replace(":","");
	    [string]$servername = (($remotePath).Substring(2)).Split("\")[0];
        # Check if the network drive already exists -> yes -> remove this
        if ($null -ne (Get-SmbMapping | Select-String -Pattern $networkDrive)) {

            Remove-SmbMapping -LocalPath $networkDrive -Force;
        }

        # Read the credentials
        Write-Host "Please enter the credentials for the network drive (hint: open the keepass db on the desktop)" -ForegroundColor DarkYellow;
        $cred = Get-Credential;
        $user = $cred.UserName;
        $pw = $cred.GetNetworkCredential().Password;

        # Create network drive and save the credentials
        New-SmbMapping -LocalPath $networkDrive -RemotePath $remotePath -UserName $user -Password $pw -Persistent $true;
        
        # Check if the credentials are correct
        if (!(Test-Path $networkDrive)) {

            Write-Host "Wrong credentials for the networkdrive." -ForegroundColor DarkRed;
            return $false;
        }

        # Delete (if is necessary) the old credentials
        if ($null -ne (cmdkey /list | Select-String -Pattern "target=$($servername)")) {
        
            cmdkey /delete:$servername;
        }
        # Save the credentials
        cmdkey /add:$servername /user:$user /pass:$($pw);
	
	    # Ensure that the credentials are saved after the logoff
        REG ADD "HKEY_CURRENT_USER\Network\$($networkDriveLetter)" /v ConnectionType /t REG_DWORD /d 1 /f;
        REG ADD "HKEY_CURRENT_USER\Network\$($networkDriveLetter)" /v DeferFlags /t REG_DWORD /d 4 /f;
    }
    Write-Host "Finish to map the networkdrive." -ForegroundColor DarkGreen;

    Write-Host "`nFinish with mounting the network drive (hint: after the next login, you see the $($networkDrive) also in the explorer).`n" -ForegroundColor DarkGray;
    return $true;
}
# Entry point for the main function
try {

    main;
}
catch {

    $e = $_.Exception;
    $line = $_.InvocationInfo.ScriptLineNumber;
    $msg = $e.Message;

    Write-Error "In script main.ps $($msg) see line $($line)" -Category InvalidOperation -TargetObject $e;
}
finally {

    #    Write-Host "Done";
}