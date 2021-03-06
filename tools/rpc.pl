#!/usr/bin/perl -w
# Copyright (c) 2013 SUSE Linux Products GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

=head1 boilerplate

rpc.pl - test rpc to openqa dispatcher

=head1 SYNOPSIS

rpc.pl [OPTIONS] COMMANDS...

=head1 OPTIONS

=over 4

=item B<--host> HOST

connect to specified host

=item B<--commands>

show available commands

=item B<--help, -h>

print help

=back

=head1 DESCRIPTION

lorem ipsum ...

=cut

use strict;
use Data::Dump;
use Getopt::Long;
Getopt::Long::Configure("no_ignore_case");

my $clientclass;
for my $i (qw/JSON::RPC::Legacy::Client JSON::RPC::Client/) {
	eval "use $i;";
	$clientclass = $i unless $@;
}
die $@ unless $clientclass;

my %cmds = map { $_ => 0 } (qw/
	list_workers
	list_commands
	/);
for (qw/
	echo
	job_get
	job_delete
	job_set_scheduled
	job_set_stop
	job_set_waiting
	job_set_running
	job_find_by_name
	job_restart
	job_stop
        iso_delete
        iso_stop
	command_get
	worker_get
	/) {
	$cmds{$_} = 1;
}
for (qw/
	job_set_prio
	job_grab
	job_set_done
	job_update_result
	command_enqueue
	command_dequeue
	/) {
	$cmds{$_} = 2;
}
$cmds{worker_register} = 3;
$cmds{job_create} = 99;
$cmds{list_jobs} = 99;
$cmds{iso_new} = 99;

sub showcommands
{
	print "Available Commands:\n";
	print join("\n", sort keys %cmds);
	exit(0);
}

my %options;

sub usage($) {
	my $r = shift;
	eval "use Pod::Usage; pod2usage($r);";
	if ($@) {
		die "cannot display help, install perl(Pod::Usage)\n";
	}
}

GetOptions(
	\%options,
	"commands",
	"host=s",
	"verbose|v",
	"help|h",
) or usage(1);

showcommands if exists $options{'commands'};

usage(1) unless @ARGV;
usage(1) unless exists $options{'host'};

$options{'host'} .= '/jsonrpc' unless $options{'host'} =~ '/';
$options{'host'} = 'http://'.$options{'host'} unless $options{'host'} =~ '://';

my $client = new $clientclass;
my $port = 80;


$client->prepare($options{'host'}, [keys %cmds]) or die "$!\n";
while (my $cmd = shift @ARGV) {
	unless (exists $cmds{$cmd}) {
		warn "invalid command $cmd";
		next;
	}
	my @args;
	@args = splice(@ARGV,0,$cmds{$cmd}) if $cmds{$cmd};
	printf "calling %s(%s)\n", $cmd, join(', ', @args);
	my $ret;
	eval qq{
		\$ret = \$client->$cmd(\@args);
	};
	die ">>> $@ <<<\n" if ($@);
	dd $ret;
}

1;
