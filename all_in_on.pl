
use MIME::Base64 qw(encode_base64);
use Encode qw(encode);

use strict;
if(scalar(@ARGV) < 2) {
	die "Usage script <in> <out>\n"; 
}
my $filename = $ARGV[0];
my $outfile = $ARGV[1];

my $out;
open($out, ">", $outfile ) || die "Can not open " . $!; 

my $fh;
open($fh, "<", $filename ) || die "Can not open " . $!; 

print $out "<!-- Auto generated file do not change -->\n";
while(<$fh>) {
	if( m/<\s*((script.*src=)|(link.*href=))"([^"]*)"/ ) {
		if( $2 ) {
			print $out '<script type="text/javascript">';
		}
		if( $3 ) {
			print $out '<style>';
		}
		#print $1 . " - " . $2 . " - " . $4. "\n";
		my $infh;
		open($infh, "<", $4 ) || die "Can not open " . $!; 
		while(<$infh>){
			if(	m/^(.*)url\([ \.'\/]*(.*\.([^']{3,4}))[ \.']*\)/) {
				my $line = $1;
				my $suffix = $3;
				my $pich;

				open (my $nfh, $2) or die $!;
				binmode $nfh;
				local ($/) = undef;  # slurp

				my $image_base64_data = encode_base64(<$nfh>, "");
				close($nfh) or die $!;

				print $out "background: url(\"data:image/$suffix;base64," . $image_base64_data . "\") top left no-repeat;\n";
				next;
			}
			print $out $_;
		}
		if( $2 ) {
			print $out "</script>\n";
		}
		if( $3 ) {
			print $out "</style>\n";
		}

	}

	print $out $_;
}

