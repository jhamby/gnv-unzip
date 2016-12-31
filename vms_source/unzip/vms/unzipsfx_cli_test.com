$! File: UNZIPSFX_CLI_TEST.COM
$!
$! This is designed to be run as a spawned subprocess to not make
$! changes in the local clitables
$!
$ if f$type(unzipsfx) .eqs. "STRING" then delete/sym/global unzipsfx
$ if f$search("new_gnu:[vms_bin]gnv$unzipsfx_cli.exe") .eqs. ""
$ then
$   write sys$output "UNZIPSFX images have not been staged!"
$   exit 42
$ endif
$ set command new_gnu:[vms_bin]unzipsfx_verb.cld
$ unzipsfx /help
