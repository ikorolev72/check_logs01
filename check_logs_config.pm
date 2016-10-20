# Config file for check_logs utilite
#
#

# if $DEBUG=1 then print all messages to stderr.
# if $DEBUG=0 then write messages only to $LOGFILE
$DEBUG=1;

# main working dir
$WORKING_DIR='/opt/check_logs01';

# check new files every $SCAN_INTERVAL ( in seconds )
$SCAN_INTERVAL=60; 

# Dir for 'redirecti scanned error lines'
$LOGDIR="$WORKING_DIR/var/log";

# log file for errors with check_logs script ( eg 'cannot open file', etc)
$LOGFILE="$WORKING_DIR/var/log/check_logs.log";


@SCAN_DIRS=( 
	'/opt/check_logs01/var/tmp/logs', 
	'/opt/check_logs01/var/tmp/export/logs' ,
	); 
	
@LAST_SCANED_TIME_DB=( 
	"$WORKING_DIR/var/last_scaned_time_dir0.txt",
	"$WORKING_DIR/var/last_scaned_time_dir1.txt",
	); 
	
@CHECK_FILE_MASK=(
	'(server)_(\d{8}_\d{6})\.log', 
	'(worker)_(\d{8}_\d{6})\.log', 
	'(runner)_(\d{8}_\d{6})\.log', 
	'(slave)_(\d{8}_\d{6})\.log', 
	);

	
$KEYWORDS{low}=[
	'info',
	'panzer',
	'777',
	];

$KEYWORDS{warning}=[
	'warning',
	'888',
	'/dev/null',
	'/dev/zero',
	];

$KEYWORDS{alert}=[
	'alert',
	'error',
	'007',
	'bond',
	];

# Mail settings

$MAIL{'Smtp'}	="localhost";
$MAIL{'From'}	="osboxes\@localhost.localdomain";
$MAIL{'To'}="osboxes\@localhost.localdomain";
#$MAIL{'To'}="korolev-ia\@yandex.ru";
$MAIL{'Content-Type:'}='text/plain; charset=utf-8';
$MAIL{'Subject'}="Mail for admin. Found error in log file";



1;