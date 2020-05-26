#!/usr/bin/perl -w
package CookieCreator; 
use strict;
use utf8;
use warnings;
use diagnostics;
use locale;
use MConnect;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "MTemplate: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";
use Apache::Cookie;
use Data::Dumper;

sub new{# на вход apache_request
    my  ($class,$r)=@_;
        my  $self={};
            $self->{'params'}={};
            $self->{'params'}->{"r"}=$r;
    return bless ($self,$class);    
}

#задает параметр в куки
sub setCookie{#на вход имя параметра и згначение
    my  ($self,$name,$val)=@_;
    my $cookie = Apache::Cookie->new($self->{'params'}->{'r'},-name=>$name,-value=>$val,-path=>'/',-domain=>'cms.mitme.ru',-expires=>'');
	$cookie->bake;
    #$self->{'params'}->{'cookie'}=$cookie;
}

sub sendCookie{
    my  $self=shift;
    #$self->{'params'}->{'cookie'}->bake;
}

#получает данные о куки из сесии, или наоборот :)
sub getCookie{#на вход имя параметра
    my  $self=shift;
    my  $name=shift;
    our $inCookies;
    my $value;
    $inCookies=Apache::Cookie->fetch;
    $value = ($inCookies && exists $inCookies->{$name}) ? $inCookies->{$name}->value : undef;
    return $value;
    
}

sub deleteCookie{#имя параметра
    my  ($self,$name)=@_;
    my $cookie = Apache::Cookie->new($self->{'params'}->{'r'},-name=>$name,-value=>"",-path=>'/',-domain=>'cms.mitme.ru',-expires=>'-1d');
    $cookie->bake;  
}



sub DESTROY{

}
1;
