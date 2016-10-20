#!/usr/bin/perl
# korolev-ia [at] yandex.ru
# version 1.0 2016.10.20
##############################

use Data::Dumper;
use Getopt::Long;
use Mail::Sendmail;

use check_logs_config;

GetOptions (
        'daemon|d' => \$daemon,
        "help|h|?"  => \$help ) or show_help();

show_help() if($help);

if( $daemon ) {
	$DEBUG=0;
	while( 1 ) {
		foreach $i ( 0..$#SCAN_DIRS ) {
			scan_dir( $SCAN_DIRS[$i], $LAST_SCANED_TIME_DB[$i] );
		}	
		sleep( $SCAN_INTERVAL );
	}
} else {
		foreach $i ( 0..$#SCAN_DIRS ) {
			scan_dir( $SCAN_DIRS[$i], $LAST_SCANED_TIME_DB[$i] );
		}	
}




exit(0);


sub scan_dir {
	my $dir=shift; # scan this dir 
	my $lastchecked_file=shift; # read last checked time and save here the current time
	
	my $lastchecked_tmp=ReadFile( $lastchecked_file );
	my $lastchecked_db;
	if( $lastchecked_tmp ) {		
		eval "$lastchecked_tmp";
		if( $@ ){
			w2log( "Error: $@" );
		} else {
			$lastchecked_db=$VAR1;
		}
	}
	
	
	#my $time_now=get_date( time(), "%s%.2i%.2i_%.2i%.2i%.2i" );
	# we will save the current time and will check in future only new files

	unless( opendir(DIR, $dir) ) {
		w2log( "can't opendir $dir: $!" );	
		return 0;
	} 
	while( readdir(DIR) ) {
		my $filename=$_;
		foreach $filemask ( @CHECK_FILE_MASK  ) {			
			if( $filename=~/^$filemask$/ && -f "$dir/$filename" ) {
				my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat( "$dir/$filename" );
				#print "$filename $filemask \n";
				my $lines=0;
				
				if( $lastchecked_db->{$filename}->{mtime} ) {
					# if we check this file but it modified
					if( $mtime <= $lastchecked_db->{$filename}->{mtime} ) {
						next;
					}
				} 
				$lines=scan_file( "$dir/$filename" , $lastchecked_db->{$filename}->{lines} );
				$lastchecked_db->{$filename}->{mtime}=$mtime;
				$lastchecked_db->{$filename}->{lines}=$lines;				
			}
			else {
				next;
			}
		}
	}
	closedir DIR;
	
	# save the db into file
	# this file can be very big and we will save it to tmp file and then remove
	if( WriteFile( "$lastchecked_file.tmp", Dumper( $lastchecked_db )  ) ) {
		return 1 if( rename( "$lastchecked_file.tmp", $lastchecked_file ) );
	}
	w2log( "Cannot save the db file $lastchecked_file: $!" );
	return 0;
}


sub scan_file {
	my $filename=shift;
	my $skip_lines=shift;
	unless( open (IN,"$filename") ) {		
		w2log("Can't open file $filename") ;
		return 0;
	}
	$count_lines=0;
	while (<IN>) { 
		$count_lines++;
		if( $skip_lines > $count_lines ) {
			next;
		}
		
		my $str=$_;
		foreach $error_level ( keys %KEYWORDS ) {
			foreach $keyword ( @{ $KEYWORDS{$error_level} } ) {
				if( $str=~/$keyword/i  ) {
					$filename=~/(\w+_\d{8}_\d{6})\.log$/;
					my $error_file="$LOGDIR/$1.$error_level";
					AppendFile( $error_file, $str );
					#w2log( "Found error keyword level $error_level in the file: $filename on the string number: $count_lines");
					#w2log( "Error keyword found in the string: $str");
					if( $error_level=~/ALERT/i ){
						my $mail_body="Found error keyword level $error_level in the file: $filename on the string number: $count_lines\n";
						$mail_body.="Error keyword found in the string: $str\n";
						send_mail( $mail_body );
					}
				}
			}
			
		}
	}
	close (IN);	
	return $count_lines;
}

sub send_mail {
	$MAIL{'Message'}=shift;
	unless ( sendmail(%MAIL) )  {
		w2log( "Cannot send email from $MAIL{'From'} to $MAIL{'To'}. Smtp server $MAIL{'Smtp'}. Sendmail::error " );
	}

}

sub get_date {
	my $time=shift() || time();
	my $format=shift || "%s-%.2i-%.2i %.2i:%.2i:%.2i";
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($time);
	$year+=1900;$mon++;
    return sprintf( $format,$year,$mon,$mday,$hour,$min,$sec);
}	


sub w2log {
	my $msg=shift;
	# daily log file
	my $log=shift;
	unless( $log ) {
		$log=$LOGFILE; 
	}
	open (LOG,">>$log") || print STDERR ("Can't open file $log. $msg") ;
	print LOG get_date()."\t$msg\n";
	print STDERR "$msg\n" if( $DEBUG );
	close (LOG);
}


sub ReadFile {
	my $filename=shift;
	my $ret="";
	open (IN,"$filename") || w2log("Can't open file $filename") ;
		while (<IN>) { $ret.=$_; }
	close (IN);
	return $ret;
}	
					
sub WriteFile {
	my $filename=shift;
	my $body=shift;
	unless( open (OUT,">$filename")) { w2log("Can't open file $filename for write" ) ;return 0; }
	print OUT $body;
	close (OUT);
	return 1;
}	

sub AppendFile {
	my $filename=shift;
	my $body=shift;
	unless( open (OUT,">>$filename")) { w2log("Can't open file $filename for append" ) ;return 0; }
	print OUT $body;
	close (OUT);
	return 1;
}
					
					
sub show_help {
print STDERR "
Check dirs, search keywords in logfiles and send mail if alert
Usage: $0  [ --daemon ]  [--help]
where:
Sample:
$0 --daemon
";
	exit (1);
}					