#!/usr/bin/perl -w
package SetParam; 
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
use GetParam;
use Data::Dumper;

sub new{
    my ($class,$dbh,$m)=@_;
    my	$self={};
    	$self->{'params'}->{'dbh'}=$dbh;
	$self->{'params'}->{'m'}=$m;
    return bless($self,$class);
}

sub setInt{#на выходе новый ид
    my ($self,$int)=@_;
    my  $v_id=$self->{'params'}->{'m'}->getSeqNextVal($self->{'params'}->{'dbh'},'web_kernel.seq_vid_int');
    my	$res=doSql(undef,$self->{'params'}->{'dbh'},"INSERT INTO web_kernel.vals_integer( v_id, val ) VALUES (?, ?)",$v_id,$int);
    if (!$res)
    {
	warn "Sonething wrong with DB!";
	return -1;  
    }
    return $v_id;
}

sub setString{
    my ($self,$string)=@_;
    my  $v_id=$self->{'params'}->{'m'}->getSeqNextVal($self->{'params'}->{'dbh'},'web_kernel.seq_vid_string');
    my	$res=doSql(undef,$self->{'params'}->{'dbh'},"INSERT INTO web_kernel.vals_string( v_id , val ) VALUES (?, ?)",$v_id,$string);
    if (!$res)
    {
	warn "Sonething wrong with DB!";
	return -1;  
    }
    return $v_id;
}

sub setLongString{
    my ($self,$lstring)=@_;
    my  $v_id=$self->{'params'}->{'m'}->getSeqNextVal($self->{'params'}->{'dbh'},'web_kernel.seq_vid_longstring');
    my	$res=doSql(undef,$self->{'params'}->{'dbh'},"INSERT INTO web_kernel.vals_longstring ( v_id, val ) VALUES (?, ?)",$v_id,$lstring);
    if (!$res)
    {
	warn "Sonething wrong with DB!";
	return -1;  
    }
    return $v_id;
}

#вставляет один элемент массива
sub pushElementInArray{
    my	($self,$el,$ord,$a_id,$type)=@_;
    #получаем следующий индекс ЭЛЕМЕНТА МАССИВА! который в таблице ID
    my  $m_id=$self->{'params'}->{'m'}->getSeqNextVal($self->{'params'}->{'dbh'},'web_kernel.seq_id_array');
        #вставляем сначала сам элемент 
	my $id;
	if ($type eq "integer")
	{
	    $id=$self->setInt($el);
	}
	elsif ($type eq "string")
	{
	    $id=$self->setString($el);
	}
	elsif ($type eq "longstring")
	{
	    $id=$self->setLongString($el);
	}
	elsif ($type eq "array")
	{
	    $id=$self->setArray($el);
	}
	elsif ($type eq "dictionary")
	{
	    $id=$self->setDictionary($el);
	}
	#вставляем теперь в массив
	if ($id == -1)
	{
	    warn "Sonething wrong with DB!";
	    return -1;
	}
	my $GP=GetParam->new($dbh);
	my type_id=$GP->getTypeId($type);
	my $res=doSql(undef,$self->{'params'}->{'dbh'},"INSERT INTO web_kernel.vals_array ( id,a_id,ord,type_id,v_id) VALUES (?,?,?,?,?)",$m_id,$a_id,$ord,$type_id,$id);
	if(! $res)
	{
	    warn "Something wrong with DB!";
	    return -1;
        }
    
}


