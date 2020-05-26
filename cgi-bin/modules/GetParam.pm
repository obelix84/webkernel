#!/usr/bin/perl -w
package GetParam;
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
use MConnect;
use Data::Dumper;


sub new{
    my	($class,$dbh)=@_;
    my	$self={};
	$self->{'dbh'}=$dbh;
    return bless ($self,$class);
}

sub getString{# id 
    my	($self,$v_id)=@_;
    my $val=doSql(undef,$self->{'dbh'},"SELECT val FROM web_kernel.vals_string WHERE v_id=?",$v_id);
    if (! $val)
    {
	warn "Something with DB in get int!";
	return undef;
    }
    else
    {
	my $v=$val->fetch();
	$val->finish();
	if (!$v)
	{
	    return undef;
	}
	else
	{
	    return $v->{'val'};
	}
    }
}


sub getLongString{# id 
    my	($self,$v_id)=@_;
    my $val=doSql(undef,$self->{'dbh'},"SELECT val FROM web_kernel.vals_longstring WHERE v_id=? " , $v_id);
    if (! $val)
    {
	warn "Something with DB in get int!";
	return undef;
    }
    else
    {
	my $v=$val->fetch();
	$val->finish();
	if (!$v)
	{
	    return undef;
	}
	else
	{
	    return $v->{'val'};
	}
    }
}


sub getInt{# id 
    my	($self,$v_id)=@_;
    my $val=doSql(undef,$self->{'dbh'},"SELECT val FROM web_kernel.vals_integer WHERE v_id=?",$v_id);
    if (! $val)
    {
	warn "Something with DB in get int!";
	return undef;
    }
    else
    {
	my $v=$val->fetch();
	$val->finish();
	if (!$v)
	{
	    return undef;
	}
	else
	{
	    return $v->{'val'};
	}
    }
}

#определяет какого типа переменная из таблицы в БД
sub WhatTypeIsIt{
    my	($self,$par_id,$type_id)=@_;
    #делаем запрос о типе параметра
    my	$res=doSql(undef,$self->{'dbh'},"SELECT par_name FROM web_kernel.param_names WHERE par_id=?",$par_id);
    if (!$res)
    {
	warn "Something with DB!";
    }
    else
    {
	my $r=$res->fetch;
	my $parname=$r->{'par_name'};
	if (!$r)
	{
	    $res->finish;
	    return 0;
	}
	else
	{
	    $res->finish;
	    my	$text_type=doSql(undef,$self->{'dbh'},"SELECT type FROM web_kernel.value_types WHERE type_id=?",$type_id);
	    if (!$text_type)
	    {
		warn "Some thing with DB!!!";
	    }
	    else
	    {
		my $r=$text_type->fetch;
		$text_type->finish;
		my $ret={};
		$ret->{$parname}=$r->{'type'};
		return $ret;
	    }
	}
    }
}

sub getTypeId{
    my ($self,$type_name)=@_;
    my	$type_query=doSql(undef,$self->{'dbh'},"SELECT type_id FROM web_kernel.value_types WHERE type=?",$type_name);
    if(! $type_query)
    {
	warn "getTypeId: Something wrong with DB in get param!";
	return -1;
    }
    my $r=$type_query->fetch();	
    $type_query->finish();
    if (! $r)
    {
	warn "getTypeId: Type not found!";
	return -1;
    }
    return $r->{'type_id'};
}


sub getParValue{#v_id, а так же type на вход 
    my	($self,$v_id,$type)=@_;
    if ($type eq "integer")
    {
	my $t=$self->getInt($v_id);
	return $t;
    }
    elsif ($type eq "string")
    {
	my $t=$self->getString($v_id);
	return $t;
    }
    elsif ($type eq "longstring")
    {
	my $t=$self->getLongString($v_id);
	return $t;
    }
    elsif ($type eq "array")
    {
	my @t=$self->getArray($v_id);
	return \@t;
    }
    elsif ($type eq "dictionary")
    {
	my $t=$self->getDictionary($v_id);
	return $t;
    }
    return undef;
}

sub getArray{#на вход id массива, на выходе массив,если такого массива нет то ундеф
    my	($self,$a_id)=@_;
    my	@array;
    my	$res=doSql(undef,$self->{'dbh'},"SELECT ord, type_id, v_id FROM web_kernel.vals_array WHERE a_id=? ORDER BY ord ",$a_id);
    if (! $res)
    {
	warn "Something with database!!!";
    }
    else
    {
	
	my $r;
	my $empty_flag=0;
	while ($r=$res->fetch())
	{
	    $empty_flag=1;
	    my $type=$self->WhatTypeIsIt($r->{'type_id'});
	    my  @k=keys %$type;
            my  $par_name=$k[0];
		$type=$type->{$par_name};
	    if ($type eq "integer")
	    {
		my $t=$self->getInt($r->{'v_id'});
		push(@array,$t);
	    }
	    elsif ($type eq "string")
	    {
		my $t=$self->getString($r->{'v_id'});
		push(@array,$t);
	    }
	    elsif ($type eq "array")
	    {
		my @t=$self->getArray($r->{'v_id'});
		push(@array,\@t);
	    }
	    elsif ($type eq "dictionary")
	    {
		my $t=$self->getDictionary($r->{'v_id'});
		push(@array,$t);
	    }
	}
	if ($empty_flag==0)
	{
	    return undef;
	}
	else
	{
	    return @array;
	}
    }
}

sub getDictionary{#на вход id словаря, на выходе ссылка на словарь,если такого нет то ундеф
    my	($self,$a_id)=@_;
    my	$dic={};
    my	$res=doSql(undef,$self->{'dbh'},"SELECT dic_key, par_id, v_id FROM web_kernel.vals_dictionary WHERE a_id=?",$a_id);
    if (! $res)
    {
	warn "Something with database!!!";
    }
    else
    {
	my $r;
	my $empty_flag=0;
	while ($r=$res->fetch())
	{
	    $empty_flag=1;
	    my $type=$self->WhatTypeIsIt($r->{'par_id'});
	    my  @k=keys %$type;
            my  $par_name=$k[0];
		$type=$type->{$par_name};
	    if ($type eq "integer")
	    {
		my $t=$self->getInt($r->{'v_id'});
		$dic->{$r->{'dic_key'}}=$t;
	    }
	    elsif ($type eq "string")
	    {
		my $t=$self->getString($r->{'v_id'});
		$dic->{$r->{'dic_key'}}=$t;
	    }
	    elsif ($type eq "array")
	    {
		my @t=$self->getArray($r->{'v_id'});
		$dic->{$r->{'dic_key'}}=\@t;
	    }
	    elsif ($type eq "dictionary")
	    {
		my $t=$self->getDictionary($r->{'v_id'});
		$dic->{$r->{'dic_key'}}=$t;
	    }
	}
	if ($empty_flag==0)
	{
	    return undef;
	}
	else
	{
	    return $dic;
	}
    }
}



sub DESTROY{

}

1;
