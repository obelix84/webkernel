#!/usr/bin/perl -w

package image;
use strict;
use warnings; 
       {
        my $imname;  #��� ��������
        my $thumb;  # ������ ��������
        my $comment;  #����������
        
       
        sub new {
            my $class= shift;
            my $self={};
            print "Let's Getta Started!";
            return bless($self,$class) ;
        }
        
        sub print_fig{
                my $c;
                foreach $c (@_){
                    print "${c}\n";
                }
        }
                
        sub DESTROY {
            print "\nKill Bill!!!\n";
        }
    }

1;