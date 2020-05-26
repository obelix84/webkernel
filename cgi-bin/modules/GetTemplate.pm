#!/usr/bin/perl -w
package GetTemplate;
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
use Data::Dumper;
use MFunctions;

sub new{#подается строка на вход там указывается откуда брать чего, и как зовут
    my ($class,$string)=@_;
    my $self={};
       
    my @a=split(/:/,$string,2);
    my $wisit=$a[0];
    my $what=$a[1];
    $wisit =~ s/\s+$//gos;
    $what =~ s/\s+$//gos;
    if ($wisit eq 'FILE'){
        $self->{'template'}=ReadFile("templates/${what}.tmpl");
     
    }
    return bless($self,$class);
}


sub getTemplate{
    my $self=shift;
    return $self->{'template'};
}


sub DESTROY{

}


1;