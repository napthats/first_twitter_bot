#!usr/bin/perl

use warnings;
use strict;
use utf8;

use Encode qw{decode encode};

use KNP;

my $knp = KNP->new('command' => '/opt/local/bin/knp');
my $result = $knp->parse(encode('euc-jp', '私はプールで泳いでいる奇麗な少女を見た'));
for my $b ($result->bnst()) {
    print $b->spec();
    print $b->dpndtype();
    print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
    print $b->parent()->spec();
    print "---------------------------------------\n";
}
