#!perl
# t/200-probe-basic.t - basic tests of Build::Hopen::Phase::Check
use rlib 'lib';
use HopenTest;
use Test::Deep;
use Path::Class;

BEGIN {
    use_ok 'Build::Hopen::Phase::Check', 'find_hopen_files';
}

sub cf { File::Spec->catfile(@_) }

my $dir = file($0)->parent->subdir('dir200')->subdir('inner');
diag "Looking in $dir";
my $lrCandidates = find_hopen_files $dir;
is_deeply($lrCandidates, [$dir->file('z.hopen.pl'), $dir->parent->file('inner.hopen.pl')], 'finds candidates');

done_testing();
