#!/usr/bin/perl -w
#
# Copyright (C) 2002 Mitel Networks Corporation
#
# $Id: printers.pm,v 1.9 2004/01/07 01:43:22 msoulier Exp $
#
#----------------------------------------------------------------------

package esmith::FormMagick::Panel::printers;

use esmith::FormMagick;
use esmith::AccountsDB;
use esmith::HostsDB;
use esmith::cgi;
use Exporter;

our @ISA = qw(esmith::FormMagick Exporter);
our @EXPORT = qw(
    show_printers create_printer print_hidden_fields 
    show_delete_confirmation delete_printer
    hostname_or_ip
);
our @VERSION = sprintf '%d.%03d', q$Revision: 1.9 $ =~ /: (\d+).(\d+)/;

=pod

=head1 NAME

esmith::FormMagick::Panel::printers - useful panel functions

=head1 SYNOPSIS

use esmith::FormMagick::Panel::printers;
my $panel = esmith::FormMagick::Panel::printers->new();
$panel->display();

=head1 DESCRIPTION

=head2 new

Exactly as for esmith::FormMagick.

=begin testing
use_ok('esmith::FormMagick::Panel::printers');
$FM = esmith::FormMagick::Panel::printers->new();
isa_ok($FM, 'esmith::FormMagick::Panel::printers');
$FM->{testing} = 1; # set test mode
$FM->{cgi} = CGI->new();
truncate("30e-smith-LPRng/accounts",0);

=end testing

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

=head2 show_printers

Reads the list of printers from accounts database and shows it as a table.

=begin testing

$FM->show_printers();
like($_STDOUT_, qr/NO_PRINTERS/, 'show_printers');

=end testing

=cut

sub show_printers
{
    my $self = shift;
    my $q = $self->{cgi};

    my $adb;
    if ($self->{testing})
    {
        $adb = esmith::AccountsDB->open('30e-smith-LPRng/accounts');
    }
    else
    {
        $adb = esmith::AccountsDB->open();
    }

    my @printerDrivers;
    if ($adb)
    {
        @printerDrivers = $adb->printers();
    }

    print '<tr><td colspan="2">';
    my $numPrinters = @printerDrivers;
    if ($numPrinters > 0)
    {
        print $q->h3($self->localise('CURRENT_LIST'));

        print $q->start_table ({-CLASS => "sme-border"});

        print $q->Tr (esmith::cgi::genSmallCell($q, $self->localise('NAME'),"header"),
        esmith::cgi::genSmallCell($q, $self->localise('DESCRIPTION'),"header"),
        esmith::cgi::genSmallCell($q, $self->localise('LOCATION'),"header"),
        esmith::cgi::genSmallCell($q, $self->localise('REMOTE_ADDRESS'),"header"),
        esmith::cgi::genSmallCell($q, $self->localise('REMOTE_NAME'),"header"),
        esmith::cgi::genSmallCell($q, $self->localise('ACTION'),"header"));

        my $printer;
        foreach $printer (sort @printerDrivers)
        {
            my $address = ($printer->prop('Location') eq 'remote')
            ? $printer->prop('Address') : 'N/A';
            my $remoteName = ($printer->prop('Location') eq 'remote')
            ? $printer->prop('RemoteName') : 'N/A';
            unless ($remoteName)
            {
                $remoteName = 'raw';
            }

            print $q->Tr (esmith::cgi::genSmallCell ($q, $printer->key, "normal"),
            esmith::cgi::genSmallCell ($q, $printer->prop('Description'), "normal"),
            esmith::cgi::genSmallCell ($q, $printer->prop('Location'), "normal"),
            esmith::cgi::genSmallCell ($q, $address, "normal"),
            esmith::cgi::genSmallCell ($q, $remoteName, "normal"),
            esmith::cgi::genSmallCell ($q,
            $q->a ({href => $q->url (-absolute => 1)
            ."?page=".$self->get_page_by_name('Delete')
            ."&Next=Delete&printer=". $printer->key}, 
            $self->localise('REMOVE')), "normal"));
        }

        print $q->end_table,"\n";
    }
    print '</td></tr>';
    return '';
}


