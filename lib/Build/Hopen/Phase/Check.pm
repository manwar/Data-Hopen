# Build::Hopen::Phase::Check - checking-phase operations
package Build::Hopen::Phase::Check;
use Build::Hopen;
use Build::Hopen::Base;
use parent 'Exporter';

our $VERSION = '0.000005'; # TRIAL

our (@EXPORT, @EXPORT_OK, %EXPORT_TAGS);
BEGIN {
    @EXPORT = qw();
    @EXPORT_OK = qw(find_hopen_files);
    %EXPORT_TAGS = (
        default => [@EXPORT],
        all => [@EXPORT, @EXPORT_OK]
    );
}

#use Build::Hopen::PathCapsule;
use Cwd qw(getcwd abs_path);
use File::Glob ':bsd_glob';
#use File::Globstar qw(globstar);
use File::Spec;
use Path::Class;

# Docs {{{1

=head1 NAME

Build::Hopen::Phase::Check - Check the build system

=head1 SYNOPSIS

Check runs first.  Check reads a foundations file and outputs a capability
file and an options file.  The user can then edit the options file to
customize the build.

Check also locates context files.  For example, when processing C<~/foo/.hopen>,
Check will also find C<~/foo.hopen> if it exists.

=cut

# }}}1

=head1 FUNCTIONS

=head2 find_hopen_files

Returns a list of hopen files, if any, to process for the given directory.
Hopen files match C<*.hopen.pl> or C<.hopen.pl>.  Usage:

    my $files_array = find_hopen_files([$proj_dir[, $dest_dir]])

If no C<$proj_dir> is given, the current directory is used.

The returned files should be processed in left-to-right order.

The return array will include a context file if any is present.
For C<$dir eq '/foo/bar'>, for example, C</foo/bar.hopen.pl> is the
name of the context file.

=cut

sub find_hopen_files {
    my $proj_dir = @_ ? dir($_[0]) : dir;
    my $dest_dir = $_[1] if @_>1;

    local *d = sub { $proj_dir->file(shift) };
        # Need slash as the separator for File::Globstar.

    hlog { 'Looking for hopen files in', $proj_dir->absolute };

    # Look for files that are included with the project
    my @candidates = sort(
        grep { $_ !~ /MY\.hopen\.pl$/ } (
            bsd_glob(d('*.hopen.pl'), GLOB_NOSORT),
            bsd_glob(d('.hopen.pl'), GLOB_NOSORT),
        )
    );
    hlog { "Candidates", @candidates };
    @candidates = $candidates[$#candidates] if @candidates;
        # Only use the last one

    # Add a $dest_dir/MY.hopen.pl file first, if there is one.
    if($dest_dir) {
        my $MY = $dest_dir->file('MY.hopen.pl');
        unshift @candidates, $MY if -r $MY;
    }

    # Look in the parent dir for context files.
    # The context file comes after the earlier candidate.
    my $parent = $proj_dir->parent;
    if($parent ne $proj_dir) {          # E.g., not root dir
        my $me = $proj_dir->basename;
        my $context_file = $parent->file("$me.hopen.pl");
        if(-r $context_file) {
            push @candidates, $context_file;
            hlog { 'Context file', $context_file };
        }
    }

    hlog { 'Using hopen files', @candidates };
    return [@candidates];
} #find_hopen_files()

1;
__END__
# vi: set fdm=marker: #
