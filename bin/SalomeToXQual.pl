#!/usr/bin/perl -w

=head1 NAME

SalomeToXQual.pl - convert SalomeTMF exported file to XStudio .csv ready for import 

=head1 SYNOPSIS

Read in Salomé_TMF exported .xml file.
Choose a Test Plan and set of tests to import.
Write out .xml or .csv that XQual can read.

Salomé project INX8000-OLC
-> Data exchange format -> Export xml  xml_export_olc_all.xml   (file saved to Desktop)

Read in that file (as XML).
Read in Famille Nom, offer user choice of Famille Nom and/or SuiteTest Nom to choose.
Read in all wanted particular items matching Famille and SuiteTest.
Save to ; delimited .csv (awkward with excel) and "   " indented for "with testplan" option.
Write fields out (some values merged, others generated/hardcoded).

=head1 USAGE

# call giving salome exported xml file, test famille are shown
$ SalomeToXQual.pl xml_export_olc_all.xml

# call specifying salome xml and test famille(can be perl regexp)
# output file is generated: xml_export_olc_all_SU_A2_OLC.csv
$ SalomeToXQual.pl xml_export_olc_all.xml "SU_A2 OLC"

# call specifying salome xml and test famille and test suite
$ SalomeToXQual.pl INX8000-BI-Salome.xml "Integ" "Sprint 11"

Integration SUA1
SuiteTest Nom:Sprint 6 - Config
SuiteTest Nom:Sprint 6 - Startup
SuiteTest Nom:Sprint 7 - Software Download
SuiteTest Nom:Sprint 7 - Web Services
SuiteTest Nom:Sprint 8 - Web Services
SuiteTest Nom:Sprint 8 - Reverse Proxy
SuiteTest Nom:Sprint 9 - Reverse Proxy
SuiteTest Nom:Sprint 9 - Alarms
SuiteTest Nom:Sprint 10 - Logging
SuiteTest Nom:Sprint 10 - Service Discovery
SuiteTest Nom:Sprint 10 - Software Download
SuiteTest Nom:Sprint 10 - Web Services & Reverse Proxy for PPC
SuiteTest Nom:Sprint 11 - Inventory
SuiteTest Nom:Sprint 11 - Startup - logging
SuiteTest Nom:Sprint 11 - Warm and Cold Restart
SuiteTest Nom:Sprint 11 - Alarms
SuiteTest Nom:Sprint 11 - Instancing
SuiteTest Nom:Sprint 11 - Software Download & Restart
SuiteTest Nom:Backlog
Software SUA1

=head1 SPEC

I tried doing this Salome_TMF export -> excel -> .csv -> XStudio.
But excel .csv output is annoyingly limited. 
Possibly could get closer with openoffice but feh.

=head2 INPUT Salome_TMF .xml format

<SalomeDynamique>
  <ProjetVT>
.
    <Familles>
      <Famille id_famille="Fam_53">
        <Nom>OLC</Nom>
.
      <Famille id_famille="Fam_102">
        <Nom>SU_A2 OLC</Nom>
        <Description>Area for tests which are parts of this phase of testing</Description>
        <SuiteTests>
          <SuiteTest id_suite="SuiteTest_198">
            <Nom>SU_A2</Nom>

=head2 Mapping Salomé .xml/.xls fields to XStudio format

A+BI+BJ (projet+id_famille+Nom) category; (set to 4) priority; (set to "") canonicalPath;(set to test script name) path
 BM (id_test) index; (set to 1) implemented; BP (Nom) name;
   CK+CL+CM step;param1,param2,...; CN check1,check2,...

=head2 XQual XStudio .csv and .xml import format

Format .xml or .csv or .csv with test plan
The .xml format (detailed below) for import I have not tested.
The IDs are in the .xml, how would we decide on those when importing?
So I'm using use .csv to import.

Tests and Testcases (without testplan)
category;implemented;priority;canonicalPath;path;indexTestcase1,indexTestcase2,...

OR Tests and Testcases (with testplan>, indentation spaces matter)
category;priority;canonicalPath;path(script name)
   index;implemented;name
      step;param1,param2,...;check1,check2,...

=head2 OUTPUT XStudio .csv in format

# the indentation whitespace matters
# test path must begin with /
# numeric fields must be numeric
# ColdRestartsOfTCS.tcl is the script for this example  (one script for all test cases in category)