sub cups_gui
{
    my $self = shift;
    my $q = $self->{cgi};
    
    print $q->p($self->localise('CUPS_GUI'));
    my $hosts_db = esmith::HostsDB->open();
    my @hosts = $hosts_db->hosts;
    foreach my $host (@hosts)
    {
        my $static = $host->prop('static') || "no";
        if ($static eq 'yes') {
            print $q->p("<a href='https://".$host->key.":631' target='_blank'>https://".$host->key.":631</a>");   
        }
    }
 
    return '';
}


=pod

=head2 print_hidden_fields

Print hidden fields needed by the AddNetwork page.

=begin testing

$FM->print_hidden_fields();
like($_STDOUT_, qr/name/, 'hidden name field');
like($_STDOUT_, qr/description/, 'hidden description field');
like($_STDOUT_, qr/location/, 'hidden location field');

=end testing

=cut

sub print_hidden_fields
{
    my $self = shift;
    my $q = $self->{cgi};

    my $name = $q->param('name');
    my $description = $q->param('description');
    my $location = $q->param('location');

    print $q->hidden (-name => 'name',
        -override => 1, -default => $name);
    print $q->hidden (-name => 'description',
        -override => 1, -default => $description);
    print $q->hidden (-name => 'location',
        -override => 1, -default => $location);
    return '';
}


=pod

=head2 show_delete_confirmation

Display the delete printer confirmation page contents.

=begin testing

$FM->{cgi}->param(-name=>'printer', -value=>'testprn');
$FM->show_delete_confirmation();
like($_STDOUT_, qr/ABOUT_TO_REMOVE/, 'show_delete_confirmation');

=end testing

=cut

sub show_delete_confirmation
{
    my $self = shift;
    my $q = $self->{cgi};

    my $printer = $q->param ('printer');
    unless ($printer)
    {
        $q->param(-name=>'wherenext', -value=>'First');
        return '';
    }

    my $adb;
    if ($self->{testing})
    {
        $adb = esmith::AccountsDB->open('30e-smith-LPRng/accounts')
            || return $self->error('ERR_OPENING_DB');
    }
    else
    {
        $adb = esmith::AccountsDB->open()
            || return $self->error('ERR_OPENING_DB');
    }

    my $rec = $adb->get($printer);
    if ($rec and $rec->prop('type') eq 'printer')
    {
        my $description = $rec->prop('Description');

        print '<tr><td>';
        print $q->p($self->localise('ABOUT_TO_REMOVE').
            "$printer ($description)");
        print $q->p($self->localise('SPOOL_FILE_WARNING'));
        print $q->p($q->b($self->localise('ARE_YOU_SURE')));
        print '</td></tr>';
    }
    return '';
}

=pod

=head2 delete_printer

Remove a printer from the accounts database

=begin testing

$FM->{cgi}->param(-name=>'printer', -value=>'testprn');
$FM->delete_printer();
like($FM->{cgi}->param('status_message'), qr/DELETED_SUCCESSFULLY/, 
'delete_printer');

=end testing

=cut

sub delete_printer
{
    my $self = shift;
    my $q = $self->{cgi};

    #------------------------------------------------------------
    # Attempt to delete printer
    #------------------------------------------------------------

    my $printer = $q->param ('printer');

    if ($printer =~ /^([a-z][a-z0-9]*)$/)
    {
        $printer = $1;
    }
    else
    {
        return $self->error('ERR_INTERNAL_FAILURE');
    }

    my $adb;
    if ($self->{testing})
    {
        $adb = esmith::AccountsDB->open('30e-smith-LPRng/accounts') 
            || return $self->error('ERR_OPENING_DB');
    }
    else
    {
        $adb = esmith::AccountsDB->open()
            || return $self->error('ERR_OPENING_DB');
    }

    my $rec = $adb->get($printer);
    unless ($rec)
    {
        return $self->error('ERR_INTERNAL_FAILURE');
    }

    $rec->set_prop('type', 'printer-deleted');
    unless ($self->{testing})
    {
        system ("/sbin/e-smith/signal-event printer-delete $printer") == 0
            or return $self->error('ERR_DELETING');
    }
    $rec->delete();

    $self->success('DELETED_SUCCESSFULLY');
}

1;
