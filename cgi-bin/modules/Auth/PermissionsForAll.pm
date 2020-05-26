#!/usr/bin/perl -w

package Auth::PermissionsForAll;

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
use Data::Dumper;


sub new{
    my ($class,$m)=@_;
    my $dir=$m->getDocumentRoot().'/caches/permissions/';
    local *DIR;
    opendir(DIR, $dir) || warn "Something with directory ${dir}!";
    my $self={'permissions'=>{}};  
    my $r;
    #номер конфигурации
    while($r=readdir(DIR)){
        if ($r ne "." && $r ne ".."){
            opendir(SUBDIR, $dir."${r}/");
            my $sd;
            $self->{'permissions'}->{$r}={};
            #имя пользователя
            while($sd=readdir(SUBDIR)){
                if ($sd ne "." && $sd ne ".."){
                    $self->{'permissions'}->{$r}->{$sd}={};
                    my $perm="";
                    my $ln;
                    local * FFF;
                    open(FFF,"<${sd}");
                    foreach $ln (<FFF>){
                        $ln=~s/\s+$//gos; 
                        $self->{'permissions'}->{$r}->{$sd}->{$ln}=1; 
                    }
                    close(FFF);
                }
            }
        }
    }
    return bless($self,$class);
}

sub getAllPerm{
    my $self=shift;
    return $self->{'permissions'};
}

sub DESTROY{

}

1;