SU_A2;4;TestCanPathIsScriptNameMaybe;/TestPath/ColdRestartsOfTCS

   1159;0;Cold Restarts of TCS with no input power

      Action_1075 A0 Check bringup wait time for WSS;;"20 minutes, or longer. [HLD.OPTA.BLK_E.0010]"
      Action_1076,A1,There is no optical output during this startup phase [Bringup slides] & R[HLD.OPTA.BLK_E.0011];;Using a power meter confirm
      Action_1077,A2,"After warm-up phase complete if BI available, manufacture and calibration phase available then the following three tasks commence \n1) CC TX - CC laser and APR ON \n2) CC RX - Coarse RX Loop starts \n3) Data plane 1st powers and warms up \n";;Confirm these tasks commence.
      Action_1090,A3,###############################################################################################################################################################################################################################################################;;Due to the fact that only part of the functionally is available cannot see without that stubbing that the bring can complete. This step attempts to highlight this issue.

=head2 running 

I'm using cygwin's perl for now. By default XML/LibXML.pm is available.

#!/cygdrive/c/Perl/bin/perl -w
$ perl c:/Perl/scripts/SalomeToXQual.pl
Can't locate XML/LibXML.pm in @INC (@INC contains: c:/Perl/site/lib c:/Perl/lib .) at c:/Perl/scripts/SalomeToXQual.pl line 283.

=head2 and match2 SuiteTest name match added

james.coleman@INTUNE-JCOLEMAN ~/Desktop
$ SalomeToXQual.pl INX8000-BI-Salome.xml "Int"
/cygdrive/c/Perl/scripts/SalomeToXQual.pl filename=INX8000-BI-Salome.xml ofilename=INX8000-BI-Salome_Int.csv match=Int
Integration SUA1
MATCH Integration SUA1
SuiteTest Nom:Sprint 6 - Config
SuiteTest Nom:Sprint 6 - Startup
SuiteTest Nom:Sprint 7 - Software Download
SuiteTest Nom:Sprint 7 - Web Services
SuiteTest Nom:Sprint 8 - Web Services
SuiteTest Nom:Sprint 8 - Reverse Proxy
SuiteTest Nom:Sprint 9 - Reverse Proxy

=head2 DESIGN

http://perl-xml.sourceforge.net/faq/#quick_choice

=cut 

use strict;

use XML::LibXML;

# defaults
my $filename = shift;
my $ofilename;
my $match = shift;
my $match2 = shift;
my $test_is_cat = 1; # one test is one category in XStudio or all tests are in famille category

$filename="c:/Documents and Settings/james.coleman/Desktop/xml_export_olc_all.xml" if (!defined $filename);
#$match = "SU_A2 OLC" if (undef $match);
$match = "" if (!defined($match));
$match2 = "" if (!defined($match));
my $matchhash = $match;
$matchhash =~ s/[^\w\d]/_/g;
if (!defined $ofilename) {
    $ofilename=$filename;
    $ofilename =~ s/.xml$//;
    $ofilename .= "_${matchhash}.csv";
}
print "$0 filename=$filename ofilename=$ofilename match=$match\n";

my $parser = XML::LibXML->new();
my $doc    = $parser->parse_file($filename);

# TODO user passes in filename [optional outfile] [optional regexp/list of famille to take]
#my $c = $#ARGV + 1;
#print FILE "ARGC=$c\n";
#foreach my $i (0 .. $#ARGV) {
#    print FILE "arg ARGV[$i]=$ARGV[$i]\n";
#}

open(FILE, '>', $ofilename) or die $!;

# ct = current test
my %ct;
my ($category,$priority,$canonicalPath,$path);
my ($index,$impl,$name);
my ($step,$param1,$param2,$check1,$check2);

$ct{'category'} = "0xdeadbeef";
$ct{'path'} = "0xdeadbeef";
$ct{'index'} = "0xdeadbeef";
$ct{'name'} = "0xdeadbeef";
$ct{'step'} = "0xdeadbeef";
$ct{'param1'} = "";
$ct{'param2'} = "";
$ct{'check1'} = "";
$ct{'check2'} = "";

$ct{'priority'} = 4;
$ct{'canonicalPath'} = "";
$ct{'impl'} = 0;

