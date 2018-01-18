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
    my $file_path = shift @_;
    my($file, $dir, $ext) = fileparse($file_path);
    return $file;
}


sub get_uuid {
    my $uuid = `uuidgen`;
    $uuid =~ s/[\r\n]//g;
    return $uuid;
}

sub get_directory_files {
    my $dir = shift @_;
    if( -d $dir) {
        opendir(DIR, $dir) or die "Cannot open $dir\n";
        my @files = readdir(DIR);
        closedir(DIR);
        return map {$dir . "/" . $_} grep !/^\.\.?$/, @files;
    }
    return [];
}

sub process_dir {
    my $dir = shift @_;
    my @files = get_directory_files($dir);
    if( grep /\.vcxproj$/, @files ) {
        if(not grep /\.vcxproj.filters$/, @files ) {
            generate_vs_filters($dir);
        }
    }
}

sub generate_vs_filters {
    my $dir = shift @_;
    my @headers = glob("$dir/*.h");
    my @cpps = glob("$dir/*.cpp");
    my @resource = glob("$dir/*.rc");
    my @texts = glob("$dir/*.txt");

    my $header_uuid = get_uuid();
    my $cpp_uuid = get_uuid();
    my $resource_uuid = get_uuid();

    my $template = <<"END";
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup>
    <Filter Include="Source Files">
      <UniqueIdentifier>{$cpp_uuid}</UniqueIdentifier>
      <Extensions>cpp;c;cc;cxx;def;odl;idl;hpj;bat;asm;asmx</Extensions>
    </Filter>
    <Filter Include="Header Files">
      <UniqueIdentifier>{$header_uuid}</UniqueIdentifier>
      <Extensions>h;hpp;hxx;hm;inl;inc;xsd</Extensions>
    </Filter>
    <Filter Include="Resource Files">
      <UniqueIdentifier>{$resource_uuid}</UniqueIdentifier>
      <Extensions>rc;ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe;resx;tiff;tif;png;wav</Extensions>
    </Filter>
  </ItemGroup>
END

    # source files
    if(@cpps) {
        $template .= "\n    <ItemGroup>\n";

        foreach my $name (@cpps) {
            $name = get_file_name($name);
            my $elem = <<"CPP_END";
        <ClCompile Include="$name">
            <Filter>Source Files</Filter>
        </ClCompile>
CPP_END
            $template .= $elem;
        }
        $template .= "    </ItemGroup>\n\n";
    }
    # headers files
    if(@headers) {
        $template .= "    <ItemGroup>\n";

        foreach my $name (@headers) {
            $name = get_file_name($name);
            my $elem = <<"HEADER_END";
        <ClInclude Include="$name">
            <Filter>Header Files</Filter>
        </ClInclude>
HEADER_END
            $template .= $elem;
        }
        $template .= "    </ItemGroup>\n\n";
    }

    # resource files
    if (@resource) {
        $template .= "    <ItemGroup>\n";

        foreach my $name (@resource) {
            $name = get_file_name($name);
            my $elem = <<"RESOURCE_END";
        <ResourceCompile Include="$name">
            <Filter>Resource Files</Filter>
        </ResourceCompile>
RESOURCE_END
            $template .= $elem;
        }
        $template .= "    </ItemGroup>\n\n";

    }

    # text files
    if (@texts) {
        $template .= "    <ItemGroup>\n";

        foreach my $name (@texts) {
            $name = get_file_name($name);

            my $elem = <<"TEXT_END";
        <Text Include="$name" />
TEXT_END
            $template .= $elem;
        }
        $template .= "    </ItemGroup>\n";
    }

    $template .= "</Project>\n";
    print $template;

    my ($filters_file,) =  grep /\.vcxproj$/, get_directory_files($dir);
    $filters_file .= ".filters";

    open (FILE, "> $filters_file") || die "problem opening $filters_file\n";
    print FILE $template;
    close(FILE);
}

main();

