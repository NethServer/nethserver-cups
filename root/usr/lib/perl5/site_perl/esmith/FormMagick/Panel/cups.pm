#!/usr/bin/perl -w
#
# Copyright (C) 2003,2005 Robert van den Aker <robert2@dds.nl>
# This script uses functions that are copyright (C) 2002 Mitel Networks
# Corporation.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
# USA.
#
#----------------------------------------------------------------------

package esmith::FormMagick::Panel::cups;

use strict;
use esmith::ConfigDB;
use esmith::FormMagick;
use esmith::cgi;
use Exporter;

our @ISA = qw(esmith::FormMagick Exporter);

our @EXPORT = qw(
    show_initial printer_sync
);

our $cdb = esmith::ConfigDB->open_ro() ||
    warn "Could not open configuration database";


=pod

=head1 NAME

esmith::FormMagick::Panel::cups - CUPS panel functions

=head1 SYNOPSIS

    use esmith::FormMagick::Panel::cups;
    my $panel = esmith::FormMagick::Panel::cups->new();
    $panel->display();

=head1 DESCRIPTION


=head2 new

Exactly as for esmith::FormMagick.

=cut

sub new
{
    shift;
    my $self = esmith::FormMagick->new();
    $self->{calling_package} = (caller)[0];
    bless $self;
    return $self;
}


=pod

=head2 get_cups_url

Returns the URL for the CUPS web interface.

=cut

sub get_cups_url
{
    my $url = "http://". ($cdb->get('LocalIP')->value() ||
	'localhost').":631/";
    return ($url);
}


=pod

=head2 get_sync_status

Compares CUPS printers configuration file and cups database to determine
whether the printer-sync event should be run.

=cut

sub get_sync_status
{
    my $fm = $_[0];
    my $cupsdb = esmith::ConfigDB->open_ro("cups") ||
	die "Could not open cups database";
    my $printersconf = "/etc/cups/printers.conf";
    my $ppddir = "/etc/cups/ppd";
    my $lastsync = $cdb->get('cupsd')->prop('LastSync') || "0";
    my $confmodtime = (stat($printersconf))[9] ||
	return "<FONT COLOR=\"Red\">Cannot stat $printersconf!</FONT>";
    my $ppddirmodtime = (stat($ppddir))[9] || "0";
    my @confprinters;
    open (PRINTERSCONF, "<$printersconf");
    while (<PRINTERSCONF>) {
	chomp;
	/^<(Default)?Printer ([a-z][a-z0-9]*)>$/ &&
	push (@confprinters, $2);
    }
    close (PRINTERSCONF);
    my $confprinters = join("",sort(@confprinters));
    my @dbprinters;
    foreach ($cupsdb->get_all_by_prop(type => 'printer')) {
	push (@dbprinters, $_->key);
    }
    my $dbprinters = join("",sort(@dbprinters));
    unless (-f "$printersconf.O") {
	return $fm->localise('NO_PRINTERS_TO_SYNC');
    }
    elsif ($lastsync < $confmodtime &&
    ($confprinters ne $dbprinters || $lastsync < $ppddirmodtime)) {
	return $fm->localise('PRINTERS_OUT_OF_SYNC');
    }
    else {
	return $fm->localise('PRINTERS_IN_SYNC');
    }
}


=pod

=head2 show_initial

Displays the cups panel.

=cut

sub show_initial
{
    my $fm = shift;
    my $q = $fm->{cgi};

    print "<tr><td>";
    print $q->p("<a href=\"". &get_cups_url."\">".
    $fm->localise('CLICK_HERE'). "</a> ".
    $fm->localise('CUPS_DESCRIPTION_BEGIN')." ". &get_cups_url.
    " ". $fm->localise('CUPS_DESCRIPTION_END'));
    print $q->p ($q->b ($fm->localise('SYNC_DESC_HEADER')));
    print $q->p ($fm->localise('SYNC_DESCRIPTION'));
    print $q->table ({border => 0, cellspacing => 0, cellpadding => 4},
    $q->Tr (esmith::cgi::genCell ($q, &get_sync_status($fm)),
	esmith::cgi::genCell ($q, $q->b ($q->submit (
	-value => $fm->localise('SYNCHRONIZE'))))));
    print "</td></tr>";
    return '';
}


=pod

=head2 printer_sync

Signals the printer-sync event.

=cut

sub printer_sync
{
    my $fm = shift;

    unless ( system("/sbin/e-smith/signal-event", "printer-sync") == 0 )
    {
        $fm->error('PRINTER_SYNC_ERROR', 'Status');
        return undef;
    }

    $fm->success('PRINTER_SYNC_SUCCESS', 'Status');
}


1;