$ct{'project'} = $doc->findnodes('//Nom')->to_literal;

foreach my $f ($doc->findnodes('//Familles/Famille')) {
    my($n) = $f->findnodes('./Nom');
    print $n->to_literal, "\n";

    next if ($match eq "");

    $_ = $n->to_literal;
    if (m/$match/) {
	print "MATCH ", $n->to_literal, "\n";
	$ct{'category'} = $n->to_literal;
	$ct{'cathash'} = $ct{'category'};
        $ct{'cathash'} =~ s/[^\w\d]/_/g;

	foreach my $sts ($f->findnodes('.//SuiteTests')){
	foreach my $st ($sts->findnodes('.//SuiteTest')){
	my $stn = $st->findnodes('./Nom');
        $ct{'stn'} = $stn->to_literal;
	print "SuiteTest Nom:" . $ct{'stn'} . "\n"; 
        next if ($match2 eq "");
        $_ = $ct{'stn'};
        if (m/$match2/) {

	### PATH MUST BEGIN WITH /
        # e.g. /IntuneTest/SU_A2_OLCTestScript
        $ct{'cathash'} = $ct{'category'}."_".$ct{'stn'};
        $ct{'cathash'} =~ s/[^\w\d]/_/g;
        my $scriptname = $ct{'cathash'}."TestScript";
        my $scriptdir = "C:/Tcl/scripts/";
        $scriptname =~ s/[^\w\d]/_/g;
	$ct{'path'} = "/IntuneTest/".$scriptname;

        # TODO check match2 against suite test name

	#print "Suite: ", $s->to_literal, "\n";
	foreach my $tests ($f->findnodes('.//Tests')) {
	#my($tests) = $f->findnodes('.//Tests');
	#print "Tests: ", $tests->to_literal, "\n";

#category;priority;canonicalPath;path(script name)
#   index;implemented;name
#      step;param1,param2,...;check1,check2,...

        if (!$test_is_cat) {
            #OR We can print category line here
	    print FILE "\n$ct{'category'};$ct{'priority'};$ct{'canonicalPath'};$ct{'path'}\n";

            #create empty script file
            `touch ${scriptdir}${scriptname}".tcl"`;
        }

	foreach my $t ($tests->findnodes('.//Test')) {

	    my @a0 = $t->attributes();
	    #$ct{'index'} = $t->getAttribute('test_id');
	    $ct{'index'} = $a0[0]->getValue();
	    $ct{'index'} =~ s/[^0-9]//g;

	    my $tn = $t->findnodes('./Nom');
	    $ct{'name'} = $tn->to_literal;

            if ($test_is_cat) {
                # how best hash test name to script name? 
                #   1159;0;Cold Restarts of TCS with no input power
                #CldRstrtsfTCSwthnnptpwr - wurgh.
	        $ct{'namehash'} = $ct{'name'};
	        $ct{'namehash'} =~ s/[aeiou ]//g;

                $scriptname = $ct{'cathash'}."_".$ct{'namehash'}."TestScript";
                $scriptname =~ s/[^\w\d]/_/g;
                #create empty script file
                `touch ${scriptdir}${scriptname}".tcl"`;

	        #$ct{'path'} = "/IntuneTest/".$ct{'cathash'}.$ct{'index'}."TestScript";
	        $ct{'path'} = "/IntuneTest/".$ct{'cathash'}.$ct{'namehash'}."TestScript";
                #OR We can print category line here
	        print FILE "\n$ct{'category'};$ct{'priority'};$ct{'canonicalPath'};$ct{'path'}\n";
            } else {
                $scriptname = $ct{'cathash'}."_".$ct{'index'}."TestScript";
                $scriptname =~ s/[^\w\d]/_/g;
                #create empty script file
                `touch ${scriptdir}${scriptname}".tcl"`;
            } 

	    # no test name in .csv :(  NO, actually yuou can do it (and must I think) - had a different problem
	    # AND two \n's are VITAL!
	    print FILE "\n   $ct{'index'};$ct{'impl'};$ct{'name'}\n\n";
	    #print FILE "\n   $ct{'index'};$ct{'impl'}\n\n";
	    # place test name in 1st test step
	    #print FILE "      $ct{'name'};;\n";
	    
	    ### TODO Test Description not included 
	    # my $desc = $tests->findnodes('./Description')) {
	    foreach my $step ($t->findnodes('./TestManuel/ActionTest')) {
		my @stepa0 = $step->attributes();
		$ct{'step'} = $stepa0[0]->getValue();
		$ct{'step'} .= "," . $step->findnodes('./Nom')->to_literal;
		$ct{'step'} .= "," . $step->findnodes('./Description')->to_literal;
		$ct{'check1'} = $step->findnodes('./ResultAttendu')->to_literal;
		#print FILE "      $ct{'step'};$ct{'param1'},$ct{'param2'},;$ct{'check1'},$ct{'check2'},\n";
		$ct{'step'} =~ s/[;,]/_/g;
		$ct{'param1'} =~ s/[;,]/_/g;
		$ct{'check1'} =~ s/[;,]/_/g;
		print FILE "      $ct{'step'};$ct{'param1'};$ct{'check1'}\n";
	    }
	}
        }
	}
        }
        }
    }
}

