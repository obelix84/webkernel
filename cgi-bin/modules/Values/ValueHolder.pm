#!/usr/bin/perl -w
package Values::ValueHolder;
use strict;
use utf8;
use warnings;
use diagnostics;
use strict;
use locale;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "ValueHolder: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";
use Data::Dumper;

use Values::ArrayHolder;
use Values::DictionaryHolder;
use Values::NumberHolder;
use Values::StringHolder;
use Values::LongTextHolder;

sub new
{
    my ($class, $m, $dbh) = @_;
    warn "REDIRECT";
    my $self = {
		'arrayHolder' => Values::ArrayHolder->new($m,$dbh),
		'dictionaryHolder' => Values::DictionaryHolder->new($m,$dbh),
		'numberHolder' => Values::NumberHolder->new($m,$dbh),
		'stringHolder' => Values::StringHolder->new($m,$dbh),
		'longTextHolder' => Values::LongTextHolder->new($m,$dbh)
		};
    my %typeIDs = ();
    foreach my $key (keys %{$self}) 
    {
	my $typeID = $self->{$key}->typeID();
	if (exists $typeIDs{$typeID})
	{
	    die "${key}->typeID = $typeID already used by $typeIDs{$typeID} typeHolder ";
	}
	$typeIDs{$typeID} = $key;
    }
    return bless($self, $class);
}

sub value()
{
    my ($self, $type_id, $v_id) = @_;
    foreach my $holder (keys %$self)
    {
    	if ($self->{$holder}->typeID() == $type_id)
	{
		return $self->{$holder}->value($v_id);
	}
    }
    return undef;
}

sub setValue()
{
    my ($self, $ref_data) = @_;
    warn "DATA:   $ref_data";
    my $v_id;
    my $type_id;
    my $ref = ref $ref_data;
    if ($ref =~ /^([A-Z]+)/)
    {
	my $type = $1;
	if($type eq "SCALAR")
	{
		my $el = $$ref_data;
		if ($el=~/^\d+/)
		{
			$v_id = $self->{'numberHolder'}->setValue($ref_data);
			$type_id = $self->{'numberHolder'}->typeID(); 
			warn "Number!";
		}
		else#значит это строка
		{
			my $size=length $el;
			if ($size<=255)
			{
			   $v_id = $self->{'stringHolder'}->setValue($ref_data);
			   $type_id = $self->{'stringHolder'}->typeID();		
				warn "String!";

			}
			else
			{
				$v_id = $self->{'longTextHolder'}->setValue($ref_data);
				$type_id = $self->{'longTextHolder'}->typeID();
				warn "Long Text!";
			}
		}	
	}
	elsif ($type eq "HASH")
	{
	    $v_id = $self->{'dictionaryHolder'}->setValue($ref_data);
	    $type_id = $self->{'dictionaryHolder'}->typeID();
	    warn "hash";
	}
	elsif ($type eq "ARRAY") 
	{
	    $v_id = $self->{'arrayHolder'}->setValue($ref_data);
	    $type_id = $self->{'arrayHolder'}->typeID();
	}
    }
    else
    {
    	warn "ValueHolder: Something wrong with regular expression!";
											    	}
    return ($type_id, $v_id);
}

sub typeID
{
    my $self = shift;
    # please use _helpers/value_type_id_creator/do
    # for create UNIQ ID for your type
    return 570854379;# CRC32 for "VirtualHolder"
}

sub DESTROY
{

}

1;
