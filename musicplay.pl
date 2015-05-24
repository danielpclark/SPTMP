#!/usr/bin/perl -w

use Term::ANSIColor;

#******************************************************************************
#                     Simple Perl Terminal Music Player 0.4b
#                                   SPTMP 0.4b
#                    By Jonathan Jeffus <istari@salemnet.com>
#******************************************************************************
#
# License:This is distributed under the Perl Artistic License found at:
#         http://www.perl.com/pub/language/misc/Artistic.html
#
# Purpose:SPTMP is a front end to mpg123 and timidity. It gets the directory
#         listing and creates a numbered alphabetized list of the mp3 or midi
#         files in the directory to play. I wrote it one fine evening just for
#         fun. It was never intended to play large mp3 libraries, just a
#         favorites section.
#
# Usage:  Put SPTMP in a directory with lots of midi or mp3 files (it's better
#         if you only have < 20 files.) Then type ./musicplay.pl this will
#         start the program. Type the number of the track you want to play then
#         hit enter to play it. Or type the number of the track followed by a
#         dash and the next track you wish to play to program it (e.g. 3-1-8.)
#         You must have mpg123 to play mp3 and timidity to play midi files.
#         In it's current version you'll need the ANSIColor module.
#
# History:0.1b Just played one mp3 file then died.
#         0.2b Timidity function added.
#         0.3b Programmable code added.  Added ANSIColor.
#         0.4b Started using the System function to run mpg123 and timidity.
#

$timidity_path = "/usr/bin/timidity";
$mpg123_path = "/usr/bin/mpg123";

$dir = `pwd`;
chop ($dir);
$dir = $dir . '/';

if ($ARGV[0] eq '-dir') {
    $dir = $ARGV[1];
}

##### Subroutines #####

while (1) {              # Main Program Loop
    while (1) {
        print (" " x 2900);  # Clear the screen (yes I know it's a kludge.)
        &get_flist;          # Get the file list.
        &print_flist;        # Print the options to the user.
    }
}

##### Get File Listing #####

sub get_flist {                # Get the directory list and put it in an array.
    @ls = `ls $dir`;           # hmmmm, why did I write this again?? It seems
    pop @list until (! @list); # that this is just removing all the items in
                               # the array.
    foreach (@ls) {
        chop ($_);             # Remove the '\n' from the array entries?
        push @list, $_;        # Put the newly cleaned up list entries onto the
    }                          # @list array.
}

sub print_flist {
    my $var = 1;

    ############### Program Title ############### 

    print color 'magenta';
    print "\tSPTMP v0.4b\n";
    print "\tSimple Perl Terminal Music Player\n";
    print color 'green';
    print "\t\tBy Jonathan Jeffus\n\n";
    print color 'blue';
    print "Dir is: $dir\n";
    print color 'bold green';
    print "Select mp3 file to play:\n\n";

    ############### Display entries ############### 

    foreach (@list) {                          # Iterate over each list item.
        if ($_ =~ /\.mp3/ || $_ =~ /\.mid/) {  # If the list item contains .mp3
                                               # or .mid then do the following.
            print color 'yellow';
            print "$var: ";        # Print the song number.
            if ($_ =~ /\.mp3/) {   # If it's an mp3 file make it red.
                print color 'red';
                print "$_\n";      # Print it and go to next line.
            }
            elsif ($_ =~ /\.mid/) { # If it's a mid make it blue.
                print color 'blue';
                print "$_\n";       # Print it and go to the next line.
            }
            $var++;
        }
    }

    ############### Print Prompt ############### 

    print color 'yellow';
    print "cd: ";
    print color 'bold red';
    print "Change directory\n";
    print color 'yellow';
    print "q: ";
    print color 'bold red';
    print "Quit\n";
    print color 'blue';
    print "Enter \#";
    print color 'green';
    print "\: ";
    print color 'yellow';

    ############### Get User Choice ############### 

    chop (my $choice = <STDIN>);   # Get user input.
    if ($choice eq 'cd') {  # Change directory.
        &change_dir;
        return;
    }
    if ($choice eq 'cd ..' or $choice eq 'cd..') {
        $dir =~ s/.{2,}\/.+\/$//;
        return;
    }
    &quit unless ($choice ne 'q'); # &quit if the choice is 'q'.
    @songs = split /-/, $choice;   # Split the choices at the '-'.

    ############### Play Chosen Songs ###############

    foreach (@songs) {
        die "$_ is not numeric!" unless $_ =~ /\d/; # Die if the user enters a
                                                    # non numeric choice.
        --$_;                   # Decrement this since the array begins at 0.
        print color 'blue bold';
        print "\nPlaying $_";
        print color 'reset';
        print ".\n";

        if ($list[$_] =~ /\.mp3/) {                   # If it's a mp3
            system {"$mpg123_path"} '', $dir . $list[$_]; # use mpg123.
        }
        elsif ($list[$_] =~ /\.mid/) {                   # If it's a midi file
            system {"$timidity_path"} '', $dir . $list[$_]; # use Timidity.
        }
    }    
}

sub change_dir {
    print "\nEnter Dir: ";
    chop($dir = <STDIN>);
    print "\n";
}

sub quit {                   # Quit if the user requests it.
    print color 'reset';
    print "Goodbye :-)\n";
    exit;
}