my $ts = time();

close FILE;


=head2 Salomé .xml exported format

<?xml version="1.0" encoding="ISO-8859-15"?>

<SalomeDynamique>
  <ProjetVT>
    <Nom>*INX8000-OLC</Nom>
    <Description>Official area for OLC Test Environment.Includes Tests, Test Results</Description>
.
    <GroupesDePersonnes>
.
    <Requirements id_req="Req_0">
      <RequirementFamily id_req="Req_7689" id_req_parent="Req_0">
        <Nom>ECS</Nom>
.
    <Environnements>
      <Environnement idEnv="Env_19">
        <Nom>Hardware Card Designer Test</Nom>
      </Environnement>
      <Environnement idEnv="Env_28">
        <Nom>OFS Optics Daughter Card: demo Board</Nom>
        <Description>Seamus's board with the following devices attached.</Description>
      </Environnement>
    </Environnements>
    <Familles>
      <Famille id_famille="Fam_53">
        <Nom>OLC</Nom>
        <SuiteTests>
          <SuiteTest id_suite="SuiteTest_102">
            <Nom>Control Channel</Nom>
            <Tests>
              <Test id_test="Test_554">
                <Concepteur>
                  <Nom>cormac.kelly</Nom>
                  <Login>cormac.kelly</Login>
                </Concepteur>
                <Nom>CC_RX.001 Coarse Control</Nom>
                <Date_crea>23 avr. 2009</Date_crea>
                <Description isHTML="true">SUMMARY: Upon cold start of card without Loss Of Signal condition present, system applies coarse control process. Once it receives an external event it proceeds to fine control.
                  <br/>
                  <br/>Can be automated - clarifying startup state
                  <br/>
                  <br/>Priority H (Assuming : High/Medium/Low options)
                  <br/>
                  <br/>Manual Execute: 15 mins (N.B. NOT SETUP TIME)
                </Description>
                <Executed>true</Executed>
                <LinkRequirement>
                  <RequirementRef ref="Req_8043">
                    <Nom>HLD.OLC.CCC.002</Nom>
                    <Description isHTML="true">The CC Rx optical power level at the Carrier Sense input will be actively controlled when the CC_LOS alarm (measured using PD_CC) is clear. (Note ? CC SFP i/p power level and the CS CC i/p power level are automatically linked in the optical architecture.) Required CC Pwr level at CS PD is as specified in the Optical Architecture.</Description>
                  </RequirementRef>
                  <RequirementRef ref="Req_8045">
                    <Nom>HLD.OLC.CCC.004</Nom>
                    <Description isHTML="true">CC_Rx_Bringup.
                      <br/>Initialise VOA_CC to maximum attenuation.
                      <br/>Upon Cold Start and CC_LOS Clear, the CC Rx level will be set to the required level (within the VOA accuracy), using coarse feedforward control and the PD_CC measurement and an estimation of the required VOA attenuation. Upon CC_LOS active, set VOA_CC attenuation to maximum.
                      <br/>Recommence control upon CC_LOS Clear, with VOA initially at maximum attenuation.
                      <br/>Check correctness of power level: CC_Rx_Fault alarm to be raised if SFP and CS do not agree that power is within range.
                      <br/>Allowed delay between CC_LOS Clear and power level achieved ? 20ms.
                      <br/>Remain in Coarse control mode, continuing to control VOA_CC using PD_CC measurements, until the ring gain is set by DC_GA.
                    </Description>
                  </RequirementRef>
                </LinkRequirement>
                <Attachements>
                  <FileAttachement nom="3screenshot.jpg" dir="Attachements/53/102/554/3screenshot.jpg">
                    <Date>2009-04-28</Date>
                  </FileAttachement>
                </Attachements>
                <TestManuel>
                  <ActionTest id_action="Action_685">
                    <Nom>A0</Nom>
                    <Description>The cc_rx_control module is initiated. The emulates a power on and mandated cold start. Power fed into the system is within the nominal values expected.</Description>
                    <ResultAttendu>The initial state of the cc_rx module is coarse control state. With loss of signal in-active then the sub state of the module entered is apply coarse control.</ResultAttendu>
                  </ActionTest>
                  <ActionTest id_action="Action_686">
                    <Nom>A1</Nom>
                    <Description>The course control setting adjusts the VOA_CC to be less than the coarse threshold value away from target value</Description>
                    <ResultAttendu>VOA_CC to be less than the coarse threshold value away from target value</ResultAttendu>
                  </ActionTest>
                  <ActionTest id_action="Action_687">
                    <Nom>A2</Nom>
                    <Description>The module remains in course adjust state</Description>
                    <ResultAttendu>Reported state at this stage is out of service</ResultAttendu>
                  </ActionTest>
                  <ActionTest id_action="Action_688">
                    <Nom>A3</Nom>
                    <Description>The OLC process declares that the WSS restoration has been competed. \nThis is currently by means of an external event triggering event - which has yet to be written. Simulated by a feed into the module. \nThe cc_rx_control module can then proceed into fine control mode.</Description>
                    <ResultAttendu>It will sit in locked sub-state within this module. \nState at this stage is in service \n</ResultAttendu>
                  </ActionTest>
                </TestManuel>
              </Test>
