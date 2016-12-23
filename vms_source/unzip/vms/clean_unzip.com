$! File: Clean_unzip.com
$!
$! Clean up for a new build
$!
$!==================================================================
$!
$ if f$search("[.ia64l]*.cld") .nes. "" then delete [.ia64l]*.cld;*
$ if f$search("[.ia64l]*.lis") .nes. "" then delete [.ia64l]*.lis;*
$ if f$search("[.ia64l]*.obj") .nes. "" then delete [.ia64l]*.obj;*
$ if f$search("[.ia64l]*.olb") .nes. "" then delete [.ia64l]*.olb;*
$ if f$search("[.ia64l]*.opt") .nes. "" then delete [.ia64l]*.opt;*
$!
$ if f$search("[.alphal]*.cld") .nes. "" then delete [.alphal]*.cld;*
$ if f$search("[.alphal]*.lis") .nes. "" then delete [.alphal]*.lis;*
$ if f$search("[.alphal]*.obj") .nes. "" then delete [.alphal]*.obj;*
$ if f$search("[.alphal]*.olb") .nes. "" then delete [.alphal]*.olb;*
$ if f$search("[.alphal]*.opt") .nes. "" then delete [.alphal]*.opt;*
$!
$ if f$search("[.vax]*.cld") .nes. "" then delete [.vax]*.cld;*
$ if f$search("[.vax]*.lis") .nes. "" then delete [.vax]*.lis;*
$ if f$search("[.vax]*.obj") .nes. "" then delete [.vax]*.obj;*
$ if f$search("[.vax]*.olb") .nes. "" then delete [.vax]*.olb;*
$ if f$search("[.vax]*.opt") .nes. "" then delete [.vax]*.opt;*
$!
$ file = "[.vms]unzip_cli.rnh"
$ if f$search(file) .nes. "" then delete 'file';*
$ file = "[]*.pcsi$*"
$ if f$search(file) .nes. "" then delete 'file';*
$ file = "[]unzip*.bck"
$ if f$search(file) .nes. "" then delete 'file';*
$ file = "[]unzip*.release_notes"
$ if f$search(file) .nes. "" then delete 'file';*
$!
$ if p1 .eqs. "REALCLEAN"
$ then
$   file = "unzip*.hlp"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "unzip_verb.cld"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "unzipsfx_verb.cld"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.ia64l]unzip*.exe"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.alphal]unzip*.exe"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.vax]unzip*.exe"
$   if f$search(file) .nes. "" then delete 'file';*
$ endif
