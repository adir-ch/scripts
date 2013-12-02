#!/usr/bin/perl 


#######################################
#  Password putter
#  By Adir Cohen 
#######################################

sub startProccess { 
	$uExp = Expect->spawn($executable) or die "Cannot fork executable: $!\n";
	$uExp->expect($timeout,
			[ qr/$prompt/i , sub { $spawn_ok = 1; return; } ], 
             		[ '.*password: $', sub { $spawn_ok = 1;
                                                 my $fh = shift;
                                                 print $fh "$password\r";
                                                 exp_continue; } ],
						 
			[ qr/$clientSSHfingerprintPrompt/i, sub { $spawn_ok = 1;
                                                 		 my $fh = shift;
                                                 		 print $fh "yes" . "\r\n";
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

####################### MAIN ###########################

use Expect;
$Expect::Exp_Internal = 0;
$Expect::Log_Stdout   = 1;
$Expect::Log_Debug   = 0;
$Expect::Debug = 0;

$spawn_ok;
$username = "root";
$password = "$ARGV[1]";
$timeout  = 30;  

# Prompts 
$clientLoginPrompt = ".*password:";
$clientSSHfingerprintPrompt=".*yes/no.*?.*";
#$prompt = '\[.*\].*(# )$'; 
$prompt = 'ACC#';

$executable=$ARGV[0];
startProccess();
wait(-1)