.
          </SuiteTest>
        </SuiteTests>
      </Famille>
      <Famille id_famille="Fam_102">
        <Nom>SU_A2 OLC</Nom>
        <Description>Area for tests which are parts of this phase of testing</Description>
        <SuiteTests>
          <SuiteTest id_suite="SuiteTest_198">
            <Nom>SU_A2</Nom>
            <Description isHTML="true">This is to allow creation of test cases only. The format used by BI is not suitable for this level as the sprint by sprint delievery of features is not something which is yet defined
.
            </Description>
            <Tests>
              <Test id_test="Test_1159">
                <Concepteur>
                  <Nom>ian.holmes</Nom>
                  <Login>ian.holmes</Login>
                </Concepteur>
                <Nom>Cold Restarts of TCS with no input power</Nom>
                <Date_crea>2 juil. 2009</Date_crea>
                <Description isHTML="true">
                  <p style="margin-top: 0">This test case attempts to validate the behaviour of the CCrx loop whil ethere is no power at the input.
                    <br/>
                    <br/>
                    <b>Note:</b>The behaviour of the sytem under LOS condition has not yet been defined(4-8-09) so the expected results may not be wholly accurate
                    <br/>
                    <br/>
                    <b>
                      <br/>Comments from James Curran (10-8-09):
                    </b>
                    <br/>cannot test "3) Data planes first powers and warms up" now - remember real SFP not available
                    <br/>not in a position to test end to end now - just blocks 1,2 and 3
                    <br/>would not bother with robustness tests yet
                  </p>
                  <p style="margin-top: 0"></p>
                </Description>
                <Executed>false</Executed>
                <TestManuel>
                  <ActionTest id_action="Action_1075">
                    <Nom>A0</Nom>
                    <Description>Check bringup wait time for WSS</Description>
                    <ResultAttendu>20 minutes, or longer. [HLD.OPTA.BLK_E.0010]</ResultAttendu>
                  </ActionTest>
                  <ActionTest id_action="Action_1076">
                    <Nom>A1</Nom>
                    <Description>There is no optical output during this startup phase [Bringup slides] &amp; R[HLD.OPTA.BLK_E.0011]</Description>
                    <ResultAttendu>Using a power meter confirm</ResultAttendu>
                  </ActionTest>
                  <ActionTest id_action="Action_1077">
                    <Nom>A2</Nom>
                    <Description>After warm-up phase complete if BI available, manufacture and calibration phase available then the following three tasks commence \n1) CC TX - CC laser and APR ON \n2) CC RX - Coarse RX Loop starts \n3) Data plane 1st powers and warms up \n</Description>
                    <ResultAttendu>Confirm these tasks commence.</ResultAttendu>
                  </ActionTest>
                  <ActionTest id_action="Action_1090">
                    <Nom>A3</Nom>
                    <Description>Following this it is anticipated, examining the bringup slides from Emilio, that there will be a series of interactions with other external modules such as Base Infrastructure, and internal modules yet to be developed, such as ROPC. \nIn order for the bring to complete these modules must be stubbed out e.g. nominal values provided. \n \nIntegration will be testing the functionality end to end, so will require that the stubbing out/bypassing is performed by another party, probably software.</Description>
                    <ResultAttendu>Due to the fact that only part of the functionally is available cannot see without that stubbing that the bring can complete. This step attempts to highlight this issue.</ResultAttendu>
                  </ActionTest>
                  <ActionTest id_action="Action_1091">
                    <Nom>A4</Nom>
                    <Description>For the receiver control the card enters course loop start. As there is no input power at this stage then the module will sit in coarse loop mode.</Description>
                    <ResultAttendu>Confirm state by querying the cli with the command 'ccrx state'. This should report that the receive loop remains in coarse state with a LOS sub state. Note the state and sub state names are not detailed in the cli commands document. Are they captured/defined elsewhere? This is important when it comes to automation of testing i.e. looking for a specific phase.</ResultAttendu>
                  </ActionTest>
                  <ActionTest id_action="Action_1106">
                    <Nom>A5</Nom>
                    <Description>Monitor the state for a period of time, e.g. 5 minutes, query that the state does not change.</Description>
                    <ResultAttendu>Confirm that the state does not change. Implementation note - this would be by every second checking state, or if logging available which is not clear, then by reviewing the log.</ResultAttendu>
                  </ActionTest>
                  <ActionTest id_action="Action_1078">
                    <Nom>A6</Nom>
                    <Description>Robustness aspect repeat a number of times - suggested 50 times.\n\nNote 20 minutes warmup plus 5 minutes monitor + = ~ 0.5hr / run , so 50 times = &gt;1 day</Description>
                    <ResultAttendu>Consistent behaviour is observed for every repetition of the test.</ResultAttendu>
                  </ActionTest>
                </TestManuel>
              </Test>
