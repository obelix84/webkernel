#!/usr/bin/perl -w
#модуль отвечает за работу с паролем и логим пользователя
#проаеряет, есть ли такой пользователь в системе
#так же добавляет или удаляеткон кретного пользователя и пароль
package Auth::AuthCreator;
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

sub new{#на вход подается указательна базу  и мигрейшн
    my  ($class,$dbh,$m)=@_;
    my  $self={};
        $self->{'dbh'}=$dbh;
        $self->{'m'}=$m;
        return bless($self,$class);
}

#проверяет, есть ли пользователья таким паролем в базе
sub testUser{#на вход имя пользователя и пароль, на выходе ID пользователя или -1
    my ($self,$user,$pass)=@_;
    warn "-------testUser--${user}---${pass}-----";
    #запрашиваю у бд трэбуемое
    warn Dumper($self->{dbh});
    my  $res=doSql(undef,$self->{dbh},"SELECT u_id,pass FROM web_kernel.users WHERE user=?",$user);
    if (!$res){
        warn "something with DB or user table is empty!";
    }else{
        my $r;
        while($r=$res->fetch){
            my $old_pass=$r->{'pass'};
            if ($old_pass =~ /^(..)(.+)$/){
                my ($salt,$hash) = ($1,$2);
                #еще раз шифруем новый пароль
                my $new_pass=$self->cryptPass($pass,$salt);
                #если хеши совпадают, то выдаем ID пользователя
                if  ($new_pass eq $old_pass){
                    return $r->{'u_id'};
                }
            }
            else{
                warn "Something with salt and hash!";
            }
        }
    }
    return -1;
}

#добавляет пользователя в таблицу
sub addUser{#на вход поступает юзер и пароль
    my  ($self,$user,$pass)=@_;
    #получаем следующее значение вставляемого UID
    my  $crypt_pass=$self->cryptPass($pass);
    my  $u_id=$self->{'m'}->getSeqNextVal($self->{dbh},'web_kernel.seq_u_id');
    #добавляем без всяких проверок
    my $res=doSql(undef,$self->{dbh},"INSERT INTO web_kernel.users (u_id,user,pass) VALUES (?, ?, ?);",$u_id,$user,$crypt_pass);
    return $u_id;
}

#удаляет пользователя из таблицы
sub delUser{#на вход поступает юзер и пароль
    my  ($self,$u_id)=@_;
    #удаляем без всяких проверок
    my $r=doSql(undef,$self->{dbh},"DELETE FROM web_kernel.users WHERE u_id = ? ",$u_id);
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