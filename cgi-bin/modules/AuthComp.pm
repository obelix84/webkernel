#!/usr/bin/perl -w
package AuthComp;
use strict;
use utf8;
use warnings;
use diagnostics;
use locale;
use MConnect;
use POSIX qw(locale_h);
my $locale = 'ru_RU.UTF-8';
my $new_locale = setlocale(LC_ALL, $locale);
die "MTemplate: no locale $locale" if ($new_locale ne $locale);
binmode STDOUT, ":utf8";
use encoding "utf8";
use Data::Dumper;
use MTemplate;
use CookieCreator;
use SessionCreator;
use Auth::AuthCreator;

#компонента генерирующая авторизацию, создается при загрузке страницы
#какие нужны параметры?

sub new{
    my $class= shift;
    my $params= shift;
    my $self={};
	$self->{'dbh'}=$params->{'dbh'};
	$self->{'m'}=$params->{'MMigration'};
    $self->{'template'}=MTemplate->new('cgi-bin/modules/AuthComp.pm')->getTemplate('main');
    #при построении колмпоненты, надо учитывать следующее
    #сначала проверяется если ли SID в куки
    my  $cook=CookieCreator->new($params->{'Apache'});
    my	$ses=SessionCreator->new($self->{'dbh'},$self->{'m'});
    my  $s_id=$cook->getCookie("session");
    #убиваем неактивные сесиии
    $ses->clearExpiredSessions();
    #если в куки ничего похожего нет, значит у нас никто не авторизировался
    #и значит надо проверить не логинится ли кто, если логинится то принять как следует
    #если не логинится, значит надо выдать шаблон для логина
    if(! $s_id){
	my  $login=$params->{'MMigration'}->param('login');
        my  $pass=$params->{'MMigration'}->param('pass');
        #это для случая, если ничего нет
        if  ($login && $pass){
            #если параметры есть, значит пользователь авторезируется..
	    #обслуживаем по полной
	    #для начала проверим, есть ли вообще такой пользователь!!
	    my	$ac=Auth::AuthCreator->new($self->{'dbh'},$self->{'m'});
	    my	$u_id=$ac->testUser($login,$pass);
	    if ($u_id==-1){
		#если такого нет, то надо регится..говорим, что-то аля извините авторизация неудачна тра-ля-ля
            $self->{'template'}->add('default_auth');
            warn "user $login not found in auth table (!)";
	    }else{
		#Здравствуйте Вася! Мы так рады вас видеть:)
		# но сколько теперь с вами гемороя однако...
		#такой пользователь есть, теперь надо сессию сделать, куку запихнуть ему :)
	       $ses->testUser($u_id,$pass);#и нам все равно, что вернет функция..
		my $s_id=$ses->addUserSession($u_id,$pass,180);
	        #куку-ре-ку...
		    $cook->setCookie("session",$s_id);
		    $cook->sendCookie();
		    #Поздравляем вас с авторизацией!
		    #формируем выводимую часть для сайта
		    #////пока остается это потом поравить
		    $self->{'template'}->add('default_name')->add('name',$login);
	    }
        }else{
            #если ничего нет вывести авторизацию;    
            $self->{'template'}->add('default_auth');
        }
    }else{
        #если ид есть
        #проверяем сессии, а активна ли она
	# а не нажал ли пользователь кнопочку выход? ась?
	my  $name=$params->{'MMigration'}->param('exbut');
	if (! $name){ #значит не нажал
	    #проверяем сесиию
	    if($ses->updateSessionTime($s_id,180)){
		#время еще есть
		if($ses->testSessionIP($s_id)){
		    #Ип совпадает
		    #выводим шаблон с именем
		    my $n=$ses->getUser($s_id);
		    $self->{'template'}->add('default_name')->add('name',$n)
		}else{
		    #ип не совпадает
		    #убиваем куки и выводим шаблон с авторизацией
		    $cook->deleteCookie('session');
		    $self->{'template'}->add('default_auth');
		}
	    }
	    else
	    {
		#если время истекло, убиваем куки
		$cook->deleteCookie('session');
		#выводим шаблон с авторизацией
		$self->{'template'}->add('default_auth');
	    }	
	}
	else{
	    #раз нажал так нажал
	    $cook->deleteCookie('session');#смерть куки!
	    $ses->deleteSession($s_id);#смерть сесии!
	    #выводим шаблон с авторизацией
	    $self->{'template'}->add('default_auth');
	}
    }
    return bless($self,$class);
}

#выводит строку с шаблоном
sub output{
    my $self = shift;
    return $self->{'template'}->output();
}

sub DESTROY{
}

1;

=fornobodies

for_alien_pattern
<!--place/-->

main
<!--default_auth-->
<table width="148" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="144">авторизация</td>
        </tr>
        <tr>
          <td>
          <form name="auth" method="post" action="">
              <label>
              логин:
	     <input type="text" name="login">
              </label>
	     <label>
              пароль:
              <input type="text" name="pass">
	     </label>
	     <input name="sbut" type="submit">
			  
          </form>
          </td>
        </tr>
</table><!--/default_auth--><!--default_name--><table width="148" border="0" cellspacing="0" cellpadding="0" class="table_auth">
        <tr>
          <td width="144">авторизация</td>
        </tr>
        <tr>
          <td><form name="form1" method="post" action="">
              <label>Здравствуйте <!--name/-->!</label><BR>
              <label>Выйти:</label>
	      <input name="exbut" type="submit">
	      </form></td>
        </tr>
</table><!--/default_name-->

end

=cut
