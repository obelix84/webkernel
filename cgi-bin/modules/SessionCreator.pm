#!/usr/bin/perl -w
package SessionCreator;
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
use Apache::Session::Generate::MD5;


#модуль для работы с таблицей сессий, в БД называется session
#заносит нового авторезированного пользователя в таблицу,а
#так же удаляет всех пользователей у которых срок действия сессии истек 

sub new{#на вход поступает указатель на базу данных и мигрейшн
    my  ($class,$dbh,$m)=@_;
    my  $self={};
        $self->{'dbh'}=$dbh;
        $self->{'m'}=$m;
        return bless($self,$class);
}

#добавляет нового пользователя в сессионную таблицу, выдает на выходе его SID
sub addUserSession{ # на вход идет ID пользователя,пароль и время сессии
    my ($self,$u_id,$pass,$stime)=@_;
    my $crypt_pass=$self->cryptPass($pass);
    #генерируем ключ сессионный
    my  $s_id = Apache::Session::Generate::MD5::generate();      
    while ($self->isSetSID($s_id))
    {
        $s_id = Apache::Session::Generate::MD5::generate();
    }
    #вставляем в таблицу
    my $curtime=$self->{'m'}->getTimeNow();
    my $res=doSql(undef,$self->{dbh},"INSERT INTO web_kernel.session (s_id,ip,u_id,pass,entry,expiration) VALUES (?, ?, ?, ?, ?, ?);",$s_id,$ENV{REMOTE_ADDR},$u_id,$crypt_pass,$curtime,$curtime+$stime);
    return $s_id;
}

#проверяет, есть ли такой пользователь в таблице сесиии и именно с таким паролем и именно с таким ИП
#если есть такой, то удаляем, а потом заново будет сессия
sub testUser{#пользователь, пароль
    my ($self, $u_id, $pass)=@_;
    my  $empty=0;
    #извлекаем из базы данные, если таковые есть     
    my $res=doSql(undef,$self->{dbh},"SELECT pass, ip FROM web_kernel.session WHERE u_id=?;",$u_id);
    if (!$res){
        warn "Something wrong with DB or session table is empty!";
    }else{
        my  $row;
        while($row=$res->fetch){
            #если в базе, что-то есть, то теперь проверим, так ли это
            my $old_pass=$row->{'pass'};
            if ($old_pass =~ /^(..)(.+)$/){
                my ($salt,$hash) = ($1,$2);
                #еще раз шифруем новый пароль
                my $new_pass=$self->cryptPass($pass,$salt);
                #если хеши совпадают, то удаляем пользователя и выдаем тру
                if  ($new_pass eq $old_pass){
                    #проверяем такой ли IP(а надо ли?)
                    if($ENV{REMOTE_ADDR} eq $row->{ip}){
                        $empty=1;
                        #и удаляем
                        warn "testUser delete   ";
                        my $r=doSql(undef,$self->{dbh},"DELETE FROM web_kernel.session WHERE pass = ? ",$old_pass);
                    }
                }
            }
            else{
                warn "Something with salt and hash!";
                $empty=0;
            }
        }
    }
    return $empty;
}

#а нет ли пользователя с таким же ID  сесии?
sub isSetSID{
    my  ($self,$s_id)=@_;
    my  $res=doSql(undef,$self->{dbh},"SELECT s_id FROM web_kernel.session WHERE s_id = ? ",$s_id);
    if(!$res)
    {
        warn "Something with DB!";
    }
    else
    {
        my  $r=$res->fetch;
        return $r->{'s_id'};
    }
}

