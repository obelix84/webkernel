#!/usr/bin/perl -w
package GetConfInfo;
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
use GetConfInfo;
use Data::Dumper;
use MConnect;
use GetParam;
 
sub new {# и еще передается migration и апаче реквест
    
    my ($class,$conf_id,$dbh,$m,$r)= @_;
    my  $GP=GetParam->new($dbh);
    my $self={'params'=>{}};#тут будет лежать хешшшш...
    #проверяем нет ли наследования параметров?
    my  $par_params={}; #Родительские параметры..
    my  $extend=0;#флаг, говорит о том есть ли наследование или нет
    my  $parental=doSql(undef,$dbh,"SELECT par_conf_id FROM web_kernel.conf_parents WHERE conf_id=?;",$conf_id);
    if(! $parental)
    {
        warn "Something with DB in cofiguration parental!";
    }
    else
    {
        my $r=$parental->fetch();
        if (!$r)
        {#наследования нет
            $extend=0;    
        }
        else
        {#наследование есть
            $extend=1;
         #извлекаем все данные о родительской конфигурации
            my  $getInfo=GetConfInfo->new($r->{par_conf_id},$dbh,$m,$r);
            $par_params=$getInfo->getParam();
        }
    }
    $parental->finish();
    
    my $res=doSql(undef,$dbh,"SELECT par_id, v_id, type_id FROM web_kernel.values WHERE conf_id=?;",$conf_id);
    if (!$res)
    {
        warn "Somthing wrong!\n";
    }else
    { 
        my $row;
        while ($row = $res->fetch){
            my $par_id=$row->{'par_id'};
            my $v_id=$row->{'v_id'};
            #вообщем, после того как мы извлекли что-то, надо извлечь название параметра
            my  $type=$GP->WhatTypeIsIt($par_id,$row->{'type_id'});
            my  @k=keys %$type;
            my  $par_name=$k[0];
            my  $val=$GP->getParValue($v_id, $type->{$par_name});
            #тут мы запендюриваем(простите за мой итальянский) в хеш, параметр со значением
            $self->{'params'}->{$par_name}=$val;        
        }
        $res->finish();
    }
    #собираем параметьры вместе
    my  $new_par;
    if ($extend)
    {
        my @k= keys %{$self->{'params'}};
        push (@k, keys %{$par_params});
        my  $par;
        foreach $par (@k)
        {
            if (exists $self->{'params'}->{$par})
            {
                $new_par->{$par}=$self->{'params'}->{$par};
            }
            elsif (exists $par_params->{$par})
            {
                $new_par->{$par}=$par_params->{$par};
            }
        }
        $self->{'params'}=$new_par;
    }
    
    #передаем MMigration, некоторым надо, некоторым нет..
    $self->{'params'}->{'MMigration'}=$m;
    $self->{'params'}->{'Apache'}=$r;
    $self->{'params'}->{'dbh'}=$dbh;
    return bless($self,$class);
}

sub getParam {#возвращает парметры данной конфигурации
    my $self=shift;
    return $self->{'params'};
}

sub DESTROY{

}

1;

