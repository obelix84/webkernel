#!/usr/bin/perl -w
package Values::LongTextHolder;
use strict;
use utf8;
use warnings;
use diagnostics;
use strict;
use locale;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "LongTextHolder: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";
use MConnect;

sub new
{
    my ($class, $m, $dbh) = @_;
    my $self = { 
	    'dbh' => $dbh,
	    'm' => $m
	    };
    return bless($self, $class);
}

sub value($)
{
    my ($self, $v_id) = @_;
    my $val=doSql(undef,$self->{'dbh'},"SELECT val FROM web_kernel.vals_longtext WHERE v_id=? " , $v_id);
    if (! $val)
    {
   	warn "LongTextHolder: Something with DB in get long text!";
	return undef;
    }
    else
    {
    	my $v=$val->fetch();
	$val->finish();
	if ($v)
	{
		my $ret = $v->{'val'};
		return \$ret;
	}
    }

return undef;

}

sub setValue($)
{
    my ($self, $ref_data) = @_;
    my  $v_id = $self->{'m'}->getSeqNextVal($self->{'dbh'},'web_kernel.seq_vid_longtext');
    my	$res = doSql(undef, $self->{'dbh'}, "INSERT INTO web_kernel.vals_longtext( v_id, val ) VALUES (?, ?)", $v_id, $ref_data);
	if (!$res)
	{
	 	warn "LongTextHolder: Something wrong with DB!";
		return -1;  
	}
	return ($self->typeID(), $v_id);

}

sub typeID
{
    my $self = shift;
    # please use _helpers/value_type_id_creator/do
    # for create UNIQ ID for your type
    return 2326232113;# CRC32 for "LongTextHolder"
}

sub DESTROY
{

}

1;
