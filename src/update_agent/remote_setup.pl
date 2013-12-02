#!/usr/bin/perl 

#######################################
#  Remote Cisco Router
#  By Adir Cohen 
#######################################



sub sendCommand {
	my $command = shift;
        my $prompt = shift;
        $exp->send($command . "\r\n"); 
	$exp->expect($timeout, "$command\r\n");
	$exp->expect($timeout, -re, qr/$prompt/i);
	return $exp->exp_before();
}

sub clientLogin {
   my $password = shift;
   $exp = Expect->spawn("$client root\@$host") or die "Cannot fork $client: $!\n";

   $exp->expect($timeout,  	[ qr/$clientLoginPrompt/i,  sub {
                                                         
							 							 $fork_ok = 1; 
                                                         my $fh = shift;
                                                         print $fh $password . "\n";
                                                         exp_continue; 
                                                    }],

	                   		[ qr/$clientSSHfingerprintPrompt/i,  sub {
                                                         print("found ssh fingerprint - approving and adding ssh key\n");
                                                         $fork_ok = 1;
                                                         my $fh = shift;
                                                         print $fh "yes" . "\r\n";
                                                         exp_continue;
                                                    }],

   			   		 		[ eof => sub { 
                                          	if ($fork_ok) {
                           		        		die "ERROR: premature EOF in login.\n";
                         		  			} else {
                                                die "ERROR: could not fork $client $host.\n"; 
                         		  			}   
                                    	 			}],

                           [ timeout => sub { die "Cannot login to: $host.\n"; }],
                
                           '-re', qr/$linuxPrompt/i); 	
} # sshLogin

sub setupLogin {
   sendCommand("expsh", $expshPrompt);
   sendCommand("en", $expshEnPrompt);
} # setupLogin

sub sendExpandShellCmd {
   my $currentCommand = shift;
   my $currentPrompt = shift;

   # session login
   clientLogin("Expand");
   setupLogin;
   if ($output eq "output") {
        print (sendCommand($currentCommand, $currentPrompt) . "\n");
   } elsif ($output eq "no_output") {
        sendCommand($currentCommand, $currentPrompt);
   } else {
	printUsage();
	exit(1);
   }
   sendCommand("exit", $linuxPrompt);
   sendCommand("exit", "");
}

sub sendLinuxCmd {
   my $currentCommand = shift;
   my $currentPrompt = shift;
   clientLogin("Expand");
   if ($output eq "output") {
     print (sendCommand($currentCommand, $currentPrompt) . "\n");
   } elsif ($output eq "no_output") {
	sendCommand($currentCommand, $currentPrompt);
   } else {
	printUsage();
	exit(1);
   }
   sendCommand("exit", "");
   
}

sub printUsage {
   print("Usage: remote_setup.pl [-q : quite mode] <expsh | linux> <host> <output | no_output> <command>\n");
}

######## MAIN #########

use Expect;
$Expect::Exp_Internal = 0;
$Expect::Log_Stdout   = 0;
$Expect::Debug = 0;

# common vars
$fork_ok;
$timeout  = 20;
$client = "/usr/bin/ssh";
$print_cmd = 1; 


if (@ARGV < 4) {
   printUsage();
   exit 1;
}

if ($ARGV[0] eq "-q") {
	$print_cmd = 0;
	$sys  = $ARGV[1];
	$host = $ARGV[2];
	$output = $ARGV[3];
	$cmd  = $ARGV[4];
} 
else {
	$sys  = $ARGV[0];
	$host = $ARGV[1];
	$output = $ARGV[2];
	$cmd  = $ARGV[3];
}


# Prompts 
$clientLoginPrompt = ".*Password:";
$clientSSHfingerprintPrompt=".*yes/no.*?.*";
$linuxPrompt = "ACC#";
$expshPrompt = "expand>";
$expshEnPrompt = "expand#";

# remoting setup
if ($sys eq "linux") {
   if ($print_cmd == 1) {
	print("Executing remote linux cmd [$host]: $cmd\n");
   }
   sendLinuxCmd($cmd, $linuxPrompt);
} elsif ($sys == "expsh") {
   if ($print_cmd == 1) {
	print("Executing remote expsh cmd [$host]: $cmd\n");
   }
   sendExpandShellCmd($cmd, $expshEnPrompt); 
} else {
   printUsage();
   exit 1;
}


exit 0;
