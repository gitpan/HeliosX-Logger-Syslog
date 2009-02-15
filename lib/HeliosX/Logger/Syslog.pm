package HeliosX::Logger::Syslog;

use 5.008;
use base qw(HeliosX::Logger);
use strict;
use warnings;

use Sys::Syslog;

use HeliosX::LogEntry::Levels qw(:all);
use HeliosX::Logger::LoggingError;

our $VERSION = '0.02_0771';

=head1 NAME

HeliosX::Logger::Syslog - HeliosX::Logger subclass implementing logging to syslogd for Helios

=head1 SYNOPSIS

 # in helios.ini
 loggers=HeliosX::Logger::Syslog
 syslog_facility=user
 # can use other options as necessary
 syslog_options=nofatal,pid 

=head1 DESCRIPTION

This class extends the HeliosX::Logger class to provide a shim between HeliosX::ExtLoggerService 
and Sys::Syslog.  This will allow Helios applications using HeliosX::ExtLoggerService to log 
messages to syslogd. 

NOTE: The base Helios system contains syslogd logging functionality, but this class enables 
syslogd logging with HeliosX::ExtLoggerService.  An added benefit is the ability to completely 
turn off internal Helios logging if desired, sending log messages only to syslogd.


=head1 CONFIGURATION

Config options:

=over 4

=item syslog_facility [REQUIRED]

The syslogd facility to log messages to. 

=item syslog_options

A comma-delimited list of syslog options.  This will be passed as the second parameter of 
openlog().  See the L<Sys::Syslog> manpage for more details.

=back

=head1 IMPLEMENTED METHODS

=head2 init()

The init() method verifies that the syslog_facility configuration parameter is set in helios.ini.  
Without it, HeliosX::Logger::Syslog (and Sys::Syslog) will not function properly.

=cut

sub init {
    my $self = shift;
    my $config = $self->getConfig();

    unless ( defined($config->{syslog_facility}) ) {
        throw HeliosX::Logger::LoggingError("CONFIGURATION ERROR: syslog_facility not defined"); 
    }
    return 1;
}


=head2 logMsg($job, $priority_level, $message)

The logMsg() method logs the given message to the configured syslog_facility with the configured 
syslog_options and the given $priority_level.

=cut

sub logMsg {
    my $self = shift;
    my $job = shift;
    my $priority = shift;
    my $msg = shift;
    
    openlog($self->getJobType(), $self->getConfig()->{syslog_options}, $self->getConfig()->{syslog_facility});
    syslog($priority, $msg);
    closelog();
}


1;
__END__


=head1 SEE ALSO

L<HeliosX::ExtLoggerService>, L<HeliosX::Logger>

=head1 AUTHOR

Andrew Johnson, E<lt>lajandy at cpan dotorgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Andrew Johnson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=head1 WARRANTY

This software comes with no warranty of any kind.

=cut
