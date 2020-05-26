#!/usr/bin/perl -w
use strict;
package SimpleImageDesigner;
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
use MTemplate;
use Resource;
use ConfigAlias;
use GetTemplate;
use Data::Dumper;

sub new{#на вход параметры необходимые для извлечения совей конфигурации
    my ($class,$par)=@_;
    #получаем шаблон внем содержится 3 шаблона, их все надо вынуть 
	my $GT=GetTemplate->new($par->{'source'});
	my $gt=$GT->getTemplate();
	my $res=Resource->new("templatesindirect",$gt);
    my	$self={};
	$self->{'params'}={};
	#теперь из шаблона вынимаем и делим на 3 составляющий Х, Ф и рек.
	$self->{'params'}->{'header'}=$res->getVal('header');
	$self->{'params'}->{'footer'}=$res->getVal('footer');
	$self->{'params'}->{'record'}=$res->getVal('record');
    return bless($self,$class);
}

sub header{
    my $self=shift;
    return $self->{'params'}->{'header'};
}

sub record{# $item - ссылка на хеш с парметрами конфигурации
    my ($self,$item)=@_;
    my $tmpl = MTemplate->new('cgi-bin/modules/SimpleImageDesigner.pm');#берем шаблон
    my $rec = $tmpl->getTemplate('for_alien_pattern');
    $rec=$rec->add('place',$self->{'params'}->{'record'});#запендюриваем туда все остальное
    $rec->add('imagehref',$item->{'imagehref'});
    $rec->add('href',$item->{'href'});
    $rec->add('text',$item->{'text'});
    return $rec->output();
}


sub footer{
    my $self=shift;
    return $self->{'params'}->{'footer'};
}

sub DESTROY{

}

1;

=for nobodies

for_alien_pattern
<!--place/-->

end

=cut