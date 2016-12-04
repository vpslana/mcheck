#!/usr/bin/perl
# Author: Iana \\vpslana at gmail
# Created: 
# Updated: Nov, 2016 
##############################
#
###############################
## Declare variables and mods #
###############################
use strict;
use Fcntl qw(:DEFAULT :flock);
use IPC::Open3;
use List::Util qw(max);
use Data::Dumper;
use Term::ANSIColor;
our (@receivers_count,@local_valias_s,@local_valias_r,$top_user_s_i,@local_valias,$top_user_r_i,$top_sender_i,$top_receiver_i,$input,$xdomain,@localdomains,@local_from_user,@local_to_user,$local_from_user,$top_sender_cnt,$top_sender,$top_receiver_cnt,$top_receiver,$top_sender,$receivers,%count_s,%count,$username,$key,$domain,$expcnt,$queue,$line,%receivers,%senders, %queue, %local_from_user, %local_to_user, %local_to, %local_from, @queuen);


print "=============================== Mail queue total ======================\n";

my ($childin, $childout);
my $cmdpid = open3($childin, $childout, $childout, "exim", "-bpc");
  my @output = <$childout>;
      	waitpid ($cmdpid, 0);
              	chomp @output;
                      	unless ($output[0])  {
die "\"exim -bpc\" shows \"0\" mails, nothing to do. \n=============================== Mail queue total ======================\n";
			} # {$output[0] = 0}
                              	print "Mail Queue ($output[0] emails)\n";

#print "=============================== Show the queue ========================\n";

 my $pos = 0;
    	my $id = 0;
    	my $count = 0;
    	my ($childin, $childout);
    	my $cmdpid = open3($childin, $childout, $childout, "exim", "-bpa");
    	foreach my $line (<$childout>) {
            	chomp $line;
            	if ($line eq "") {
                    	$queue{$id}{to} =~ s/,$//;
                    	if ($queue{$id}{to} =~ /\,/) { $expcnt++ }
                    	$queuen[$count] = $id;
                    	$count++;
                    	$pos = 0;
                    	$id = 0;
                    	next;
            	}
            	if ($pos == 0) {
                    	if ($line =~ /^\s*(\w+)\s+(\S*)\s+(\w{6}-\w{6}-\w{2})\s+(<.*?>)/) {
                            	my $time = $1;
                            	my $size = $2;
                            	$id = $3;
                            	my $from = $4;
#                            	print "$time, $size, $from, $id\n";
                         	if ($from eq "<>") {$from = "[bounce]"; $queue{$id}{bounce} = "*"}
                            	$from =~ s/\<|\>//g;
                            	$queue{$id}{from} = $from;
                            	$senders{$id} = $queue{$id}{from};
                            	$queue{$id}{time} = $time;
                            	$queue{$id}{size} = $size;
($local_from_user{$id}{username}, $local_from{$id}{domain}) =  split(/\@/,$from);
push @local_from_user, $local_from_user{$id}{username};
if ($line =~ /\*\*\* frozen \*\*\*$/) {$queue{$id}{frozen} = "*"}
                    	}
            	} else {
                    	$line =~ s/^\s+//;
                    	$queue{$id}{to} = "$line,";
                    	$receivers{$id} = $queue{$id}{to};
                    	$receivers{$id} =~ s/,$//;
                    	my $to = $line;
($local_to_user{$id}{$username}, $local_to{$id}{$domain}) =  split(/\@/,$receivers{$id});    
push @local_to_user, $local_to_user{$id}{$username};    
            	}
            	$pos++;
}
waitpid ($cmdpid, 0);

#print "=============================== Show the queue end =====================\n";
#print "=============================== Localdomains array ===================\n";

open (IN, "<", "/proc/sys/kernel/hostname");
    my $hostname = <IN>;
    chomp $hostname;
    close (IN);


open (IN, "<", "/etc/localdomains");# or die "Unable to open /etc/localdomains for reading: $!";
    flock (IN, LOCK_SH);
    my @ldomains = <IN>;
    close (IN);
    chomp @ldomains;


