$! File: unzip_tests.com
$!
$! Procedure to test unzip on VMS.
$!
$! Copyright 2016, John Malmberg
$!
$! Permission to use, copy, modify, and/or distribute this software for any
$! purpose with or without fee is hereby granted, provided that the above
$! copyright notice and this permission notice appear in all copies.
$!
$! THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
$! WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
$! MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
$! ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
$! WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
$! ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
$! OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
$!
$!==========================================================================
$!
$ set noon
$ test_count = 0
$ pass_count = 0
$ fail_count = 0
$ skip_count = 0
$ inhibit = %x10000000
$ ss_normal = 1
$ ss_skip = 43
$ ss_abort = 44 + inhibit
$ exit_status = ss_normal
$!
$ arch_type = f$getsyi("ARCH_NAME")
$ arch_name = f$edit(arch_type, "LOWERCASE")
$!
$ if arch_name .nes. "vax"
$ then
$   exedir = "''arch_name'l"
$ else
$   exedir = "vax"
$ endif
$!
$! Start Junit file
$!-------------------
$ @sys$disk:[.vms]junit_support start test_unzip
$!
$!
$unzip_help_1:
$ out_file = "unzip_help.tmp"
$ define/user sys$output 'out_file'
$ mcr sys$disk:[.'exedir']unzip --help
$ call search_text 'out_file' "Usage: unzip " -
    test_unzip unzip_help_1 vms
$ severity = $severity
$ gosub update_counters
$ if f$search(out_file) .nes. "" then delete 'out_file';
$!
$unzipsfx_help_1:
$ out_file = "unzipsfx_help.tmp"
$ define/user sys$output 'out_file'
$ mcr sys$disk:[.'exedir']unzipsfx --help
$ call search_text 'out_file' "UnZipSFX " -
    test_unzip unzipsfx_help_1 vms
$ severity = $severity
$ gosub update_counters
$ if f$search(out_file) .nes. "" then delete 'out_file';
$!
$unzip_cli_help_1:
$ if f$search("new_gnu:[vms_bin]gnv$unzip_cli.exe") .eqs. ""
$ then
$   @sys$disk:[.vms]junit_support skip test_unzip unzip_cli_1 vms
$ else
$   out_file = "unzip_cli_help.tmp"
$   spawn @sys$disk:[.vms]unzip_cli_test.com/output='out_file'
$   call search_text 'out_file' "Usage: unzip " -
      test_unzip unzip_cli_help_1 vms
$   severity = $severity
$   gosub update_counters
$   if f$search(out_file) .nes. "" then delete 'out_file';
$ endif
$!
$!
$ if 0
$ then
$unzip_environ_1:
$ unzip = "--help"
$ out_file = "unzip_help.tmp"
$ define/user sys$error 'out_file'
$ mcr sys$disk:[]gnv$unzip --help
$ call search_text 'out_file' "usage: unzip " -
    test_unzip unzip_environ_1 vms
$ severity = $severity
$ gosub update_counters
$ if f$search(out_file) .nes. "" then delete 'out_file';
$ endif
$!
$unzip_environ_2:
$ if 0
$ then
$ unzip := $lcl_root:[]gnv$unzip.exe
$ define/user unzip "--help"
$ out_file = "unzip_help.tmp"
$ define/user sys$error 'out_file'
$ mcr sys$disk:[]gnv$unzip
$ call search_text 'out_file' "usage: unzip " -
    test_unzip unzip_environ_2 vms
$ severity = $severity
$ gosub update_counters
$ if f$search(out_file) .nes. "" then delete 'out_file';
$ endif
$!
$unzip_environ_3:
$ if 0
$ then
$ zip_opts = "--help"
$ out_file = "unzip_help.tmp"
$ define/user sys$error 'out_file'
$ mcr sys$disk:[]gnv$unzip
$ call search_text 'out_file' "usage: unzip " -
    test_unzip unzip_environ_3 vms
$ severity = $severity
$ gosub update_counters
$ if f$search(out_file) .nes. "" then delete 'out_file';
$ endif
$!
$!
$finish_tests:
$ @sys$disk:[.vms]junit_support finish test_unzip 'test_count' test_unzip
$!
$ write sys$output "Total tests = ''test_count'"
$ write sys$output "Pass = ''pass_count'"
$ write sys$output "skip = ''skip_count'"
$ write sys$output "fail = ''fail_count'"
$!
$all_exit:
$ exit 'exit_status'
$!
$!
$update_counters:
$ test_count = test_count + 1
$ if severity .eq. 1
$ then
$   pass_count = pass_count + 1
$ else
$   if severity .eq. 3
$   then
$      skip_count = skip_count + 1
$   else
$      fail_count = fail_count + 1
$      exit_status = ss_abort
$   endif
$ endif
$ return
$!
$!
$search_text: subroutine
$! p1 infile
$! p2 text
$! p3 test_file
$! p4 test_name
$! p5 test_class
$!
$ define/user sys$output nla0:
$ define/user sys$error nla0:
$ search/exact 'p1' "''p2'"
$ severity='$severity'
$ if severity .ne. 1
$ then
$   @sys$disk:[.vms]junit_support fail "''p3'" "''p4'" "''p5'" -
            "Text ''p2' not found in file"
$   exit_status = ss_abort
$ else
$   exit_status = ss_normal
$   @sys$disk:[.vms]junit_support pass "''p3'" "''p4'" "''p5'"
$ endif
$ exit 'exit_status'
$ endsubroutine
$!
$!
$compare_files: subroutine
$!  p1 = oldfile
$!  p2 = newfile
$!  p3 = test_file
$!  p4 = test_name
$!  p5 = test_class
$!
$ if arch_name .nes. "vax"
$ then
$   checksum 'p1'
$   oldsum=checksum$checksum
$   checksum 'p2'
$   if oldsum .nes. checksum$checksum
$   then
$       @sys$disk:[.vms]junit_support fail "''p3'" "''p4'" "''p5'" -
            "Compare of ''p2' failed"
$       show sym oldsum
$       show sym checksum$checksum
$       exit_status = ss_abort
$   else
$       @sys$disk:[.vms]junit_support pass "''p3'" "''p4'" "''p5'"
$       exit_status = ss_normal
$   endif
$ else
$   @sys$disk:[.vms]junit_support skip "''p3'" "''p4'" "''p5'" -
            "currently skipped on VAX"
$   exit_status = ss_skip
$ endif
$ exit 'exit_status'
$ endsubroutine
