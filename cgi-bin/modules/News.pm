#!/usr/bin/perl -w


package News;
use strict;
use diagnostics;
use warnings;
use MTemplate;

use utf8;
use strict;
use locale;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "MTemplate: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";
       
sub new {
            my $class= shift;
            my $params= shift ;
            my $m=$params->{'MMigration'};
            my $self={'template'=>undef};
            my $tmpl = MTemplate->new('cgi-bin/modules/News.pm');
            my $tnews = $tmpl->getTemplate('news');
            $tnews->add('date',$m->formatTime($params->{'date'}));
            $tnews->add('newszag',$params->{'newszag'});
            $tnews->add('newstext',$params->{'newstext'});
		$self->{'template'} = $tnews;
            return bless($self,$class);
}
        
sub output{
	my $self = shift;
        return $self->{'template'}->output();
}
        
sub DESTROY{
        
}

1;
    
=for nobody

news
<table width="400" class="news">
  <tr>
    <td width="92" class="news_date"><!--date/--></td>
    <td width="292" class="news_zag"><!--newszag/--></td>
  </tr>
  <tr>
    <td colspan="2" class="news_text"><!--newstext/--></td>
  </tr>
</table>

end
=cut
