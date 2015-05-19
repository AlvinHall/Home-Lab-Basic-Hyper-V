<#
.Synopsis
   Creates a Test Lab
.DESCRIPTION
   Creates the VHDX and VM for the following:
   - DC01
   - FP01
.EXAMPLE
   .\Set-TestLab.ps1
#>
[CmdletBinding()]
[OutputType([int])]
Param()

Begin{
    $VirtualMachines = @("DC1","FP1")
    $VHDPath = "F:\Virtual Hard Drives"
    $VMPath =  "F:\Virtual Machines"
}
Process{
    ForEach ($VM in $VirtualMachines) {
        Write-Verbose "Virtual Machine clean up for $VM"
        If (Get-VM -Name $VM -ErrorAction SilentlyContinue) {
            Remove-VM -Name $VM
        }
        If (Test-path -Path "$VHDPath\$VM") {
            Remove-Item "$VHDPath\$VM" -Force -Recurse
        }

        Write-Verbose "Create VHDX for $VM"
        New-VHD -Fixed -Path "$VHDPath\$VM\$VM-C.vhdx" -SizeBytes 25GB
        Write-Verbose "Create Virtual Machine"
        New-VM -VHDPath "$VHDPath\$VM\$VM-C.vhdx" -Generation 2 -MemoryStartupBytes 1024MB -Name $VM -Path "$VMPath\$VM"
        Set-VM -Name $VM -ProcessorCount 2
        
        If ($VM = "FP01") {
            New-VHD -Fixed -Path "$VHDPath\$VM\$VM-D.vhdx" -SizeBytes 10GB
            Add-VMHardDiskDrive -VM $VirtualMachine -Path "$VHDPath\$VM\$VM-D.vhdx"
        }
    }
}
End{
}