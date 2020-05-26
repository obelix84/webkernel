#!/usr/bin/perl -w
package List;
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
use ConfigAlias;
use GetConfInfo;
use Data::Dumper;

sub new{#парметры на вход
    my	($class,$params)=@_;
    my	$self={};
    my	$dataSource;
    my	$Desig;
    my	$datasrc=$params->{'dataSource'};
    my	$designer=$params->{'designer'};
    my	$ConfAlias=ConfigAlias->new($params->{'dbh'});
    #формируем источник данных
    if ($datasrc =~ /^([A-Za-z][A-Za-z\d]*)_([A-Za-z][A-Za-z\d]*|\d+)$/)
    {	
	my ($comp,$conf)=($1,$2);
	$conf=$ConfAlias->getNumericConfAlias($conf);
	my $info=GetConfInfo->new($conf,$params->{'dbh'},$params->{'MMigration'},$params->{'Apache'});
	my $comppar=$info->getParam();
	require "${comp}.pm";#модуль добавляем
	my $string="\$dataSource=${comp}->new(\$comppar);";#конструктор...
	eval $string;    
    }
    else
    {
    	warn "Something wrong with regular expression in list package!";
    }
    #формируем дизайнер
    if ($designer =~ /^([A-Za-z][A-Za-z\d]*)_([A-Za-z][A-Za-z\d]*|\d+)$/)
    {	
	my ($comp,$conf)=($1,$2);
	$conf=$ConfAlias->getNumericConfAlias($conf);
	my $info=GetConfInfo->new($conf,$params->{'dbh'},$params->{'MMigration'},$params->{'Apache'});
	my $comppar=$info->getParam();
	require "${comp}.pm";#модуль добавляем
	my $string="\$Desig=${comp}->new(\$comppar);";#конструктор...
	eval $string;    
    }
    else
    {
    	warn "Something wrong with regular expression in list package!";
    }
    #все сформировали, теперь можно строить вывод
    my	$out;
    if ($Desig && $dataSource)
    {
	$out=$Desig->header;
	my $i;
	my $count=$dataSource->count();
	for($i=0;$i<$count;$i++)
	{
	    my $rec=$Desig->record($dataSource->objectAtIndex($i));
	    $out=$out.$rec;
	}
	$out=$out.$Desig->footer();
    }
    else
    {
	warn "Can't creat Designer!";
    }
    $self->{'output'}=$out;
    return bless($self,$class);
}

sub DESTROY{

}

sub output{
    my $self=shift;
    return $self->{'output'};
}

1;
