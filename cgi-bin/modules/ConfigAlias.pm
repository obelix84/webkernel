#!/usr/bin/perl -w
package ConfigAlias;
use strict;
use utf8;
use warnings;
use diagnostics;
use locale;
use MMigration;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "MTemplate: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";
use MConnect;
use Data::Dumper;

sub new{#на вход dbh
    my	($class,$dbh)=@_;
    my	$self={};
	$self->{'dbh'}=$dbh;
    return bless($self,$class);
}

#возвращает числовой эквивалент
sub getNumericConfAlias{#имя на вход и компоненты имя
    my	($self,$alias,$compname)=@_;
    #проверяем алиас или число?
    if ($alias =~ /^\d+$/)
    {
	return $alias;
    }
    else
    {
	my $res=doSql(undef,$self->{'dbh'},"SELECT conf_id FROM web_kernel.conf_aliases WHERE nameconf=? AND comp_id=(SELECT comp_id FROM web_kernel.components WHERE class_name=?)",$alias,$compname);
	if (!$res)
	{
	    warn "Something with DB in cofigurations aliases!!!";
	}
	else
	{
	    my $r=$res->fetch;
	    return $r->{conf_id};   
	}
	return 0;
    }
}

sub DESTROY{

}

1;

