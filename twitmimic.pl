#!usr/bin/perl

package twitmimic;

use warnings;
use strict;
use utf8;
use Encode;

use AnyEvent::Twitter::Stream;
use AnyEvent::Twitter;
use Config::Pit;
use URI::Escape;
use Text::Mecab;

binmode(STDOUT, ":utf8");

my $mecab_encode = Encode::find_encoding( Text::MeCab::ENCODING );
my $parser = Text::MeCab->new();



#for (my $node = $parser->parse($mecab_encode->encode('今日はいい天気ですね')); $node; $node = $node->next()) {
#    print $mecab_encode->decode($node->surface()).qq{\n};
#}



my $cv = AnyEvent->condvar;

my $auth = Config::Pit::get('twitter');
my $twitter = AnyEvent::Twitter->new(%$auth);




my $stream = AnyEvent::Twitter::Stream->new(
                                            %$auth,
                                            method => 'sample',
                                            on_tweet => \&exec_tweet,
);



$cv->recv;

sub exec_tweet {
    my $tweet = shift;
    return if(!$tweet->{user} || $tweet->{user}{lang} ne 'ja');

    my @nodes;
    my $flag_ha;
    for (my $node = $parser->parse($mecab_encode->encode($tweet->{text})); $node; $node = $node->next()) {
        next if ($node->stat == 2 || $node->stat == 3);
        push @nodes, $node;
        $flag_ha++ if $mecab_encode->decode($node->surface) eq 'は';

    }
    if ($flag_ha) {
        for my $node (@nodes) {
            print $mecab_encode->decode($node->surface).q{ }.$mecab_encode->decode($node->feature).qq{\n};
        }
    }

    print "-----------------\n";
}
                                  


=pod
$twitter->post('statuses/update',
               {status => Encode::decode_utf8('あいう'),},
               sub {
                   my ($header, $tweet) = @_;
                   warn "$header->{Status} $header->{Reason}\n";
                   warn $tweet->{id_str} if $tweet;
                   $cv->send;
});
=cut
