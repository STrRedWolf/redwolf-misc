#!/usr/bin/perl

my $dt=0; 
my $phase=0;
my $idn=1;
my $li=0;
while(<>) {
	chomp; $li++;
	s/^\s+//;
	
	if(/^<!DOCTYPE/) {
		# Start the page properly.  Insert some CSS here.
		print <<EOT;
<!DOCTYPE html>
<head>
<meta name="viewport" content="width=device-width" />
<style type="text/css">
body { -webkit-animation: bugfix infinite 1s; }
@-webkit-keyframes bugfix {
	from { padding: 0; }
	to   { padding: 0; }
}


ul,li {                                                        
	list-style-type: none;                              
}


.title {
	font-weight: bold;
}

section {
	display: none;
}
                 
input:checked ~ section {
	display: block;
}       
</style>
EOT
		next;
	}
	
	if(/^<TITLE>/) {
		print "$_\n</head><body>";
		next;
	}
	
	next if(/^<DD>/); # If it's a <DD> just drop that line.
	
	s/<p>//g; # Strip out all the <p> tags.

	# Swich the <Hx> tags to <span class="title">, insert checkbox
	$idn++ if(s/<H(\d).*?>/<input id="c$idn" type="checkbox" \/><label for="c$idn">/);
	s/<\/H\d>/<\/label>/;

	# Make all <A HREF> open into a new tab. Strip some junk.
	s/<A /<A TARGET="_blank" /;
	s/ADD_DATE="\d+"//;
	s/LAST_MODIFIED="\d+"//;
	s/ICON_URI=".*?"//;
	s/ICON=".*?"//;
	
	
	if(s/^<HR>\s+//) { # Horizontal rule?
		# It's now stripped out.  Print the <HR>
		print "<HR />\n";
	}
	
	# Convert a <DT> to a <LI> and <DL> to a <UL>
	s/^<DT>/<LI>/;
	s/^<DL>/<UL>/;
	s/^<\/DL>/<\/UL>/;
	# <DT> is the pain here, but comes in two flavors. <A or <H3. 
	# <DT><A can just be closed off.
	if(/^<LI><A/) {
		# Just close the link off.
		$_.='</LI>';
	}
	
	# <DT><H3 usually has a <DL> afterwards. The <H3> is closed but
	# not the <DT>. So flag it for after the <DL>.
	if(/^<UL>/) {
		$_='<section>'.$_;
		# Flag it for later processing.
		$dt++;
	}
	if(/^<\/UL>/) {
		#print STDERR "ping! $li\n";
		$_.='</section></LI>';
		$dt--;
	}

	# SPECIAL: If the Bookmarks Toolbar is here, go one level above.
	if(/>Bookmarks Toolbar</) {
		print "</ul></section></li>\n";
		$dt--;
	}
		

	# And done. Print it out.
	print "$_\n";
	
}
print "</body></html>\n";
