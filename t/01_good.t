use strict;
use lib "lib";
use Test::More;

$SIG{__WARN__}=sub { diag @_; };
plan tests => $Tests::tests + 1;

my @tst_subs = sort grep { s{^s}{t_s} } keys %Exception::ThrowUnless::;

my @exp_subs = sort grep { m{^t_s} } keys %Tests::;
is( "@exp_subs", "@tst_subs", "same subs" );
for ( @tst_subs ) {
	local $\="\n";
	#warn($_);
	&{$Tests::{$_}};
};

BEGIN {
	package Tests;
	require "t/must_die.pl" or die;
	use	Exception::ThrowUnless qw(:all);
	use Test::More;
	if ( -e 'tmp' ) {
		system("chmod -R 700 tmp; rm -fr tmp");
	};
	mkdir 'tmp', 0700 or die "mkdir:$!\n";
	symlink "xxx", "tmp/xxx" or die "symlink:xxx,tmp/xxx:$!";
	$Tests::tests+=2;
	sub t_sexec(@)
	{
		defined(my $pid = fork) || die "fork:$!";
		if ( !$pid ) {
			exec "/bin/true";
			exit 1;
		} else {
			is(wait, $pid, "pid $pid dead");
			is($?, 0, "exec returned true");
		};
	};
	$Tests::tests+=4;
	sub t_sopen # (*$)
	{
		local(*FILE);
		ok(defined(sopen(*FILE, ">tmp/testfile")),"open_test");
		ok(close(FILE), "file open");
		eval {
			sopen(*FILE,">tmp");
			fail("open>tmp should have failed.");	
		};
		like($@, qr/^open:>tmp:./, "open dir failed");
		ok(!close(FILE), "!file open");
	};
	$Tests::tests+=3;
	sub t_sclose # (*)
	{
		local *FILE;
		my $passed;
		must_die( sub { sclose(*FILE) }, qr/^close:/, "close unopened");
		sopen(*FILE,">tmp/sclose");
		$@="";
		ok(eval "sclose(*FILE)", "close open file");
		is($@, "", "no error");
	};
	$Tests::tests+=0;
	sub t_schdir # ($)
	{
		#
		# This is just here for coverage checks.  It is tested in
		# tg/01_good_chdir.t, since I don't want to change the pwd
		# during a long series of tests.
		#
		ok("Bush is a Tax and Spend Republican");
	};
	$Tests::tests+=1;
	sub t_schmod # (@)
	{
		SKIP: {
			skip "not implemented", 1;
		};
	};
	$Tests::tests+=3;
	sub t_sunlink # (@)
	{
		local *FILE;
		sopen(*FILE,">tmp/sunlink");
		ok(sunlink("tmp/sunlink"),"unlink ok");
		ok(sunlink("tmp/sunlink"),"unlink ENOENT");
		SKIP: {
			if ( $< && $> ) {
				sopen(*FILE,">tmp/sunlink");
				schmod(0500, "tmp");
				must_die(sub {
					sunlink "tmp/sunlink"
				}, qr(^unlink:),"unlink EPERM");
			} else {
				skip "Running as root", 1;
			};
		};
	};
	$Tests::tests+=0;
	sub t_slink # ($$)
	{
	};
	$Tests::tests+=0;
	sub t_srename # ($$)
	{
	};
	$Tests::tests+=0;
	sub t_srename_nc # ($$)
	{
	};
	$Tests::tests+=1;
	sub t_ssymlink # ($$)
	{
		must_die(sub{ ssymlink("tmp", ".") }, qr(^symlink:), "symlink is dir");
	};
	$Tests::tests+=0;
	sub t_smkdir # ($$)
	{
	};
	$Tests::tests+=1;
	sub t_sfork # (;$)
	{
		SKIP: {
			skip("how can you make fork fail in a cross platform way?",1);
		};
	};
	$Tests::tests+=2;
	sub t_spipe # ($)
	{
		SKIP: {
			skip("how can you make pipe fail in a cross platform way?",1);
		};
		local(*I,*O);
		ok(spipe(*I,*O),"spipe");
	};
	$Tests::tests+=2;
	sub t_sreadlink # ($)
	{
		ssymlink("test", "tmp/test");
		is(sreadlink("tmp/test"),"test","symlink");
	};
	$Tests::tests+=0;
};