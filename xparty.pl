#!/usr/bin/env perl

use strict;
use sigtrap 'handler' => \&inthandler, 'INT';

my $active = 1;

sub inthandler {
    $active = 0;
} 

# read configuration file
my $rc = do 'xparty.cfg'
         or die "could not read config file\n";

my $xvfb;
{
    print "starting Xvfb\n";
    defined ($xvfb = fork) or die $!;
    $xvfb and last;
    my @args = split(/ /, $::CONFIG{'Xvfb'}{'args'});
    unshift @args, $::CONFIG{'Xvfb'}{'display'};
    exec $::CONFIG{'Xvfb'}{'bin'}, @args;
}

print "Xvfb PID: $xvfb\n";

sleep 2; # this should be long enough until Xvfb has started
$ENV{'DISPLAY'} = $::CONFIG{'Xvfb'}{'display'};
system "$::CONFIG{'wm'} &";

while ($active) {
    system "$::CONFIG{'screenshot'}{'prog'} $::CONFIG{'screenshot'}{'args'} 2>/dev/null";
    sleep $::CONFIG{'screenshot'}{'interval'};
}

print "cleanup...\n";
kill 'INT', $xvfb;

