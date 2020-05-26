#!/usr/bin/perl -w
package CompAlias;
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
use MConnect;

sub new{#на вход база
    my	($class,$dbh)=@_;
    my	$self={};
    $self->{'dbh'}=$dbh;
    return bless($self,$class);
}

#если есть такой алиас возвращает соответсвующую, ему 
sub returnCompName{#на вход имя
    my	($self,$compname)=@_;
    #делаем запрос в алиас, и смотрим,что будет
    my	$res=doSql(undef,$self->{'dbh'},"SELECT class_name FROM web_kernel.components WHERE comp_id=(SELECT comp_id FROM web_kernel.comp_aliases WHERE compname_alias=?)",$compname);
    if (!$res)
    {
	warn "Something with database in component aliases!";
    }
    else
    {
	my $r=$res->fetch();
	if($r)
	{
	    return $r->{'class_name'};    
	}
	else
	{
	    return $compname;
	}
    }
}

sub DESTROY{

}

1;