#проверяет активна ли сесиия, и продлевает ее время, если она активна
#а если не активна то удаляет
sub updateSessionTime{# на вход ID сессии, время продления  
    my ($self, $s_id, $stime)=@_;
    #извлекаем из базы данные о сессии
    my $res=doSql(undef,$self->{'dbh'},"SELECT expiration FROM web_kernel.session WHERE s_id=?",$s_id);
    if(!$res){
        warn "Something wrong with DB!"
    }else{
        my $cur_time=$self->{'m'}->getTimeNow();
        my  $r=$res->fetch;
        if (!$r){
            return 0;
        }else{
            my  $time = ($r->{'expiration'}) - $cur_time;
            #эх время время времечко, жизнь...
            if($time>=0){
                #не пролетела зря(продлеваем..)
                $res=doSql(undef,$self->{'dbh'},"UPDATE web_kernel.session SET expiration = ? WHERE s_id = ?",($cur_time+$time),$s_id);   
                if(!$res){
                    warn "Something with DB in update session creator!";
                }
                return 1;
            }else{
                #пролетела зря(удаляем)
                warn "Update session time delete  ";
                $self->deleteSession($s_id);
                return 0;
            }
        }
    }
    $res->finish;
    return 0;
}

#проверяет IP для сессии, если совпадает, то все чики-пики, если нет, то на выходе нет
sub testSessionIP{#на вход id сесии
    my  $self=shift;
    my  $s_id=shift;
    my $res=doSql(undef,$self->{dbh},"SELECT ip FROM web_kernel.session WHERE s_id=?",$s_id);
    my  $r=$res->fetch;
    if (!$r){
            return 0;
        }else{
            if($r->{'ip'} ne $ENV{REMOTE_ADDR}){
                #если не совпадают выдаем false 
                $res->finish;
                return 0;
            }else{
                $res->finish;
                return 1;
            }
        }
}




#удаляет пользователя из таблицы сессии по ID сесии
sub deleteSession{
    warn "DeleteUser  ";
    my ($self, $s_id)=@_;
    my $r=doSql(undef,$self->{dbh},"DELETE FROM web_kernel.session WHERE s_id = ? ",$s_id);
}

#удаляет все истекшие сессии
sub clearExpiredSessions{
   my $self= shift;
   my $res=doSql(undef,$self->{dbh},"delete FROM web_kernel.session WHERE expiration<=?",$self->{'m'}->getTimeNow());
=for nobody
   #расчесываем полученный результат
   my $row;
   while($row=$res->fetch){
        $self->deleteUser($row->{'s_id'});
   }
=cut
}

#достает оттуда имя пользователя по id
sub getUser{
    my ($self,$s_id)=@_;
    my $res=doSql(undef,$self->{dbh},"SELECT user FROM web_kernel.users WHERE u_id=(SELECT u_id FROM web_kernel.session WHERE s_id=? )",$s_id);
    my  $r=$res->fetch;
    return $r->{'user'};
}


sub cryptPass{#на вход поступает строка с паролем и salt, если надо, если солта нет,значит рандом берем
    my ($self,$pass,$salt)=@_;
    #алфавит для солта
    my @alf = split(//,"qazxswedcvfrtgbnhyujmkiolpZAQWSXCDERFVBGTYHNMJUIKLOP1234567890");
    my $crypt_pass;
    if(! $salt){
        my $a1=rand(scalar(@alf));
        my $a2=rand(scalar(@alf));
        my $random_salt=$alf[$a1].$alf[$a2];
        #warn "pass = ${pass} ------- random_salt = ${random_salt}";
        $crypt_pass=crypt($pass,$random_salt);
        return $crypt_pass;  
    }else{
       $crypt_pass=crypt($pass,$salt);
       return $crypt_pass; 
    }
}

sub DESTROY{
    
}

1;

=fornobodies
   INSERT INTO `session` ( `s_id` , `u_id` , `pass` , `entry` , `expiration` ) 
VALUES (
'dfjsdfjsdhfjksdhfsdkfhsdffsfs0df0sd', '1', 'sadasdasdads', '000', '100'
); 


DELETE FROM `session` WHERE CONVERT(`s_id` USING utf8) = 'dfjsdfjsdhfjksdhfsdkfhsdffsfs0df0sd' LIMIT 1

=end