open (IN, "<", "/etc/secondarymx");
    flock (IN, LOCK_SH);
    my @sdomains = <IN>;
            	close (IN);
            	chomp @sdomains;
            	push @localdomains, @ldomains, @sdomains;
            	my $hit;
            	foreach my $domain (@localdomains) {
                    	if ($domain eq $hostname) {
                           	$hit = 1;
                            	last;
                  	}
           	}
            	unless ($hit) {push @localdomains,$hostname}
            	if (@localdomains == 0) {die "Failed: /etc/localdomains is empty"}

 foreach my $domain (@localdomains) {
            	$domain =~ s/\s//g;
                            	if ($domain =~ /^\#/) {next}
                            	if ($domain =~ /\.zz$/) {next}
                            	if ($domain =~ /^\n/) {next}
                            	if ($domain =~ /^\r/) {next}
                            	if ($input ne "-bw") {
                                    	$xdomain = $domain;
                                    	$xdomain =~ s/\[/\\\[/;
                                    	$xdomain =~ s/\]/\\\]/;
           	 
                                                   	}
}
#print "=============================== Localdomains array end================\n";
print "=============================== Top sender ============================\n";

foreach ( values %senders) {
		$count_s{$_}++;}
        	my  @senders_count = max values %count_s;
        	$top_sender_cnt =  $senders_count[-1];
        	print "Max number of messages per sender in the queue: $top_sender_cnt\n";
			foreach $key (keys  %count_s) {
        			$top_sender = $key  if $count_s{$key} >= $top_sender_cnt;
	}
print "This sender sends the most messages in the queue \n" .  color("green"),"=> ",color ("reset") .  color(""), "$top_sender\n", color ("reset"); 

($top_user_s_i, $top_sender_i) = split(/\@/,$top_sender);
	if ( $top_sender_i =~ /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/ ) {
		if ( grep /$top_sender_i/, @localdomains ) { print color("green"),"==> ",color ("reset") . "$top_sender_i  present in /etc/localdomains\n";
			if ( -s "/etc/valiases/$top_sender_i") {
				open (IN, "<", "/etc/valiases/$top_sender_i");
    				my @local_valias_s = <IN>;
    				chomp @local_valias_s;
    				close (IN);
					if ( grep /$top_user_s_i/, @local_valias_s ){
print color("green"),"===> ",color ("reset") . "# grep $top_user_s_i /etc/valiases/$top_sender_i \n\t\t\t @local_valias_s[$top_user_s_i] \n";
					}
else { print color("green"),"No record for $top_user_s_i in /etc/valiases/$top_sender_i found\n",color ("reset") }; 
			} 
else { print color("green"),"No /etc/valiases/$top_sender_i found\n",color ("reset") };
		}
else { print color ("red")," Top sender $top_sender is NOT in /etc/localdomains \n",color ("reset") ; }
	}
else { print color ("red"),"Sender domain is not a valid domain\n",color ("reset");
}
#print "=============================== Top sender end=========================\n";

print "=============================== Top receiver ==========================\n";

foreach ( values %receivers) {
        $count{$_}++;
	}
	my  @receivers_count =  max values %count;
             $top_receiver_cnt =  $receivers_count[-1];
             print "Max number of messages per receiver in the queue: $top_receiver_cnt \n";
             foreach $key (keys  %count) {
             $top_receiver = $key  if $count{$key} >= $top_receiver_cnt;
	}
	print "This receiver gets the most messages in the queue\n" .  color("green"),"=> ",color ("reset") . "$top_receiver \n";

($top_user_r_i, $top_receiver_i) = split(/\@/,$top_receiver);
	if ( $top_receiver_i =~ /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/ ) {
		if ( grep /$top_receiver_i/, @localdomains ) {
			print  color("green"),"==> ",color ("reset") . "Top receiver $top_receiver is found in /etc/localdomains\n";
				if ( -s "/etc/valiases/$top_receiver_i") {
					print "$top_user_r_i\n";
					open (IN, "<", "/etc/valiases/$top_receiver_i");
    					my @local_valias_r = <IN>;
    					chomp @local_valias_r;
    					close (IN);
						if ( grep /$top_user_r_i/, @local_valias_r ) { 
print color("green"),"===> ",color ("reset") . "# grep $top_user_r_i  /etc/valiases/$top_receiver_i\n\t\t\t@local_valias_r[$top_user_r_i] \n ";} else {print color("green"),"No record for $top_user_r_i in /etc/valiases/$top_receiver_i found\n",color ("reset") };
						} 
				else { print color("green"),"No /etc/valiases/$top_receiver_i found\n",color ("reset") };
				}
			else { print color ("red"),"Top receiver $top_receiver is NOT found in /etc/localdomains \n",color ("reset") };
			}
	else { print  color ("red"),"Receiving domain is not a valid domain\n",color ("reset") }

#print "=============================== Top receiver end=======================\n";
#
#
#
#
#
# For more options to clear mail queue see: ephur -> on github -> exim_despam/exim_queue.pl
# :wq
