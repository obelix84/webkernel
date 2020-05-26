#!/usr/bin/perl -w
package CommonFunction;
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

sub new{
    my $class=shift;
    my $self={};
    return bless($self,$class);
}


# *** getRandomIndexes *** * * *
# input: needCount, totalCount (needCount can be even less, equal or great than totalCount)
# output: random uniq indexes array by reference
# *** ================ *** * * *
sub getRandomIndexes($$)
{
	my ($self,$need,$total) = @_;
	
	my @res = ();
	my @internal;
	my ($i,$randIndex);

	return \@res unless ($total && $need);
	$need = $total if ($need > $total);
	@internal[0..$total-1] = 0..$total-1;
	for ($i = 0; $i < $need; $i++,$total--)
	{
		$randIndex = int(rand($total));
		push @res, $internal[$randIndex];
		splice @internal,$randIndex,1;
	}
	return \@res;
}

sub DESTROY{

}

1;
