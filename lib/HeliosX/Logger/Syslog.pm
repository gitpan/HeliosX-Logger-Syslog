package HeliosX::Logger::Syslog;

use 5.008;
use base qw(Helios::Logger);
use strict;
use warnings;

use Sys::Syslog;

use Helios::LogEntry::Levels qw(:all);
use Helios::Error::LoggingError;

our $VERSION = '0.04_0111';

=head1 NAME

HeliosX::Logger::Syslog - Helios::Logger subclass implementing logging to syslogd for Helios

=head1 SYNOPSIS

 # in helios.ini
 loggers=HeliosX::Logger::Syslog
 syslog_facility=user
 # (optional) you can use other options as necessary
 syslog_options=nofatal,pid 
 # (optional) you can set the logmask by using integer values
 syslog_logmask=127

=head1 DESCRIPTION

This class implments a Helios::Logger subclass to provide Helios applications 
the ability to log messages to syslogd. 

=head1 CONFIGURATION

Config options:

=over 4

=item syslog_facility

The syslogd facility to which to log messages.  If not specified, it will 
default to 'user'.

=item syslog_options

A comma-delimited list of syslog options.  This will be passed as the second 
parameter of openlog().  See the L<Sys::Syslog> manpage for more details.

=item syslog_logmask

Allows you choose which log priorities you want to syslogd to actually log.  
This is like the Helios internal log_priority_threshold, but more capable as 
you can pick and choose which priorities you want, rather than just a range.

Syslogd defines the mask values for priorities as:

 1   = LOG_EMERG
 2   = LOG_ALERT
 4   = LOG_CRIT
 8   = LOG_ERR
 16  = LOG_WARNING
 32  = LOG_NOTICE
 64  = LOG_INFO
 128 = LOG_DEBUG
 
So, for example, if you wanted to log everything except LOG_DEBUG messages, 
putting:

syslog_logmask=127

in your helios.ini or Ctrl Panel will cause syslogd to filter out messages of 
LOG_DEBUG priority.  In addition, to only log LOG_ERR and LOG_WARNING messages:

syslog_logmask=24

will filter out any messages not of LOG_ERR or LOG_WARNING priority 
(8 + 16 = 24).

=back

=head1 IMPLEMENTED METHODS

=head2 init()

The init() method is empty.

=cut

sub init { }


=head2 logMsg($job, $priority_level, $message)

The logMsg() method logs the given message to the configured syslog_facility with the configured 
syslog_options and the given $priority_level.

=cut

sub logMsg {
    my $self = shift;
    my $job = shift;
    my $priority = shift;
    my $msg = shift;
	my $config = $self->getConfig();
	my $facility;
	my $options;
	
	# default to facility 'user'
	if ( !defined($config->{syslog_facility}) ) {
		$facility = 'user';
	} else {
		$facility = $config->{syslog_facility};
	}
	# use options if specified
	if ( defined($config->{syslog_options}) ) {
		$options = $config->{syslog_options};
	}

    openlog($self->getJobType(), $options, $facility);
    if ( defined($config->{syslog_logmask}) ) {
    	setlogmask($config->{syslog_logmask});
    }
    syslog($priority, $self->assembleMsg($job, $priority, $msg));
    closelog();
}


=head2 assembleMsg($job, $priority_level, $msg)

Given the information passed to logMsg(), assembleMsg() returns the actual text 
string to be logged to syslogd.  Separating this step into its own method 
allows you to easily override the default message format if you so 
choose.  Simply subclass HeliosX::Logger::Syslog and override assembleMsg() 
with your own message formatting method.

=cut

sub assembleMsg {
	my ($self, $job, $priority, $msg) = @_;
    if ( defined($job) ) { 
    	return 'Job '.$job->getJobid().': '.$msg;
    } else {
    	return $msg;
    }
}


1;
__END__


=head1 SEE ALSO

L<Helios::Service>, L<Helios::Logger>

=head1 AUTHOR

Andrew Johnson, E<lt>lajandy at cpan dotorgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-11 by Andrew Johnson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=head1 WARRANTY

This software comes with no warranty of any kind.

=cut
