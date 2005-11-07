use strict;
BEGIN { use lib "lib"; };
use Test::More;

$SIG{__WARN__}=sub { diag @_; };
my @tst_subs = sort grep { s{^s}{t_s} } keys %Exception::ThrowUnless::;
plan tests => $Tests::tests + 1;
do {
	my @exp_subs = sort grep { m{^t_s}    } keys %Tests::;
	is( "@exp_subs", "@tst_subs", "same subs" );
};
for ( @tst_subs ) {
	local $\="\n";
	warn($_);
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
	smkdir 'tmp', 0700;
	ssymlink "xxx", "tmp/xxx";
	$Tests::tests--;
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
	$Tests::tests+=3;
	sub t_ssocketpair
	{
		use Socket;
		no warnings "once";
		local (*I,*O);
		ok(ssocketpair(*I,*O,AF_UNIX,SOCK_STREAM,PF_UNSPEC),
			"socketpair");
		must_die(sub {
			for ( 0 .. 10000 ) {
				no strict "refs";
				ssocketpair(*{"I$_"},*{"O$_"},AF_UNIX,SOCK_STREAM,PF_UNSPEC);
			};
		},qr{^socketpair:GLOB},"many pipes");
		for ( 0 .. 10000 ) {
			no strict "refs";
			no warnings "closed";
			close(*{"I$_"});
			close(*{"O$_"});
		};
		ok(ssocketpair(*I,*O,AF_UNIX,SOCK_STREAM,PF_UNSPEC),
			"socketpair");
	};
	$Tests::tests+=0;
	sub t_sspit
	{
	};
	$Tests::tests+=0;
	sub t_ssuck
	{
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
		like($@, qr/^open:GLOB\(0x[0-9a-zA-Z]*\),>tmp:./, "open dir failed");
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
		ok(defined sclose(*FILE), "close open file");
		is($@, "", "no error");
	};
	$Tests::tests+=1;
	sub t_schdir # ($)
	{
		#
		# This is just here for coverage checks.  It is tested in
		# tg/01_good_chdir.t, since I don't want to change the pwd
		# during a long series of tests.
		#
		ok("Bush is a Tax and Spend Republican");
	};
	$Tests::tests+=3;
	sub t_spipe # (@)
	{
		ok(spipe(local *I,local *O),"spipe piped");
		must_die(sub {
			for ( 0 .. 10000 ) {
				no strict "refs";
				spipe(*{"I$_"},*{"O$_"});
			};
		},qr{^pipe:GLOB},"many pipes");
		for ( 0 .. 10000 ) {
			no warnings "closed";
			no strict "refs";
			close(*{"I$_"});
			close(*{"O$_"});
		};
		ok(spipe(local *I,local *O),"spipe piped");
	};
	$Tests::tests+=2;
	sub t_schmod # (@)
	{
		smkdir("adir",0700);
		ok(schmod(0770,"adir"));
		srmdir("adir");
		must_die(sub { schmod(0777,"adir") },qr/^chmod:/,"chmod gone");
	};
	$Tests::tests+=2;
	sub t_srmdir # (@)
	{
		local $_ = "xxx";
		smkdir($_,0777);
		ok(srmdir);
		smkdir($_,0777);
		ok(srmdir($_));
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
		must_die(
			sub{
				ssymlink("tmp", ".")
			}, qr(^symlink:), "symlink is dir"
		);
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
	sub t_sreadlink # ($)
	{
		ssymlink("test", "tmp/test");
		is(sreadlink("tmp/test"),"test","readlink eq 'test'");
	};
	$Tests::tests+=0;
};
