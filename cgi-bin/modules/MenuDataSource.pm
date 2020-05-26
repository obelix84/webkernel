#!/usr/bin/perl -w
package MenuDataSource;
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

sub new{
    my	($class,$params)=@_;
    my	$self={};
	$self->{'params'}->
    return bless($self,$class);
}

sub DESTROY{
}


1;