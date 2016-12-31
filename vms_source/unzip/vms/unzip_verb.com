$! unzip_verb.com - build the unzip_verb.cld from the unzip.cld.
$!
$! The CLD file needed to modify a DCL command table is different
$! from the CLD file needed to build the product by specifying an image.
$!
$! So read in the [.vms]unzip.cld and generate a unzip_verb.cld.
$!
$! 23-Nov-2016 - J. Malmberg
$!
$ arch_type = f$getsyi("ARCH_NAME")
$ arch_name = f$edit(arch_type, "LOWERCASE")
$ if arch_name .nes. "vax"
$ then
$   arch = arch_name + "l"
$ else
$   arch = arch_name
$ endif
$!
$ outfile1 = "sys$disk:[]unzip_verb.cld"
$ outfile2 = "sys$disk:[]unzipsfx_verb.cld"
$ infile = "[.''arch']unz_cli.cld"
$ if f$search(infile) .eqs. ""
$ then
$   infile = "sys$disk:[.vms]unz_cli.cld"
$ endif
$ open/read cld 'infile'
$ create 'outfile1'
$ create 'outfile2'
$ open/append cldv1 'outfile1'
$ open/append cldv2 'outfile2'
$loop:
$   read cld/end=loop_end line_in
$   if f$locate("Verb", line_in) .lt. f$length(line_in)
$   then
$       write cldv1 line_in
$       write cldv1 "    image gnv$gnu:[vms_bin]gnv$unzip_cli"
$       write cldv2 line_in
$       write cldv2 "    image gnv$gnu:[vms_bin]gnv$unzipsfx_cli"
$       goto loop
$   endif
$   write cldv1 line_in
$   write cldv2 line_in
$   goto loop
$loop_end:
$ close cldv1
$ close cldv2
$ close cld
$!
