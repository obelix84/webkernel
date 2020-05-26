#!/usr/bin/perl -w
package Values::DictionaryHolder;
use strict;
use utf8;
use warnings;
use diagnostics;
use strict;
use locale;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "DictionaryHolder: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";
use MConnect;

sub new
{
    my ($class, $m, $dbh) = @_;
    my $self = { 
	    'dbh' => $dbh,
	    'm' => $m
	    }; 
    return bless($self, $class);
}

sub value($)
{
    my ($self, $v_id) = @_;
    return -1;
}

sub setValue($)
{
    my ($self, $data) = @_;
    return -1;
}

sub typeID
{
    my $self = shift;
    # please use _helpers/value_type_id_creator/do
    # for create UNIQ ID for your type
    return 2917877050;# CRC32 for "DictionaryHolder"
}

sub DESTROY
{

}

1;
