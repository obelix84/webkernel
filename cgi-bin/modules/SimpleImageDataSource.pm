#!/usr/bin/perl -w
package SimpleImageDataSource;
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
use CommonFunction;
use Data::Dumper;

sub new{#на вход поступает conf_id и указатель на базу
    my	($class,$params)=@_;
    my	$self={};
    #формируем хеш массив согласованный с designerом	
	$self->{'params'}->{'items'}=$params->{'items'};
	$self->{'params'}->{'limit'}=$params->{'limit'};
	my $total=scalar @{$params->{'items'}};
	bless($self,$class);
    my	$CF=CommonFunction->new();
    my	$arr=$CF->getRandomIndexes($params->{'limit'},$total);
	$self->{'params'}->{'rand_ind'}=$arr;
    return $self;
}

sub count{
    my $self = shift;
    my $total = scalar @{$self->{'params'}->{'items'}};
    my $count = $self->{'params'}->{'limit'} < $total ? $self->{'params'}->{'limit'} : $total;
    return $count;
}

sub objectAtIndex{
    my ($self,$ind)=@_;
    my $rind=$self->{'params'}->{'rand_ind'};
    my $arr=$self->{'params'}->{'items'};
    return @$arr[@$rind[$ind]];
}

sub DESTROY{

}

1;
