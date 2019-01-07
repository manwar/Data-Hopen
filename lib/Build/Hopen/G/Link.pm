# Build::Hopen::G::Link - base class for hopen edges
package Build::Hopen::G::Link;
use Build::Hopen;
use Build::Hopen::Base;

our $VERSION = '0.000003'; # TRIAL

use parent 'Build::Hopen::G::Runnable';
use Class::Tiny {
    greedy => 0
};

=head1 NAME

Build::Hopen::G::Link - The base class for all hopen links between ops.

=head1 VARIABLES

=head2 greedy

If set truthy in the C<new()> call, the edge will ask for all inputs.

=head1 FUNCTIONS

=head2 run

Copy the inputs to the outputs.

    my $hrOutputs = $op->run([$hrInputs])

The output is C<{}> if no inputs are provided.

=cut

sub run {
    my $self = shift or croak 'Need an instance';
    hlog { Running => __PACKAGE__ , $self->name };
    my $hrRetval = {};
    $hrRetval = Storable::dclone($_[0]) if @_ && ref $_[0];
    return $hrRetval;
} #run()


=head2 BUILD

Constructor.  Interprets L</greedy>.

=cut

sub BUILD {
    my ($self, $args) = @_;
    $self->want(UNSPECIFIED) if $args->{greedy};
    use Data::Dumper;
    #hlog { 'Link::BUILD', Dumper($self) };
} #BUILD()

1;
__END__
# vi: set fdm=marker: #
