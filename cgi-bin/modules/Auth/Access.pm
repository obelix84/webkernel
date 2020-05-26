#!/usr/bin/perl -w
#проверяет наличие доступа пользователя к данной конфигурации страницы

package Auth::Access;
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

sub new{#migration,пользователь, конфигурация 
    my ($class,$m,$user,$conf_id)=@_;
    my $dir=$m->getDocumentRoot().'/caches/permissions/'.$conf_id;
    local *DIR;
    opendir(DIR, $dir) || warn "Something with directory ${dir}!";
    my $d;
    my $name_file="";
    while($d=readdir(DIR)){
        warn Dumper($d);
        if($d eq "${user}"){
            $name_file=$d;
            last;
        }
    }
    closedir(DIR);
    my $self;
    if(!$name_file){
        $self={"access"=>0};    
    }else{
        $self={"access"=>{}}; 
        local * FFF;
        open (FFF,"<${name_file}");
        my $ln;
        foreach $ln (<FFF>){
            $self->{'access'}->{$ln}=1;   
        }
        close (FFF);
    }
    return bless($self,$class);
}

sub hasPerm{
    my $self=shift;
    my $perm=shift;
    if($self->{'access'}){
        my $h=$self->{'access'};
        my @k=keys %{$h};
        warn Dumper(@k);
        my $i;
        my $count=0;
        foreach $i (@k){
            $i=~s/\s+$//gos;
            if ($perm eq $i){
                $count++;
            }
        }
        if ($count){
            return $count;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}

sub DESTROY{

}

1;

