#!/usr/bin/perl -w

package Auth::CachePerm;
use strict;
use warnings;
use diagnostics;
use MConnect;
use MMigration;

use utf8;
use strict;
use locale;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "MTemplate: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";

sub new { #передается дескриптор базы,который определяется в главной программе
    my $class= shift;
    my $m=shift;
    my $dbh=shift;
   
    system("rm -rf ".$m->getDocumentRoot()."/caches/permissions/*");
    #для начала надо убить все папки, которые были до этого
    #выбираем все conf_id из таблицы, которые только могут быть
    my $res=doSql(undef,$dbh,"SELECT DISTINCT conf_id FROM web_kernel.values;");
    my $row;
    umask 0077;
    chdir("".($m->getDocumentRoot()).'/caches/permissions');# заходим в каталог
    if (!$res){   
         warn "Some trouble!\n";
    }
    else {
        #для others
	while ($row = $res->fetch){
             #если каталог есть, то все ок, если нет рисуем еще один новый каталог
 	    if (!chdir($m->getDocumentRoot() . '/caches/permissions/'.$row->{conf_id})){
                mkdir($m->getDocumentRoot().'/caches/permissions/'.$row->{conf_id},0700);
	    }
            #делаем запрос
            # для OTHERS
	    my $permid=doSql(undef,$dbh,"SELECT DISTINCT perm_id FROM web_kernel.other WHERE conf_id=?;",$row->{conf_id} );
            chdir($m->getDocumentRoot() . '/caches/permissions/'.$row->{conf_id});
	    my $dir=$m->getDocumentRoot() . '/caches/permissions/'.$row->{conf_id};
	    chdir ($dir);
	    local *DEF;
	    my $r;
	    #первая итерация, проверяем, есть ли там вообще что-то тут...
	    if ($r=$permid->fetch){
		open (DEF,">default");
		my $permtype=doSql(undef,$dbh,"SELECT perm_type FROM web_kernel.permissions WHERE perm_id=?;",$r->{perm_id} ); 
		my $p=$permtype->fetch;
		print DEF $p->{perm_type}."\n";
	    }
	    while ($r=$permid->fetch){
               my $permtype=doSql(undef,$dbh,"SELECT perm_type FROM web_kernel.permissions WHERE perm_id=?;",$r->{perm_id} ); 
               my $p=$permtype->fetch;
	       print DEF $p->{perm_type}."\n";
	       $permtype->finish();
            }
            close (DEF);
            $permid->finish;
         #для others
	#для всех остальных пользователей, в цикле перебираются все конфигурации,
	#теперь надо раскрутить все группы и всех пользователей для нее
	#из пользователей
        my $uid_uperm=doSql(undef,$dbh,"SELECT DISTINCT u_id FROM u_perm WHERE conf_id=?;",$row->{conf_id} );
	#чисто группы
	my $gid_gperm=doSql(undef,$dbh,"SELECT DISTINCT g_id FROM g_perm WHERE conf_id=?;",$row->{conf_id} );
	#теперь надо чисто список всех ID пользователей	 из групп
	my @uid=();
	    #из групп достаем
	    while ($r=$gid_gperm->fetch){
		my $uid_from_group=doSql(undef,$dbh,"SELECT DISTINCT u_id FROM UG WHERE g_id=?;",$r->{g_id} );
		#получем таблицу пользователей, которых надо чисто загнать в массив, учитывая повторы..
		while ($r=$uid_from_group->fetch){
		    #сначала сравниваем, а не было ли раньше такого пользоваьеля, ибо нам не нужны повторея
		    my $t;
		    my $count;
		    $count=0;
		    foreach $t (@uid){
			if ($t==$r->{u_id}){
			    $count++;
			}
		    }
		    if ($count==0){# если не было, то пихаем его туда..
			push (@uid,$r->{u_id});
		    }
		}
		$uid_from_group->finish();
	    }
	    #из пользователей достаем
	    while ($r=$uid_uperm->fetch){
		    #сначала сравниваем, а не было ли раньше такого пользоваьеля, ибо нам не нужны повторея
		    my $t;
		    my $count;
		    $count=0;
		    foreach $t (@uid){
			if ($t==$r->{u_id}){
			    $count++;
			}
	            }
		    if ($count==0){# если не было, то пихаем его туда..
			push (@uid,$r->{u_id});
		    }
	    }
	    #теперь U_ID содержит всех пользователей для какой-то конфигурации
	    #теперь, зная пользователя и конфигурацию, крутим все таблицы и собираем в них perm_id
	    #опять же проверяем, чтобы не было повторений...
	    #как и в старь, если каталог есть, то все ок, если нет рисуем еще один новый каталог
            if (!chdir($m->getDocumentRoot() . '/caches/permissions/'.$row->{conf_id})){
                mkdir($m->getDocumentRoot().'/caches/permissions/'.$row->{conf_id},0700);
	    }#нарисовали
	    chdir($m->getDocumentRoot() . '/caches/permissions/'.$row->{conf_id});#нефиг лазить там где не надо..
	    my $t;
	    foreach $t (@uid){ # с каждым пользователем, придется спокойно поговорить лично.
		#надо озвучить, что делать дальше, создаем массив для каждого пользователя, и в него кидаем права в текстовом виде
		#потом тоже самое из групп, ну что же, он сказал поехали, он взамахнул рукой..
		my %perms=(); #хеш массив с правами, точнее с ID прав...
		my $uper=doSql(undef,$dbh,"SELECT DISTINCT perm_id FROM u_perm WHERE u_id=? AND conf_id=?;",$t, $row->{conf_id});
		while ($r=$uper->fetch){# надо распотрашить
		    $perms{$r->{perm_id}}=1;  #собираем вс права пользователя в одну кучу.. 
		}
		$uper->finish();
		#получаем группы в которые входит пользователь
		my $group_id=doSql(undef,$dbh,"SELECT DISTINCT g_id FROM UG WHERE u_id=?;",$t);
		while ($r=$group_id->fetch){# потрашим...
		   # теперь надо все права для этих групп собрать в хеш...
		   my $group_perm_id=doSql(undef,$dbh,"SELECT DISTINCT perm_id FROM g_perm WHERE g_id=? AND conf_id=?;",$r->{g_id},$row->{conf_id});
		   my $g;
		   while ($g=$group_perm_id->fetch){# потрашим group_perm_id...
			 $perms{$g->{perm_id}}=1;#запендюриваем (итальянское слово, прим. автора кода)
		   }
		   $group_perm_id->finish();
		}
		$group_id->finish();
		#теперь надо все загнать в файл с именем юзера, и права в столбик...
		my $username=doSql(undef,$dbh,"SELECT DISTINCT uname FROM web_kernel.users WHERE u_id=?;",$t); 
                my $name=$username->fetch;
		my $n=$name->{uname};
		local *USERPERM;
		open (USERPERM,">${n}");
		my @permissions= keys %perms;
		my $pi;
		foreach $pi (@permissions){
		    my $pername=doSql(undef,$dbh,"SELECT perm_type FROM web_kernel.permissions WHERE perm_id=?;",$pi); 
		    my $pname=$pername->fetch();
		    print USERPERM $pname->{perm_type}."\n";
		    $pername->finish();
		}
		close(USERPERM);
	    }
	}
    }
    my $self={};
    return bless($self,$class) ;
        }

sub DESTROY {
            
        }
1;

