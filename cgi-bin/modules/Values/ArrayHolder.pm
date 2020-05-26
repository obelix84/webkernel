#!/usr/bin/perl -w
package Values::ArrayHolder;
use strict;
use utf8;
use warnings;
use diagnostics;
use strict;
use locale;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "ArrayHolder: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";
use MConnect;
use Values::ValueHolder;

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
    my $valHold = Values::ValueHolder->new ($self->{'m'}, $self->{'dbh'});
    my	@array;
    my	$res = doSql(undef, $self->{'dbh'}, "SELECT ord, type_id, v_id FROM web_kernel.vals_array WHERE a_id=? ORDER BY ord ", $v_id);
    if (! $res)
    {
	warn "ArrayHolder: Something with database!!!";
    	return undef;
    }
    else
    {
    	my $empty_flag=0;
	my $row;
	while ($row = $res->fetch())
	{
		$empty_flag=1;
		my $element = $valHold->value($row->{'type_id'}, $row->{'v_id'}); 	
		push(@array, $element);
	}
	if (! $empty_flag)
	{
		return undef;
	}
    }
    return \@array; 
}

sub setValue($)
{
    my ($self, $ref_data) = @_;
    my $valHold = Values::ValueHolder->new ($self->{'m'}, $self->{'dbh'});
    #следующий индекс массива
    my  $a_id = $self->{'m'}->getSeqNextVal($self->{'dbh'}, 'web_kernel.seq_vid_array');
    my	$ord = 0;
    my $elem;
    foreach $elem (@$ref_data)
    {
    	my @type_vid = $valHold->setValue(\$elem);
    	my  $id = $self->{'m'}->getSeqNextVal($self->{'dbh'}, 'web_kernel.seq_id_array');
	my $res = doSql(undef, $self->{'dbh'}, "INSERT INTO web_kernel.vals_array ( id,a_id,ord,type_id,v_id) VALUES (?,?,?,?,?)", $id, $a_id, $ord, $type_vid[0], $type_vid[1]);
    	$ord++;
	if (! $res)
	{
		warn "ArrayHolder: Something wrong with DB!!!";
		return -1;
	}
    } 	
    return ($self->typeID(), $a_id);
}

sub typeID
{
    my $self = shift;
    # please use _helpers/value_type_id_creator/do
    # for create UNIQ ID for your type
    return 1440690368;# CRC32 for "ArrayHolder"
}

sub DESTROY
{

}

1;
