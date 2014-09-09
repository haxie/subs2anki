#!/usr/bin/perl -w
# subs2anki.pl - Version 0.0.1
#
# Build an Anki deck from video and subtitle files
# Usage: ./subs2anki -s subs.ass -v video.mkv -o mydeck.txt
#
use strict;
use warnings;
use diagnostics;
use Getopt::Std;
use Time::Piece;
use Cwd;
binmode(STDOUT, ':utf8'); 

# Defaults
my %opt = (
    's'     => undef,
    'v'     => '',
    'o'     => 'anki-deck.txt'
);

# Get command-line args 
getopts('s:v:o:', \%opt);
if (!defined $opt{s}) { usage(); }

my @data = read_subs($opt{s}, "UTF-16LE");
my $dialogue_count = scalar(grep {defined $_} @data);

foreach my $i (0 .. $dialogue_count) {
    generate_assets($data[$i]{start}, $data[$i]{duration}, $opt{v}, $i);
    build_card($data[$i]{text}, cwd(), $opt{o}, $i);
}

# Read and parse the subtitle file
sub read_subs {
    my ($filename, $encoding) = @_;
    my @output;
    my $re = '([^,]*),' x 9;
    open my $data, "<:encoding($encoding)", $filename or die "Could not open subs";
    while (my $line = <$data>) {
        if ($line =~ /^Dialogue: $re(.*)/) {
            my $start = "0" . substr($2, 0, -3);
            my $end = "0" . substr($3, 0, -3);
            my $duration = (Time::Piece->strptime($end, '%H:%M:%S') - Time::Piece->strptime($start, '%H:%M:%S'));

            push @output, { 
                'text' => $10,
                'start' => $start . substr($2, -3),
                'duration' => ($duration == 0 ? 1 : $duration) . substr($3, -3)
            };
        }
    }

    close $data;
    return grep defined, @output;
}

# Generate assets for use in SRS program (mp3, jpg)
sub generate_assets {
    my ($start, $duration, $filename, $iteration) = @_;

    my @audio_args = (
        "ffmpeg",
        "-ss $start -t $duration",
        "-i $filename",
        "-b:a 320K",
        "-vn $iteration.mp3",
        "> /dev/null 2>&1"
    );

    my @screenshot_args = (
        "ffmpeg",
        "-ss $start",
        "-i $filename",
        "-y -f image2",
        "-vcodec mjpeg",
        "-vframes 1",
        "$iteration.jpg",
        "> /dev/null 2>&1"
    );

    my $audio_cmd = sprintf '%s ' x @audio_args, @audio_args;
    my $screen_cmd = sprintf '%s ' x @screenshot_args, @screenshot_args;
    system("$audio_cmd && $screen_cmd");
}

# Build the anki txt file for import
sub build_card {
    my ($text, $directory, $deck_name, $iteration) = @_;

    $text =~ s/\v//g;
    open my $fh, '>>:encoding(UTF-8)', $deck_name or die "Could not create deck";
    print $fh "<strong>$text</strong><br /> <img src='$directory/$iteration.jpg'> <br />[sound:$directory/$iteration.mp3]\n";
    close $fh;
}

sub usage {
    print "Usage: ./subs2anki -s subs.ass -v video.mkv -o mydeck.txt\n";
    exit;
}
