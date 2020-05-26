#!/usr/bin/perl -w
package ArrayCreator;
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
#работает с масиивами в таблице массивов

sub new{#на вход указатель на базу
    my ($class,$dbh)=@_;
    my	$self={};
	$self->{'dbh'}=$dbh;
    return bless($self,$class);
}

#добавляет массив в базу
sub addArrayToDB{

}

#извлекает массив из базы
sub getArrayFromDB{#на вход ид массива, на выходе ссыдка на хеш
    my	($self,$a_id)=shift;
    my	$array={};
    my	$res=doSQL(undef,$self->{'dbh'},"SELECT v_id, type_id FROM web_kernel.vals_array WHERE a_id=? ORDER BY ord",$a_id);
    
}

sub dropArrayFromDB{

}

sub DESTROY{

}

1;
