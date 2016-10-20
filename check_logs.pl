#!/usr/bin/perl
# korolev-ia [at] yandex.ru
# version 1.0 2016.10.20
##############################

use Data::Dumper;
use Getopt::Long;
use check_logs_config;

GetOptions (
        'daemon|d' => \$daemon,
        "help|h|?"  => \$help ) or show_help();

show_help() if($help);

if( $daemon ) {
	$DEBUG=0;
	while( 1 ) {
		foreach $i ( 0..$#SCAN_DIRS ) {
			scan_dir( @SCAN_DIRS[$i], @LAST_SCANED_TIME[$i] );
		}	
		sleep( $SCAN_INTERVAL );
	}
} else {
		foreach $i ( 0..$#SCAN_DIRS ) {
			scan_dir( @SCAN_DIRS[$i], @LAST_SCANED_TIME[$i] );
		}	
}




exit(0);


sub scan_dir {
	my $dir=shift; # scan this dir 
	my $lastchecked_file=shift; # read last checked time and save here the current time
	
	my $lastchecked=ReadFile( $lastchecked_file );
	my $time_now=get_date( time(), "%s%.2i%.2i_%.2i%.2i%.2i" );
	unless( $lastchecked ) {
		$lastchecked=$time_now;
	}
	# we will save the current time and will check in future only new files
	WriteFile( $lastchecked_file, $time_now  ) ;

	opendir(DIR, $dir) || w2log( "can't opendir $dir: $!" );
	while( readdir(DIR) ) {
		my $filename=$_;
		foreach $filemask ( @CHECK_FILE_MASK  ) {			
			if( $filename=~/^$filemask$/ && -f "$dir/$filename" ) {
				print "$filename $filemask \n";
				if( $1 > $lastchecked ) {	
					scan_file( "$dir/$filename" );
				}
				else {
					next;
				}
			}
		}
	}
	closedir DIR;
}


sub scan_file {
	my $filename=shift;
	unless( open (IN,"$filename") ) {		
		w2log("Can't open file $filename") ;
		return 0;
	}
	$count_str=0;
	while (<IN>) { 
		$count_str++;
		my $str=$_;
		foreach $error_level ( keys %$KEYWORD ) {
			if( grep{ $str=~/$_/ }@{ $KEYWORD{$error_level} } ) {
				$filename=~/(\w+_\d{8}_\d{6})\.log$/;
				my $error_file="$LOGDIR/$1.$error_level";
				AppendFile( $error_file, $str );
				w2log( "Found error keyword level $error_level in the file: $filename on the string number: $count_str");
				w2log( "Error keyword found in the string: $str");
				if( $error_level=~/ALERT/ ){
					my $mail_body="Found error keyword level $error_level in the file: $filename on the string number: $count_str\n";
					$mail_body.="Error keyword found in the string: $str\n";
					send_mail( $mail_body );
				}
			}
			
		}
	}
	close (IN);	
	return 1;
}

sub send_mail {
	$msg=shift;
	print $msg;
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
	# dayly log file
	my $log="$LOGDIR/".get_date( time(),"%s-%.2i-%.2i" ).".log"; 
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