

$grp = "xxxx-group"


($Groups = Get-ADGroup -identity $grp -Properties *).Member.Count
$Groups # | Select @{Name="type"; Expression={"secGrp"}}, name

#$members = Get-ADGroupMember -Identity $grp -Recursiv
#$members | Select @{Name="type"; Expression={"member"}}, name

