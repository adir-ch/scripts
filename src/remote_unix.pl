#!/usr/bin/perl 


#######################################
#  Remote unix 
#  By Adir Cohen 
#######################################


sub sendCommand {
	
	$command = shift;
	$exp->send("$command\r");  
	$exp->expect($timeout, "$command\r\n");
	$exp->expect($timeout, -re, $prompt);
	return $exp->exp_before();
}

use Expect;
$Expect::Exp_Internal = 0;
$Expect::Log_Stdout   = 0;
my $spawn_ok;
my $username = "root";
my $password = "Expand";
my $clientSSHfingerprintPrompt=".*yes/no.*?.*";
$timeout  = 20;
$prompt = '\[.*\].*(# )$'; 
$exp = Expect->spawn("ssh $ARGV[0]") or die "Cannot fork telnet: $!\n";
$exp->expect($timeout,
             [ '.*password: $', sub { $spawn_ok = 1;
				      my $fh = shift;
                                      print $fh "$password\n";
                                      exp_continue; } ],
	     [ qr/$clientSSHfingerprintPrompt/i,  sub {
                                                         print("found ssh fingerprint - approving and adding ssh key\n");
                                                         $fork_ok = 1;
                                                         my $fh = shift;
                                                         print $fh "yes" . "\r\n";
                                                         exp_continue;
                                                    }],
             [ eof => sub {
                      		if ($spawn_ok) {
                        		die "ERROR: premature EOF in login.\n";
                      		} else {
                        		die "ERROR: could not fork telnet.\n";
                      		}
                    	  } ],
             [ timeout => sub { die "Unable to login.\n"; } ],
             '-re' , $prompt
);

@result = sendCommand ($ARGV[1]);
print ("@result\n");
$exp->send("exit\r");
exit 0;
