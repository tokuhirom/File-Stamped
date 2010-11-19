package File::Stamped;
use strict;
use warnings;
use 5.008001;
our $VERSION = '0.01';
use Carp ();
use POSIX ();
use SelectSaver ();

sub new {
    my $class = shift;
    my %args = @_==1?%{$_[0]}:@_;
    $args{pattern} || Carp::croak "missing mandatory parameter 'pattern'";
    my $self = bless \do { local *FH }, $class;
    tie *$self, $class, $self;
    %args = (
        autoflush         => 1,
        close_after_write => 1,
        iomode            => '>>:utf8',
        %args
    );
    for my $k (keys %args) {
        *$self->{$k} = $args{$k};
    }
    return $self;
}

sub TIEHANDLE {
    (
        ( defined( $_[1] ) && UNIVERSAL::isa( $_[1], __PACKAGE__ ) )
        ? $_[1]
        : shift->new(@_)
    );
}

sub PRINT     { shift->print(@_) }

sub _gen_filename {
    my $self = shift;
    return POSIX::strftime(*$self->{pattern}, localtime());
}

sub print {
    my $self = shift;

    my $fname = $self->_gen_filename();
    my $fh;
    if (*$self->{fh}) {
        if ($fname eq *$self->{fname} && *$self->{pid}==$$) {
            $fh = delete *$self->{fh};
        } else {
            my $fh = delete *$self->{fh};
            close $fh if $fh;
        }
    }
    unless ($fh) {
        open $fh, *$self->{iomode}, $fname or die "Cannot open file($fname): $!";
        if (*$self->{autoflush}) {
            my $saver = SelectSaver->new($fh);
            $|=1;
        }
    }
    print {$fh} @_
        or die "Cannot write to $fname: $!";
    if (*$self->{close_after_write}) {
        close $fh;
    } else {
        *$self->{fh}    = $fh;
        *$self->{fname} = $fname;
        *$self->{pid}   = $$;
    }
}

1;
__END__

=encoding utf8

=head1 NAME

File::Stamped - time stamped log file

=head1 SYNOPSIS

    use File::Stamped;
    my $fh = File::Stamped->new(pattern => '/var/myapp.log.%Y%m%d.txt');
    $fh->print("OK\n");

    # with Log::Minimal
    use Log::Minimal;
    my $fh = File::Stamped->new(pattern => '/var/myapp.log.%Y%m%d.txt');
    local $Log::Minimal::PRINT = sub {
        my ( $time, $type, $message, $trace) = @_;
        print {$fh} "$time [$type] $message at $trace\n";
    };

=head1 DESCRIPTION

File::Stamped is utility for time stamped log file.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

L<Log::Dispatch::File::Stamped>

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
