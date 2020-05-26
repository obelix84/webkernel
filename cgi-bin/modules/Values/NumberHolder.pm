#!/usr/bin/perl -w
package Values::NumberHolder;
use strict;
use utf8;
use warnings;
use diagnostics;
use strict;
use locale;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "NumberHolder: no locale $locale" if ($new_locale ne $locale);
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
    my $val_query = doSql(undef, $self->{'dbh'},"SELECT val FROM web_kernel.vals_number WHERE v_id = ? ", $v_id);
    if (! $val_query)
    {
	    warn "NumberHolder: Something wrong with DB!!!";
    }
    else
    {
	    my $val = $val_query->fetch();
	    if ($val)
	    {
	    	my $ret = $val->{'val'}; 
	    	return \$ret;
	    }
    }
    return -1;
}

sub setValue($)
{
    my ($self, $ref_data) = @_;
    my  $v_id = $self->{'m'}->getSeqNextVal($self->{'dbh'},'web_kernel.seq_vid_number');
    my	$res = doSql(undef, $self->{'dbh'}, "INSERT INTO web_kernel.vals_number( v_id, val ) VALUES (?, ?)", $v_id, $$ref_data);
	if (!$res)
	{
	 	warn "NumberHolder: Something wrong with DB!";
		return -1;  
	}
	return ($self->typeID(), $v_id);
}

sub typeID
{
    my $self = shift;
    # please use _helpers/value_type_id_creator/do
    # for create UNIQ ID for your type
    return 4165261607;# CRC32 for "NumberHolder"
}

sub DESTROY
{

}

1;
