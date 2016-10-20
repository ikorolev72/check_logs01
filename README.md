#						log parser 01


##  What is it?
##  -----------
A "watchdog" script running in backgroud on linux servers and 
scanning log files in two differents folders.

### How to install
Extract archive with ```tar -x -C /opt -f check_logs01.tgz``` to folder /opt ( you can use any folder, 
but change $WORKING_DIR in check_logs_config.pm  ) . Your working dir now: /opt/check_logs01


Edit the _check_logs_config.pm_ with your prefferences:
   +  @SCAN_DIRS - dirs you plane to scan
   +  @LAST_SCANED_TIME_DB - database files, where will be saved data: filename, modification time, line count
   +  @CHECK_FILE_MASK - filemask for your logs
   +  $KEYWORDS{...} - keywords for low, warning and alert level
   +  $MAIL{...} - settings for your mailserver


### How to run
There three ways to run:
   1. From command line. Usualy for testing resone. Simple run ```/opt/check_logs01/check_logs.pl```
   2. From crontab. Add next line to your crontab with ```crontab -e``` command:
   ```
*	*	*	*	*	/opt/check_logs01/check_logs.pl >/dev/null 2>&1
   ```
   3. From command line as daemon. Run ```/opt/check_logs01/check_logs.pl --daemon &```
   
   
  Licensing
  ---------
	GNU

  Contacts
  --------

     o korolev-ia [at] yandex.ru
     o http://www.unixpin.com

