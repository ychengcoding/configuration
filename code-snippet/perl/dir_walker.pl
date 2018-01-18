use warnings;
use strict;

use File::Basename;

sub main {
    my @dirs = (".");
    my %seen;
    while (my $pwd = shift @dirs) {
        if (!$seen{$pwd}) {
            process_dir($pwd);
            $seen{$pwd} = 1;
        }
        push @dirs, grep {-d $_} get_directory_files($pwd);
    }
}


sub get_file_name {
    my($file, $dir, $ext) = fileparse(shift @_);
    return $file;
}


sub get_uuid {
    my $uuid = `uuidgen`;
    $uuid =~ s/[\r\n]//g;
    return $uuid;
}


sub get_directory_files {
    my $dir = shift @_;
    if(-d $dir) {
        opendir(DIR, $dir) or die "Cannot open $dir\n";
        my @files = readdir(DIR);
        closedir(DIR);
        return map {$dir . "/" . $_} grep !/^\.\.?$/, @files;
    }
    return ();
}


sub process_dir {
    my $dir = shift @_;
    my @files = get_directory_files($dir);
    if( grep /\.vcxproj$/, @files ) {
        print grep /\.vcxproj$/, @files;
        print "\n";
        print $dir . "\n";
    }
}

main();

