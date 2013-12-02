#!/usr/bin/perl 


#######################################
#  Setup updator    
#  By Adir Cohen 
#######################################

sub getBashVar {
   my $varName = $_[0];
   return `source ${BASH_SRC}; echo -n \${$varName}`;
}

sub startProccess { 
	#print("starting proccess...\n");
	$uExp = Expect->spawn($executable) or die "Cannot fork executable: $!\n";
	$uExp->expect($timeout,
             		[ '.*[Pp]assword: $', sub { $spawn_ok = 1;
                                                 my $fh = shift;
                                                 print $fh "Expand\r";
                                                 exp_continue; } ],
             		[ eof => sub {
                                        if ($spawn_ok) {
                                            return;
                                        } else {
                                            die "ERROR: could not fork updator.\n";
                                        }
                                     } ],
             		[ timeout => sub { die "Unable to start update.\n"; } ],
             		'-re' , $prompt);

}

sub countSetups {
	# work around - reading bash predefined variables in perl
	# local $CONF_FILE = getBashVar(SETUPS_LIST_SRC);
	#local $CONF_FILE = "/local/scripts/update_agent/update_list.conf"
        
        # getting setups (takes non empty lines that dont start with  #)
	#local $setupCount=`cat $CONF_FILE | egrep -v "[!(^#)]" | grep -v "^\$" | egrep "^[0-9].*" | tr -s "\n" " " | wc -w | awk '{print \$1}'`;
	
	local $setupCount=`cat /local/scripts/update_agent/setups.conf | egrep -v "[!(^#)]" | grep -v "^\$" | egrep "^[0-9].*" | tr -s "\n" " " | wc -w | awk '{print \$1}'`;
	return $setupCount
}

####################### MAIN ###########################

use Expect;
$Expect::Exp_Internal = 0;
$Expect::Log_Stdout   = 1;

my $spawn_ok;
my $username = "root";
my $password = "Expand";
my $clientSSHfingerprintPrompt=".*yes/no.*?.*";
$BASH_SRC="agent.conf"; 

$timeout  = (countSetups() * 30);  # 30 sec per setup 
$prompt = '\[.*\].*(# )$'; 
$executable=$ARGV[0];
startProccess();
#print("Proccess done !!!\n");
exit 0;


