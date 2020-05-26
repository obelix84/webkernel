#!/usr/bin/perl -w
#Формирует компоненту по заданной конфигурации и заданном имени компоненты

package ComponentCreator;
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

use Data::Dumper;
use MConnect;
use GetConfInfo;


sub new{#на вход подается ссылка на хеш с параметрами,comp_id,дескриптор базы   
    my ($class,$params,$dbh)=@_;    
    #теперь надо раскрутить все это дело, подключить модуль и тп
    my  $comp;
    my  $cn=$params->{'compname'};
    require "${cn}.pm";#модуль добавляем
    my $string="\$comp=${cn}->new(\$params);";
    eval $string;
    my  $self={'params'=>{}};
        $self->{'params'}->{'component'}=$cn;
        if ($comp)
        {
            $self->{'params'}->{'out'}=$comp->output();
        }
        else
        {
            warn "Component ${cn} can't be  rendered!!!";
        }
        #($comp && exists $comp->{'template'} && $comp->{'template'}) ? $comp->{'template'}->output():'';
    return bless($self,$class);
}

sub output(){
    my $self=shift;
    $self->{'params'}->{'out'};
}

sub getSecName(){
    my $self=shift;
    return $self->{'params'}->{'component'};
}

sub DESTROY{

}

1;
