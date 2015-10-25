#!/usr/bin/perl

use strict;
use warnings;
# use utf8;
use diagnostics;
use File::Slurp;
use Getopt::Std;
use Data::Dumper;
use JSON::Parse 'parse_json';

binmode STDOUT, ':utf8';

getopts('c', \ my %opts );

my $jsonFile = read_file( 'Hangouts.json' ) ;

# how deep to traverse the JSON object
my $maxDepth = $ARGV[0] || 1;
my $conversation_id = $ARGV[1] || 0;
my $currentDepth;

# hash
my $parsedContentRef = parse_json ($jsonFile);

# conversation paths
# my $conversation_root = $parsedContentRef->{conversation_state}->[0]->{conversation_state}->{conversation};
# my $conversation_name = $conversation_root->{name};
# my $user_names = $conversation_root->{participant_data}->[0]->{fallback_name};

# my $event_root = $parsedContentRef->{conversation_state}->[0]->{conversation_state}->{event};
# my $conversation_mesage = $event_root->[0]->{chat_message}->{message_content}->{segment};
# ->[0]->{text};

if ($opts{c}) {
	# print "\n The value of the -c switch is $opts{c} \n";
	print "Conversation List:\n";
	ListConversations();
}else{

	# print 'Conversation name: '.$conversation_name ."\n";
	# print outputConversation($event_root,$conversation_id);
	# mine($conversation_root->{current_participant});
	# mine($event_root);
	# mine($conversation_root);
	# mine($parsedContentRef->{conversation_state});
	mine($parsedContentRef->{conversation_state}->[0]->{conversation_state}->{conversation}->{participant_data});
}

sub ListConversations {
	my $conversationArray = $parsedContentRef->{conversation_state};
	my $conversationCount = scalar @$conversationArray;
	print 'array length: '.$conversationCount."\n";
	for (my $counter = 0; $counter < $conversationCount; $counter++) {
		our $name = $conversationArray->[$counter]->{conversation_state}->{conversation}->{name};
		# print 'Type: '.$conversationArray->[$counter]->{conversation_state}->{conversation}->{type};
		if (defined($name)){
			print 'Hangout Name: '.$name."\n";
			printUserNames($conversationArray->[$counter]->{conversation_state}->{conversation});
		}

		# This path does not print all? 21
		# print ($conversation_root->[$counter]->{name});
		# print "\n";
	}
}

sub outputConversation {
	my ($messageEvents,$conversation_id) = @_;
	foreach (@$messageEvents){
		# print "m: ";
		print 'TS: '.$_->{timestamp}.' ';
		print $_->{chat_message}->{message_content}->{segment}->[0]->{text} if defined($_->{chat_message}->{message_content}->{segment}->[0]->{text});
		print "\n";
	}
}

sub printUserNames {
	my ($conversation) = @_;
	my $users = $conversation->{participant_data};
	my $participantCount = scalar @$users;
	print "Participents($participantCount): ";
	for (my $counter = 0; $counter < $participantCount; $counter++) {
		print $users->[$counter]->{fallback_name}.',';
	}
	print "\n\n";
}

sub mine {
	$currentDepth++;
	print "currentDepth: $currentDepth \n";
	my ($payload) = @_;
	my $type = checkType($payload);
	if ('HASH' eq $type){
		mineHashElements($payload);
	}elsif('ARRAY' eq $type){
		mineArrayElements($payload);
	}
	
}


sub mineHashElements {
	my ($expandHash) = @_;
	print "key list for level $currentDepth \n";
	while ( my ($key, $value) = each %{$expandHash} ){
		if(isScalar($value)){
			print "key: $key value: $value\n";
		}else{
			print "key: $key OBJECT\n";
		}
	}

	while ( my ($key, $value) = each %{$expandHash} ){
		if ($currentDepth >= $maxDepth){
			print "mineHashElements key: $key, value: $value\n";	
		}elsif(!isScalar($value)){
			print "NOT Scaler, mining... key: $key, value: $value\n";	
			mine($value);
			$currentDepth--;
		}
	}
}

sub mineArrayElements {
	my ($expandArray) = @_;
	print "key list for level $currentDepth \n";
	while ( my ($key2, $value2) = each @{$expandArray} ){
		if(isScalar($value2)){
			print "key: $key2 value: $value2\n";
		}else{
			print "key: $key2 OBJECT\n";
		}
	}

	while ( my ($key2, $value2) = each @{$expandArray} ){
		if ($currentDepth >= $maxDepth){
			print "mineArrayElements key: $key2, value: $value2\n";	
		}elsif(!isScalar($value2)){

			print "NOT Scaler, mining... key: $key2, value: $value2\n";
			mine($value2);
			$currentDepth--;
		}
	}
}

sub isScalar {
	if(!( 'HASH' eq ref $_[0] or 'ARRAY' eq ref $_[0])){
		return 1;
	}
}

sub checkType {
	return ref $_[0];
}

# sub expandHashElements {
# 	my ($expandHash) = @_;
# 	while ( my ($key, $value) = each %{$expandHash} ){
# 		print "key: $key, value: $value\n";
# 	}
# }




# while ( my ($key, $value) = each @{$parsedContentRef->{conversation_state}} ){
# 	# print " ----------------- key: $key, value: $value ------------------ \n";
# 	foreach my $keys ( keys %$value ){
# 		print "key: $key, value: $value->{$key}\n";
# 		while ( my ($key2, $value2) = each %{$value->{$key}} ){
# 			print "key: $key2, value: \n";
# 		}
# 	}

# }



