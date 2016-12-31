$! File: UNZIP_CLI_TEST.COM
$!
$! This is designed to be run as a spawned subprocess to not make
$! changes in the local clitables
$!
$ if f$type(unzip) .eqs. "STRING" then delete/sym/global unzip
$ if f$search("new_gnu:[vms_bin]gnv$unzip_cli.exe") .eqs. ""
$ then
$   write sys$output "UNZIP images have not been staged!"
$   exit 42
$ endif
$ set command new_gnu:[vms_bin]unzip_verb.cld
$ unzip /help