.

=head2 XStudio .xml export/import format

Category id and folder id and things are set in the .xml
How would we get them right?
 
<?xml version="1.0" encoding="ISO-8859-1" ?>
<!--<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">-->
<testplans>
   <category id="2" name="Intune XAgent tcl test">
      <folder id="34" name="IntuneTest">
         <test id="1" name="Hello World - basic" priority="4" canonicalPath="" author="admin">
            <prerequisites><![CDATA[tcl installed on local agent]]></prerequisites>
            <description><![CDATA[Hello World - basic <br/>call to local tcl script and response]]></description>
            <testcase id="1" index="11" name="Hello world basic - 1" implemented="1" useDescAsTestplan="0">
               <steps>
                  <object type="root"><object type="step" description="Run the hello world script"><object type="parameters"></object><object type="checks"><object type="operator" operator="and"><object type="check" description="hello world is output"/></object></object></object></object>
               </steps>
               <description><![CDATA[]]></description>
            </testcase>
            <testcase id="2" index="5" name="HelloWorld_Basic" implemented="1" useDescAsTestplan="0">
               <steps>
                  <object type="root"></object>
               </steps>
               <description><![CDATA[perl tcl script<br/>NO SPACES in TEST NAME]]></description>
            </testcase>
         </test>
         <test id="2" name="HelloWorld_Basic" priority="6" canonicalPath="" author="admin">
            <prerequisites><![CDATA[]]></prerequisites>
            <description><![CDATA[]]></description>
            <testcase id="3" index="1" name="HelloWorld_Basic_T1" implemented="1" useDescAsTestplan="0">
               <steps>
                  <object type="root"></object>
               </steps>
               <description><![CDATA[]]></description>
            </testcase>
         </test>
      </folder>
   </category>
</testplans>

=cut

