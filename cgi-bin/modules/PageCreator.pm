#!/usr/bin/perl -w

package PageCreator;
use utf8;
use warnings;
use diagnostics;
use strict;
use locale;
use MMigration;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "MTemplate: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";
use Data::Dumper;
use MConnect;
use MTemplate;
use GetTemplate;
use CompAlias;
use ConfigAlias;

#страница интерпритируется как нулевая компонента
#модуль генерирует страницу полностью

sub new{#на вход подается номер страницы и ммигратион и апаче реквест, насчет остального пока не знаю..
    my ($class,$param)=@_;
    my $self={};
    my	$m=$param->{'MMigration'};
    my	$dbh=$param->{'dbh'};
    my	$r=$param->{'Apache'};
    my	$CA=CompAlias->new($dbh);
    my	$ConfAl=ConfigAlias->new($dbh);
    #	1)Есть параметры
    #	2)Извлекаем оттуда source
    my	$GT=GetTemplate->new($param->{'source'});
    #	3)создаем шаблон
	my $tmpl = MTemplate->new('cgi-bin/modules/PageCreator.pm');#берем шаблон
	my $page = $tmpl->getTemplate('for_alien_pattern');
	my $gt=$GT->getTemplate();
	$page=$page->add('place',$gt);#запендюриваем туда все остальное
    #	4)Парсим шаблон, продолжая искать то, что нам нужно
    my	$allcomps={};
    my	$rendered=$param->{'rendered'};
    while (($gt =~ /<!--meta_([^-_\/]+)_([A-Za-z][A-Za-z\d]*|\d+)\/-->/sg))
    {
	my ($alias_comp,$alias_conf) = ($1,$2);
	my $comp;
	my $conf;
	$comp=$CA->returnCompName($alias_comp);
	$conf=$ConfAl->getNumericConfAlias($alias_conf,$comp);
	if (!(exists $rendered->{"${comp}"} && exists $rendered->{$comp}->{$conf}))
	{
	    #тут будет собираться страницы из компонент по конфигурациям
	    my $info=GetConfInfo->new($conf,$dbh,$m,$r);#информация о компоненте и ее конфигурация
	    my	$comp_parms=$info->getParam();
	    #тут создается выводимая часть страницы
	    if($comp_parms->{'compname'} eq $comp)
	    {
		my $CC=ComponentCreator->new($comp_parms,$dbh);
		#а тут ее надо вставить в страницу
		my $out=$CC->output();
		$page->add("meta_${alias_comp}_${alias_conf}",$CC->output());
	    }
	    else
	    {
		warn "Components names not equal!!!";
		$page->add("meta_${alias_comp}_${alias_conf}"," ");
	    }
	    if (! exists $rendered->{$comp})
	    {
		$rendered->{$comp}={};
	    }
	    $rendered->{$comp}->{$conf}=$conf;
	}
	else
	{
	    #а нет ли ded loopa?
	    #пока просто воткну...
	    #if (ref $rendered->{"${comp}"} scalar)
	    my	$type=ref $rendered->{$comp};
	    $page->add("meta_${alias_comp}_${alias_conf}",$rendered->{$comp}->{$conf});
	}
	$allcomps->{"${alias_comp}"}=$alias_conf;
    }    
    $self->{'template'}=$page;
    return bless($self,$class);
}

#парсит шаблон и выдает хешь со всеми компонентами и тп, если нет ничего выдает пустоту
sub parseTemplate{
    my	($self,$tmpl)=@_;
    my	$components={};
    while (($tmpl =~ /<!--meta_([^-_\/]+)_(\d+)\/-->/sg))
    {
	my ($comp,$conf) = ($1,$2);
        $components->{"$comp"}=$conf;
    }
    return $components;
}


sub output(){
    my $self=shift;
    return $self->{'template'}->output();
}

sub DESTROY{

}

1;

=for nobody

for_alien_pattern
<!--place/-->

end


=cut


