package Exception::ThrowUnless;
require Exporter;
use strict;
use File::Spec::Functions;

our(@ISA)=qw(Exporter);
our $VERSION = "1.02";
our @EXPORT_OK = qw(
	schdir   schmod  sclose     sexec    sfork       slink
	smkdir   sopen   sreadlink  srename  srename_nc  ssymlink
	sunlink
);
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

sub throw(@) {
	eval q[ use Carp; ];
	*Exception::throw = \&Carp::confess;
	goto &Carp::confess;
}
sub checkdef($@) {
	return $_[0] if defined $_[0];
	throw splice(@_,1);
}
sub sexec(@){
	exec @_;
	die throw "exec (@_):$!";
}
sub sopen(\*$) {
	my ($h,$n) = @_;
	my $r;
	$r=open($h,$n);
	throw "open:$n:$!" unless defined ($r);
	return $r;
}
sub sclose(*){
	close(shift) || throw "close:$_:$!";
}
sub sunlink(@) {
	unlink(@_) == @_ && return scalar(@_);
	for ( @_ ) {
		-l $_ || -e $_ || next;
		unlink($_) && next;
		throw "unlink:$_:$!";
	}
	return scalar(@_);
}
sub slink($$) {
	my ($f,$t) = @_;
	link $f, $t or throw "link:$f,$t:$!\n";
}
sub srename($$) {
	my ($f,$t) = @_;
	rename($f,$t) or throw "rename:$f,$t:$!\n";
};
sub srename_nc($$) {
	my ($f,$t) = @_;
	-e $t || -l $t && throw "won't clobber '$t'";
	srename($f,$t);
}
sub schdir($){
	local $"=",";
	chdir @_ or throw "chdir:@_:$!";
}
sub ssymlink($$) {
	my ( $f, $t ) = @_;
	symlink($f,$t) or throw "symlink:$f,$t:$!";
}
sub schmod(@) {
	local $"=',';
	return @_-1 if ( chmod(@_) == @_-1 );
	throw "chmod:@_:$!";
}
sub smkdir($$) {
	my ( $dir, $mode ) = @_;
	my $res = mkdir $dir, $mode;
	return $res if $res;
	return $res if -d $dir && $! == 17;
	throw "smkdir:$dir:$! and is not a directory" if $! == 17;
	throw "smkdir:$dir:$!";
};
sub sfork() {
	defined (my $pid=fork) or throw "fork:$!";
	return $pid;
}
sub sreadlink($) {
	readlink $_[0] or throw("readlink:@_:$!");
}
1;