#вставляет один элемент массива
sub pushElementInDictionary{
    my	($self,$el,$key,$a_id,$type)=@_;
    #получаем следующий индекс ЭЛЕМЕНТА МАССИВА! который в таблице ID
    my  $m_id=$self->{'params'}->{'m'}->getSeqNextVal($self->{'params'}->{'dbh'},'web_kernel.seq_id_dictionary');
        #вставляем сначала сам элемент 
	my $id;
	if ($type eq "integer")
	{
	    $id=$self->setInt($el);
	}
	elsif ($type eq "string")
	{
	    $id=$self->setString($el);
	}
	elsif ($type eq "longstring")
	{
	    $id=$self->setLongString($el);
	}
	elsif ($type eq "array")
	{
	    $id=$self->setArray($el);
	}
	elsif ($type eq "dictionary")
	{
	    $id=$self->setDictionary($el);
	}
	#вставляем теперь в массив
	if ($id == -1)
	{
	    warn "Sonething wrong with DB!";
	    return -1;
	}
	my $GP=GetParam->new($dbh);
	my type_id=$GP->getTypeId($type);
	my $res=doSql(undef,$self->{'params'}->{'dbh'},"INSERT INTO web_kernel.vals_dictionary ( id,a_id,dic_key,type_id,v_id) VALUES (?,?,?,?,?)",$m_id,$a_id,$key,$type_id,$id);
	if(! $res)
	{
	    warn "Sonething wrong with DB!";
	    return -1;
        }
    
}


sub setArray{#на вход передается ссылка на массив
    my ($self,$ref_arr)=@_;
    #получаем следующий индекс массива, но буедт нужен на протяжении всей вставки
    my  $a_id=$self->{'params'}->{'m'}->getSeqNextVal($self->{'params'}->{'dbh'},'web_kernel.seq_vid_array');
    my	$ord=0;
    my $el;
    foreach $el (@$ref_arr)
    {
	my $ref_el=ref \$el;
	if ($ref_el=~/^([A-Z]+)/)
	{
	    my $type=$1;
	    if($type eq "SCALAR")
	    {
	        if ($el=~/^\d+/)
	        {
		    $self->pushElementInArray($el,$ord,$a_id,"integer");
		    $ord++;
		}
		else#значит это строка
		{
		    my $size=length $el;
		    if ($size<=255)
		    {
		        $self->pushElementInArray($el,$ord,$a_id,"string");
		        $ord++;   
		    }
		    else
		    {
		        $self->pushElementInArray($el,$ord,$a_id,"longstring");
		        $ord++;   
		    }
		}
	    }
	    elsif($type eq "REF")
	    {
		my $reef=ref $el;
		if ($reef eq "HASH")
		{
		    $self->pushElementInArray($el,$ord,$a_id,"dictionary");
		    $ord++;
		}
		else
		{
		    $self->pushElementInArray($el,$ord,$a_id,"array");
		    $ord++;
		}
	    }
	}
	else
	{
	    warn "Something wrong with regular expression!";
	}
    }
    return $a_id;
}

sub setDictionary{#на вход передается ссылка на хеш-массив
    my ($self,$ref_hash)=@_;
    #получаем следующий индекс в словаре, он будет нужен на протяжении всей вставки
    my  $a_id=$self->{'params'}->{'m'}->getSeqNextVal($self->{'params'}->{'dbh'},'web_kernel.seq_vid_dictionary');
    my	$key;
    foreach $key (keys %$ref_hash)
    {
	my $temp=$ref_hash->{$key};
	my $ref_el=\$temp;
	if ($ref_el=~/^([A-Z]+)/)
	{
	    my $type=$1;
	    if($type eq "SCALAR")
	    {
		if ($ref_hash->{$key}=~/^\d+/)
	        {
		    $self->pushElementInDictionary($ref_hash->{$key},$key,$a_id,"integer");
	        }
	        else#значит это строка
	        {
			my $size=length $ref_hash->{$key};
			if ($size<=255)
			{
			    $self->pushElementInDictionary($ref_hash->{$key},$key,$a_id,"string");
			}
			else
			{
		            $self->pushElementInDictionary($ref_hash->{$key},$key,$a_id,"longstring");
			}
	        }
	    }
	    elsif($type eq "REF")
	    {
	       my $reef=ref $ref_hash->{$key};
	       if ($reef eq "HASH")
	       {
		$self->pushElementInDictionary($ref_hash->{$key},$key,$a_id,"dictionary");
	       }
	       else
		{
		    $self->pushElementInDictionary($ref_hash->{$key},$key,$a_id,"array");
		}
	    }
	}
	else
	{
	    warn "Something with ref in Set parms!!!!"
	}
	
    }
    return $a_id;
}

sub DESTROY{

}

1;
