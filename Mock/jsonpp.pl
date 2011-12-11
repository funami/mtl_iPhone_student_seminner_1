#!/usr/bin/env perl

use JSON;

my $json = JSON->new;
undef $/;
while (<>) {
    print $json->pretty->encode($json->decode($_));
}