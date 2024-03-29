package Test::WWW::Mechanize::Dancer;
use strict;
use warnings;
use Cwd;
use Dancer qw(:tests :moose !load);
use Module::Load qw(load);
use Moose;
use Test::WWW::Mechanize::PSGI;

our $VERSION = '0.0100'; # VERSION

has appdir      => (is => 'ro', default => getcwd );
has envdir      => (is => 'ro');
has agent       => (is => 'ro', default => 'Dancer Tests');
has confdir     => (is => 'ro');
has environment => (is => 'ro', default => 'test');
has public      => (is => 'ro');
has views       => (is => 'ro');
has mech_class  => (is => 'ro', default => 'Test::WWW::Mechanize::PSGI');

has mech        => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self) = @_;

        load $self->mech_class;
        my $m = $self->mech_class->new(
            app => sub {
                my $env = shift;
                set (
                    appdir => $self->appdir,
                    envdir => $self->envdir || path($self->appdir, 'environments'),
                    confdir => $self->confdir || $self->appdir,
                    public => $self->public || path($self->appdir,  '/public'),
                    views => $self->views || path($self->appdir, '/views' ),
                    environment => $self->environment,
                );
                my $request = Dancer::Request->new( env => $env );
                Dancer->dance( $request );
            }
        );
        $m->agent($self->agent);
        return $m;
    },
);

# ABSTRACT: Wrapper to easily use Test::WWW::Mechanize with your Dancer apps


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::WWW::Mechanize::Dancer - Wrapper to easily use Test::WWW::Mechanize with your Dancer apps

=head1 VERSION

version 0.0100

=head1 SYNOPSIS

    use MyDancerApp;
    use Test::WWW::Mechanize::Dancer;

    # Get your standard Test::WWW::Mechanize object
    my $mech = Test::WWW::Mechanize::Dancer->new(
        # settings here if required
    )->mech;
    # Run standard Test::WWW::Mechanize tests
    $mech->get_ok('/');

=head1 DESCRIPTION

This is a simple wrapper that lets you test your Dancer apps using
Test::WWW::Mechanize.

=head1 SETTINGS

=head2 appdir

Probably the main thing you will want to set, C<appdir> sets the base
directory for the app.  C<confdir>, C<views>, and C<public>, will be 
set to C<appdir>, C<appdir>/views, and C<appdir>/public
respectively if not set explicitly.

The C<appdir> defaults to the current working directory, which works
in most testing cases.

=head2 agent

Allows you to set the user agent of the Mechanizer.

=head2 confdir

Set the dancer confdir.  Will default to appdir if unspecified.

=head2 envdir

Allows you to set the directory where Dancer should look for the config files
for each environment.  Defaults to 'environments' under appdir.  Note if your
app uses $ENV{DANCER_ENVDIR} you should explicitly pass that value using this
option.

=head2 environment

Allows you to set the Dancer environment to run your app in.  Defaults to
'test'

=head2 mech_class

Allows you to override the class used to instantiate the user agent object.
Use this to invoke your own class with project-specific test-helper methods.
Defaults to 'Test::WWW::Mechanize::PSGI' - which your class should inherit
from.  Note, it is your responsibility to 'require' the class.

=head2 public

Set the public directory for your dancer app.  Defaults to C<appdir>/public

=head2 views

Set the views directory for your dancer app.  Defaults to C<appdir>/views

=head1 AUTHORS

=over 4

=item *

William Wolf <throughnothing@gmail.com>

=item *

Grant McLean <grantm@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by William Wolf.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
