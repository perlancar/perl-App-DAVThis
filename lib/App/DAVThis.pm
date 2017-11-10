package App::DAVThis;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Cwd;
use Getopt::Long;
use Pod::Usage;

sub new {
    my $class = shift;
    my $self = bless {port => 4242, root => '.'}, $class;

    GetOptions($self, "help", "man", "port=i",
           ) || pod2usage(2);
    pod2usage(1) if $self->{help};
    pod2usage(-verbose => 2) if $self->{man};

    if (@ARGV > 1) {
        pod2usage("$0: Too many roots, only single root supported");
    } elsif (@ARGV) {
        $self->{root} = shift @ARGV;
    } else {
        $self->{root} = getcwd();
    }

    return $self;
}

sub run {
    require Filesys::Virtual::Plain;
    require HTTP::Daemon;
    require Net::DAV::Server;

    my ($self) = @_;

    my $filesys = Filesys::Virtual::Plain->new({root_path => $self->{root}});
    my $webdav = Net::DAV::Server->new();
    $webdav->filesys($filesys);

    my $d = HTTP::Daemon->new(
        LocalAddr => 'localhost',
        LocalPort => $self->{port},
        ReuseAddr => 1)
        or die "Can't start HTTP::Daemon on port $self->{port}: $!";

    print "Please contact me at: ", $d->url, "\n";
    while (my $c = $d->accept) {
        while (my $request = $c->get_request) {
            my $response = $webdav->run($request);
            $c->send_response ($response);
        }
        $c->close;
        undef($c);
    }
}

1;
# ABSTRACT: Export the current directory over WebDAV

=head1 SYNOPSIS

 # Not to be used directly, see dav_this command


=head1 DESCRIPTION


=head1 METHODS

=head2 new

=head2 run


=head1 ENVIRONMENT


=head1 SEE ALSO

=cut
