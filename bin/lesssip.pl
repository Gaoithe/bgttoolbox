#!/usr/bin/perl -w

=head1 NAME

lesser.pl - a customisable (interactively or outeractively) (log)file pager presenting record and channel view and filtering

          - an interactive framework for filtered browsing of logfiles and customising
            of the filtering

=head1 SYNOPSIS

  # Define logfile format - Identity of records
  # D record delimiter
  # I field identifier
  # 
  cat >sccp.cfg 
  D /IUPS: .*SSCOP.*type \(..\)/ sscop_mt
  D /SCCP: message type 0x\(..\)/ sccp_mt
  I /RANAP message type 0x\(..\), procedure code 0x\(..\)/ ranap_tom ranap_pc
  # note the reuse of sccp_mt and later slr/dlr
  # this log - we may not determine bot local refs till later, first print prints 000000 if local ref undetermined
  I /SCCP mt:\(..\) slr:\(.+\) dlr:\(.+\) ssn.*/ sccp_mt sccp_slr sccp_dlr
  # new / found channel do not occur together so there is no override situation
  I /found iups channel id=\(.*\)$/ channel_id
  I /new iups channel id=\(.*\)$/ channel_id
  I /GOT both rnc_lr: \(.*\) and cn_lr: \(.*\)$/ rnclr cnlr

  I /IuPS Channel: \(.*\). .* parked pdus. RNC:\(....\) CN:\(....\) RNC side local ref:\(......\) CN side local ref:\(......\)/ chan_id rncpc cnpc rnclr cnlr
  I /WARNING: unknown direction, dpc:\(...\) opc:\(....\)/ dpc opc

  F sub lrcmp { my $lr=shift; return , $lr0, $lr1, $lr2
  F sub sccp_filt { my $pc0=shift; my $pc1=shift; 
                    my $ilr0=shift; my $ilr1=shift; 
                    return pccmp($rncpc, $pc0, $pc1) &&
                           pccmp($cnpc, $pc0, $pc1) &&
                           lrcmp($rnclr,$ilr0,$ilr1,"000000") && 
                           lrcmp($cnlr,$ilr0,$ilr1,"000000"); }
  Ctrl-D


  ### do D and I differently? 
  ### in plain perl code? my ($sccop_mt) =~ m//;
  ### I is add line of code to ident func/code (run every record encounter)
  ### D is record delimit grep (but also ident as with I)

  # invoke on cmd line
  lesser.pl -c sccp.cfg ~/tmp/IuPSlog.txt

  # user cmds
  ///$ranap_pc == 0x14  ## search (perl search) without filtering
  nnnnp # browse records, select one)
  m # make filter from current record
  F cur_filt sccp_filt('1fa81,'043c','f45634','480056');
  A cur_filt # seperate step to apply filter? (or applies automatically?)
  S cur_filt # save filter

=head1 DESCRIPTION

This is a test/admin tool.

Page large logfiles presenting list of records (e.g. PDUs) and filtering on them.
Ability to select channel of records identified with various fields.
Define record start/end/ignore/identifying lines.
Multi-line identity info collected and different logic may identify a channel.

Page efficiently on large files using fseek. Quick user interface. 
Records presented immediately as available to user.
Respond to ctrl-G/ESC by stopping potentially long file reads (e.g. when searching)

Dynamic add to record identity/filters. 
Quick creation of new file format.

=head1 User Interface 
 
=head2 User view/filter/movement

  v - view mode toggle. record header list/full record
  [np] - next/prev record 
  [fu] [<filter name>] (filter param values) - filter/unfilter toggle (on records matching selected record)
  / - search 
  // - search (within all record text in any mode)
  /// = perl search
  w - write current filter selection to file
  W <list of field names> - write selected field data to file
  m - make filter using info from selected line

#head2 Sublanguage

Define log/record file format.

  I - [-<identname>] <regexp> <list of field names> - identify record fields
  D - [-<identname>] <regexp> <list of field names> - delimit records (and identify record fields as with I)
  F - [-<filter name>] { <expression of cmd/op and field names> } - add to filter stack
  c/r - write/read current Ident/Filter config to/from file
  T - [-<trigger name>] -<filter name> <trigger action> - shell command, inbuilt actions (such as /something; f(filter select) %f filter name %<field name> %t trigger name %s file seek pos %n log file name

-<identname> -<filtername> not implemented yet.
Possible to implement nested stacks of record idents and filters to go 
doen into/p.

=head1 DESIGN/NOTES

Surely someone has done this before?
A customisable less tool. This is more of a tool for development.
But I think applies equally well to software development and systems 
script/tool development.

Normal log file report generators are interested in less user interactivity (perhaps).
A tool like this has the interactive side and non-interactive side.
As fast as possible user interface wise plus can extend it interactively 
and save config changes made. These config changes may be quickly used and
applied to automated runs of the script.

I use a mix of grep/egrep, sed, perl, bash functions to do this.
But. 
Well.
After customizing everything but still finding myself not quite 
able to reduce myself repeating different similar variations on the same
theme over and over and over again ... maybe it is time to write 
something that will make life a little easier.

From ESR's the TAO of Programming there is quite an interesting 
talk about how we connect our tools together - our tool framework.
I think this comes under the framework tool category.
[chomp out of digression into emacs/vi/cmd line editors discussion]
http://www.catb.org/~esr/writings/taoup/html/ch13s03.html#id2967765
"Is Emacs an Argument against the Unix Tradition?"
Rationale or rationalisation? :)

A good tip for vi or emacs or other tools browsing large files.
ESC or Ctrl-C or Ctrl-G often will stop that last command
  or the screen refresh and give you back control.
 
=head2 Apply to Software development/test

You regularily process huge files/db tables/whatever.
You have output record file or log files.
To do development work you iterate a cycle of log file browse/analysis,
development/change of code and regeneration of log files.

Sometimes you are analysing deeply exactly what happens in a particular case. 
Need ability to search, refine filter, search deeply into log. 
Other times you wish system overview. Record stats, counts. Save
of lists of named fields (e.g. |sort |uniq -c analysis).
Non-interactive use is done to keep track of overall system functionality.
e.g. reference snapshot of system, automated tests analysis/checking,
automated build and test reports

=head2 Apply to systems admin/development

I think many more log file analysis tools exist for the sys admin side.
The emphasis is less on interactivity I think (or at least the interactive +
recustomisation is not tied together).

=head2 design features

Browse log. Different user modes.
 Record/channel mode (filters select channel)
 Record summary/full record details.

Customise - add record identities, field selections interactively (and save 
config). Browse completely new files.

Save Channel selections or save fields (for other analysis - plotting etc.)

=head2 surely someone has done this already?

http://www.gnu.org/software/xlogmaster/

http://awstats.sourceforge.net/

http://www.analog.cx/

http://search.cpan.org/~domizio/Template-Magic-Pager-1.15/lib/Template/Magic/Pager.pm

http://search.cpan.org/~jaw/Term-Pager-1.00/Pager.pm
http://search.cpan.org/~pjb/Term-Clui-1.35/Clui.pm

http://www.loganalysis.org/sections/parsing/generic-log-parsers/
http://www.logreport.org/

=head1 EXAMPLE

=head2 define file format

#head2 logfile details

Below is parts of a log from decode of IuPS stack.

Record delimiters: 

 IUPS: Unhandled SSCOP len 000C type 0b
 SCCP: message type 0x05

Record identifiers:

PDU record:

 SCCP: message type 0x05
 SCCP mt:05 slr:84a102 dlr:4cba2e ssn is 00 data len 0 no
 RANAP message type 0x00, procedure code 0x14
 SCCP mt:06 slr:000000 dlr:48004b ssn is 00 data len 56 yes
 GOT both rnc_lr: 48004b and cn_lr: f4b463
 found iups channel id=000f4240 
 new iups channel id=000f4258
 WARNING: creating BAD new iups channel (missed connection setup), not a SCCP CR message 06
 IuPS Channel: 000f4257. 0 parked pdus. RNC:1fa8 CN:043c RNC side local ref:0048009a CN side local ref:00000000  

Channel/refresh record:

 LocalRefMap 478 channels
 IupsChannelMgr 242 channels, pdu count Parked: 2733 Unparked: 2268

Statistics record:

 Started on: Fri Dec  2 10:07:16 2005
 Now time:   Fri Dec  2 10:07:20 2005
 Uptime: 4

 PDUs Read:                              0
 PDUs Retransmitted:                     0
 PDUs Retransmittednp:                   0
 Out of sequence PDUs:                   0

 Processed PDUs:                     19014
 Rate of Processing PDUs:           4753 PDUs per second

 Protocol        Total   Processed       HigherLayerInfo Ignored         Bad
 SSCOP            19014    7513            7513           11501       0
 MTP3B             7513    7507            7507               6       0
 SCCP              7507    7507            5661               0       0
 RANAP             5661    2643            2643            3018       0

 Bad channels (missed CC/CR): 197    deleted: 183    active: 14     PDUs dropped: 72    .

 PDUs dropped because of CREF: 0     

 Total GMM/SM      2643
 GMM               2469    2077                               0       0
 SM                 174     103                               0       0
 Protocol        Total   Processed       Missing Discarded
 SecCtrlProcIni     546     417             121       8
 GMM               2469    2077             314      78
 SM                 174     103              30      41

#head2 logfile (whitespace inserted where records chomped out)

 IUPS: Unhandled SSCOP len 0008 type 0a

 IUPS: Unhandled SSCOP len 000C type 0b

 SCCP: message type 0x05
 SCCP mt:05 slr:84a102 dlr:4cba2e ssn is 00 data len 0 no
 WARNING: unknown direction, dpc:043c opc:2395
 WARNING: unknown direction, dpc:043c opc:2395

 SCCP: message type 0x04
 SCCP mt:04 slr:94b7b9 dlr:4801a7 ssn is 00 data len 0 no
 WARNING: unknown direction, dpc:1fa7 opc:043c
 WARNING: unknown direction, dpc:1fa7 opc:043c
 ERROR: SCCP message without (determined) rnc local ref? dir:-1
 WARNING: not enough info to create or find iups channel. SCCP mt: 04 RNC: 0000 CN: 0000 RNC_lr: 000000 CN_lr: 000000

 SCCP: message type 0x06
 SCCP mt:06 slr:000000 dlr:f4b4da ssn is 00 data len 41 yes
 RANAP message type 0x00, procedure code 0x14 
 ERROR: SCCP message without (determined) rnc local ref? dir:-1
 WARNING: not enough info to create or find iups channel. SCCP mt: 06 RNC: 0000 CN: 0000 RNC_lr: 000000 CN_lr: 000000

 SCCP: message type 0x06
 SCCP mt:06 slr:000000 dlr:48004b ssn is 00 data len 56 yes
 RANAP message type 0x00, procedure code 0x06
 RANAP IE 0x0c len 18
 RANAP IE 0x0c: 00000000: 00008ee72913086eeb3ecdbe04f5e567 ....)..n.>.....g
 00000010: b26e                             .n              
 RANAP IE 0x0b len 18
 RANAP IE 0x0b: 00000000: 00004cb9525beac22286ddbd95f3c61d ..L.R[..".......
 00000010: 3fe2                             ?.              
 RANAP IE 0x4b len 1
 RANAP IE 0x4b: 00000000: 00                               .               
 Got direction 0 from stored opc/dpc arrays.
 Got direction 0 from ranap message type. rnc=8104 cn=1084
 GOT both rnc_lr: 48004b and cn_lr: f4b463
 Got direction 0 from stored opc/dpc arrays.
 Got direction 0 from ranap message type. rnc=8104 cn=1084
 GOT both rnc_lr: 48004b and cn_lr: f4b463
 found iups channel id=000f4240 
 IuPS Channel: 000f4240. 1 parked pdus. RNC:1fa8 CN:043c RNC side local ref:0048004b CN side local ref:00f4b463  

 SCCP: message type 0x02
 called_party_address len=0 spc=043c ssn=8e
 SCCP mt:02 slr:4cbbb1 dlr:4800ae ssn is 8e data len 0 no
 Got direction 0 from stored opc/dpc arrays.
 new CIupsLocalRefMap RNC: 1fa8 CN: 043c RNC_lr: 4800ae CN_lr: 4cbbb1
 RNC side local ref:4800ae CN side local ref:4cbbb1
 found iups channel id=000f4245 


=cut


# page large logfiles presenting list of records(PDUs) and filtering on them
# ability to select channel of records identified with various fields
# define record start/end/identifying lines
# (multi-line identity info collected and different logic may identify a channel)
#
# page efficiently on large files using fseek
# 
# user interface: 
#  n/p - next/prev record 
#  f - filter/unfilter toggle (on records matching selected record)
#  F - (future add to filter stack - filter on anything)
#  / - search 
#  s - search (within all record text)
#
# Sublanguage?
# I (identify field) regexp match + field names
# e.g.

sub recBegin {
    my %recVars;
    $_;
    #( $recVars{'sip_m'}, $recVars{'sip_mt'} ) = m/^(.*) (.*)/;
    $recVars{'sip_mt'} = m/^([A-Z][A-Z]*) (.*)/;
    print "debug sip_m:" . $recVars{'sip_mt'} . "\n";
    #$recVars{'sccp_mt'} = m/SCCP: message type 0x\(..\)/;
    if ($recVars{'sip_mt'}) { return 1; }
    print "debug 0 $0 _ $_\n";
    #print "debug 0 $0 1 $1 2 $2\n";
    return 0;
}

sub recLine {
    my %recVars;
    ( $recVars{'ranap_tom'}, $recVars{'ranap_pc'} ) = 
        m/RANAP message type 0x\(..\), procedure code 0x\(..\)/;

    # note the reuse of sccp_mt and later slr/dlr
    # this log - we may not determine bot local refs till later, first print prints 000000 if local ref undetermined
    ( $recVars{'sccp_mt'}, $recVars{'sccp_slr'}, $recVars{'sccp_dlr'} ) = 
        m/SCCP mt:\(..\) slr:\(.+\) dlr:\(.+\) ssn.*/;

    # new / found channel do not occur together so there is no override situation
    ( $recVars{'channel_id'} ) = 
        m/found iups channel id=\(.*\)$/;
    ( $recVars{'channel_id'} ) = 
        m/new iups channel id=\(.*\)$/;
    ( $recVars{'rnclr'}, $recVars{'cnlr'} ) = 
        m/GOT both rnc_lr: \(.*\) and cn_lr: \(.*\)$/;
    
    ( $recVars{'chan_id'}, $recVars{'rncpc'}, $recVars{'cnpc'}, $recVars{'rnclr'}, $recVars{'cnlr'} ) = 
        m/IuPS Channel: \(.*\). .* parked pdus. RNC:\(....\) CN:\(....\) RNC side local ref:\(......\) CN side local ref:\(......\)/;
    ( $recVars{'dpc'}, $recVars{'opc'} ) = m/WARNING: unknown direction, dpc:\(...\) opc:\(....\)/;
    return &{%recVars};
}


sub lrcmp { 
    my $lr=shift; my $lr0=shift; my $lr1=shift; my $lr2=shift;
    if ($lr == $lr0 || $lr == $lr1 || $lr == $lr2) { return 1 };
}

sub pccmp { 
    my $pc=shift; my $pc0=shift; my $pc1=shift;
    if ($pc == $pc0 || $pc == $pc1) { return 1 };
}
 
sub sccp_filt { 
    my $pc0=shift; my $pc1=shift; 
    my $ilr0=shift; my $ilr1=shift; 
    return pccmp($rncpc, $pc0, $pc1) &&
        pccmp($cnpc, $pc0, $pc1) &&
        lrcmp($rnclr,$ilr0,$ilr1,"000000") && 
        lrcmp($cnlr,$ilr0,$ilr1,"000000"); 
}

my $file = shift;

if ( !open( FILE, "<$file" )) {
    warn "$file: $!";
    next;
} else {
    print "Data from $file\n";
}

# array of records - load in 80? (+ more in bg)
my $scr_lines = 80;
my @recs;

my $pos = tell(FILE);
while ( <FILE> ) {
    if ( recBegin($_) ) { # begin of record
        my %rec;
        $rec{'pos'} = $pos;
        if ( $bits[0] ne "#2c" and $bits[0] =~ /$match/ ) {
            print "Site " . $bits[0] . "\n  ";
            shift @bits;
            print join( "\n  ", @bits );
            print "\n";
        }
        @bits = ();
        next;
    }
    $pos = tell(FILE);
}
