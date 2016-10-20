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

# save all messages (if any $KEYWORD found) to this $LOGFILE
$LOGDIR="$WORKING_DIR/var/log";

@SCAN_DIRS=( 
	'/opt/check_logs01/var/tmp/logs', 
	'/opt/check_logs01/var/tmp/export/logs' ,
	); 
	
@LAST_SCANED_TIME=( 
	"$WORKING_DIR/var/last_scaned_time_dir0.txt",
	"$WORKING_DIR/var/last_scaned_time_dir1.txt",
	); 
	
@CHECK_FILE_MASK=( 
	'(server)_(\d{8}_\d{6})\.log', 
	'(worker)_(\d{8}_\d{6})\.log', 
	'(runner)_(\d{8}_\d{6})\.log', 
	'(slave)_(\d{8}_\d{6})\.log', 
	);

	
$KEYWORD{LOW}=(
	'info',
	'panzer',
	'777',
	);

$KEYWORD{WARNING}=(
	'warning',
	'888',
	'/dev/null',
	'/dev/zero',
	);

$KEYWORD{ALERT}=(
	'alert',
	'error',
	'007',
	'bond',
	);



1;