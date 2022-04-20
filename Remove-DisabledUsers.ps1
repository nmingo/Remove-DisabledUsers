$search = New-Object System.DirectoryServices.DirectorySearcher
$search.SearchRoot = [ADSI]"LDAP://DC=domain,DC=com"

$exclude = @('NetworkService','LocalService','systemprofile')
$profiles = Get-WmiObject -ClassName Win32_UserProfile | Where-Object {$_.LocalPath.split('\')[-1] -notin $exclude}

foreach ($p in $profiles) {
    $user = $p.LocalPath.Split('\')[-1]
    $filter = "(&(objectCategory=person)(objectClass=user)(anr=$($user)))"
    $search.Filter = $filter
    $results = $search.FindOne()

    if ($results.Properties.useraccountcontrol -eq 514) {
        $p.Delete()
    }
}