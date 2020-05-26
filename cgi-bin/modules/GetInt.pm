#!/usr/bin/perl -w
package GetInt;
use strict;
use utf8;
use warnings;
use diagnostics;
use strict;
use locale;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "MTemplate: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";

#на вход БД
sub new{
    my	($class,$self)=@_;
    my	$self={};
	$self->{'dbh'};
    return bless ($self,$class);
}

sub getInt{# id на вход, на выходе инт, если такого нет то undef
    my	$self=shift;
    my $val=doSql(undef,$dbh,"SELECT val FROM web_kernel.vals_int WHERE v_id=?",$v_id);
    if (! $val)
    {
	warn "Something with DB in get int!";
	return undef;
    }
    else
    {
	my $v=$val->fetch();
	$val->finish();
	if (!$v)
	{
	    return 
	}
	else
	{
	    return $v->{'val'};
	}
    }
}

sub DESTROY{

}

1;
