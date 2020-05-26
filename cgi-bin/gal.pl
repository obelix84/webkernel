#!/usr/bin/env perl
use strict;
use warnings;
use diagnostics;
#тестовый пример, на примере фотогаллереи
#для нормальной кодировки
use utf8;
use locale;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "att: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";
#типо прослойка...
use MMigration;

our $r = shift;# apache data request
our $m = MMigration->new($r);

our $tmpl = MTemplate->new;
our $tm = $tmpl->getTemplate('main');
our $tmpl2 = MTemplate->new;
our $tm2=$tm->getTemplate('image');
$m->print($tm->output());


=for nobody

main
<html>
<head><title>Моя фото галлерея!</title></head>
<body>
<--image/-->
</body>
</html>

image
<img src>

end
=cut