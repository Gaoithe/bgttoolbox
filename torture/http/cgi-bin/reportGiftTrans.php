<?

##
#  reportGiftTrans.php
# Script used by dev to make reports (in interim only) until 
#   report is agreed between accounts & everyone
#   and report is specified fully (in particular invoicing charges).
#
#  Copyright (C) 2004 Doolin Technologies
#
#  This scriptie is free software; you can redistribute it and/or modify it
#  under the same terms as php itself.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#  $Id: reportGiftTrans.php,v 1.1 2006-06-07 16:05:54 jamesc Exp $
#

#
# TBD: could be tidied more
#  comment top of every function
#  remove/tidy debug (debug quite useful though & this script may change)
#

# if want to run/debug from command line:
#../classes/globals.inc:define("DEBUG", $ini_array["database"]["debug"]);
#define("DEBUG", "1");
#$REMOTE_USER = "stella";
#include("../../classes/globalsDebug.inc");
#globalsDebug.inc is same as globals.inc just doesn't instantiate Authenticator class


# include the global definitions
include("../../classes/globals.inc");

$gift = new giftcard();
$havepartners = $gift->getPartners();
$havepartners[ALL." ".PARTNERS] = "all";

function printArray($array){
  if (is_array($array)) {
    while (list($key, $val) = each($array)) {
      echo "\tIndex:" . $key . "  ";
      dump_array($val);
      echo ")<BR>\n";
    }
  }
}

function printHtmlArray($page,$array){
  $p = new Ptag("class=error");
  if (is_array($array)) {
    while (list($key, $val) = each($array)) {
      $p->push("\tIndex:" . $key . "  ");
      $p->push(dump_array($val));
      $p->push(")<BR>\n");
    }
  }
  $page->push($p);
}

function ShowEntireArray($array,$root)
{
  foreach (array_keys($array) as $element)
  {
   $my_array=$array[$element];
   if(is_array($my_array))
   {
     ShowEntireArray($my_array,$root . "[" . $element . "]");
   }
   else
   {
     echo($root . "[" . $element . "]=" . $array[$element]);
   }
  }

  $ses_obj = serialize ($array);
  print $ses_obj;
}

function printWarning($page,$warning){
  $p = new Ptag("class=error");
  $p->push($warning);
  $page->push($p);
}

#printArray($havepartners);

# directly from giftcard.class
# I want to keep partner_id
function getTransList($merchid, $termid, $partnerid, $estart, $eend) {

    $now = time();  # current time in epoch seconds
    $thirty = 60*60*24*TRANSACTIONS_KEPT; # number of seconds in 30 days
    $diff = $now - $thirty;
    if(($diff > $estart) || SPEED_SEARCH==0) { # extensive search
        $table = "transactions_".COUNTRY;
    } else { # looking in small transactions table
        $table = "transactions";
    }

    print "\n<debug doing SQL query on table $table>\n";


    $dbh = new mopsDB();
    $dbh->connect_read_mgr();

    $SQL = "SELECT from_unixtime(tr.time) as date, p.name as partner, p.id as partner_id, 
      t.merchid, m.name as merchname, tr.termid, tr.loyalty as cardno, tr.serial, 
      tr.amount, ts.description as status, tt.type_name as transtype,
      tr.expiry as transtype_id
            FROM 
      $table tr, terminal t, giftcard_partners p, giftcard g,
      giftcard_transtype tt, trans_status ts, merchant m
       WHERE 
      tr.product like 'G%'
       AND
      tr.time >= $estart
       AND 
      tr.time < $eend
       AND
      tr.termid = t.termid
       AND
      tr.status = ts.status
       AND
      tr.expiry = tt.number
       AND
      tr.loyalty = g.card_no
       AND
      g.partner_id = p.id
       AND
      m.merchant = t.merchid";
       #"AND 
      #t.country = '".COUNTRY."'";
    if (isset($termid) && $termid != "") {
   $SQL .= " AND tr.termid = ".quote($termid);
    }
    if (isset($merchid) && $merchid != "") {
   $SQL .= " AND t.merchid = ".strtoupper(quote($merchid));
    }
    if (isset($partnerid) && $partnerid != "" && $partnerid != "all") {
   $SQL .= " AND p.id = ".quote($partnerid);
    }

    print "\n<debug SQL query " . ereg_replace("[<>]", "GREATLESS", $SQL)  . ">\n";

    $result = $dbh->execute($SQL);

    if($dbh->errorMsg()){
        return $dbh->errorMsg();
    }

    return $result;
}


#$transList = getAndSortTransactions($gift, "all", $estart, $eend);

# global array for transactions
# selects on transactions on live database take yeages!!! so try do one just once
$completeTransListCount = 0;
$completeTransList = array();

function getAndSortTransactions($gift, $partnerid, $estart, $eend){

  global $completeTransList,$completeTransListCount;
  global $havepartners;

  print "\n<debug getAndSortTransactions($partnerid)>\n";

  if ($completeTransListCount <= 0) {

    if ($httpCompleteTransList) {
      $completeTransList = $httpCompleteTransList;
      $completeTransListCount = $httpCompleteTransListCount;
    } else {

      # get the datA from database (could be SLOW!)
      #$merchid = "";
      #$termid = "";
      #$partnerid = "all";

      print "\n<debug do SQL query: gift-getTransList( , , all, $estart, $eend)>\n";

      # function getTransList($merchid, $termid, $partnerid, $estart, $eend) {
      $results = getTransList("", "", $partnerid, $estart, $eend);
      #$results = getTransList("", "", "all", $estart, $eend);
      #$results = $gift->getTransList("", "", "all", $estart, $eend);

      print "\n<debug SQL query result $results->_numOfRows rows>\n";

# would be nice to get partnerid back in results BUT 
# safer for now for me not to change giftcard.class (logical?) maybe.
# we can (and do) match partnersd on names and string compares :-7
# ... for now .... (maybe forever) (shh)

      do {

	$completeTransList[$completeTransListCount++] = 
	  array (
		 partner_id => $results->fields["partner_id"],
		 partner => $results->fields["partner"],
		 merchname => $results->fields["merchname"],
		 merchid => $results->fields["merchid"],
		 termid => $results->fields["termid"],
		 date => $results->fields["date"],
		 cardno => $results->fields["cardno"],
		 serial => $results->fields["serial"],
		 amount => $results->fields["amount"],
		 status => $results->fields["status"],
		 transtype => $results->fields["transtype"],
		 transtype_id => $results->fields["transtype_id"]
		 );

	if ($completeTransList[$completeTransListCount-1]["cardno"] == "9372261000102300") {
	  print "\n<debug have Jim's card here! " .
	    $completeTransList[$completeTransListCount-1]["cardno"] . "," . 
	      $completeTransList[$completeTransListCount-1]["transtype_id"] . "," . 
		$completeTransList[$completeTransListCount-1]["date"] . "," . 
		  $completeTransList[$completeTransListCount-1]["partner_id"] . "," . 
		    $completeTransList[$completeTransListCount-1]["merchname"] . "," . 
		      $completeTransList[$completeTransListCount-1]["amount"] . "," . 
			"completeTransList count is " . count($completeTransList) . " = $completeTransListCount>\n";
	}

      } while ($results->nextRow() );
      
      print "\n<debug completeTransList(Count|size) $completeTransListCount=" . 
	count($completeTransList) . ">\n";
      
    }

  }


  # if we have results (that we want to put in report)
  # copy into array (partner first, merchid second) for sorting

  $transListCount = 0;
  #$partnerListCount = 0;

  if ($completeTransListCount > 0) {

    $i = 0;

    while ($completeTransList[$i]){

      # $process = 0;
      # this process select is old code
      # now trans types selected when printing depending on report type
      $process = 1;

      # check on termid, merchid needed? I don\'t think so
      # check on partner needed? I think so.

      if ($process == 1 && ($partnerid == "all" || 
        $havepartners[$completeTransList[$i]["partner"]] == $partnerid) ) {

        #$partnerList[$partnerListCount++] = $completeTransList[$i]["partner"];

        # order here determines sorting
        # partner_id partner merchname merchid date then rest (don\'t care)

        # different report daily sorted

	$transList[$transListCount++] = 
	  array (
		 partner_id => $completeTransList[$i]["partner_id"],
		 partner => $completeTransList[$i]["partner"],
		 merchname => $completeTransList[$i]["merchname"],
		 merchid => $completeTransList[$i]["merchid"],
		 date => $completeTransList[$i]["date"],
		 termid => $completeTransList[$i]["termid"],
		 cardno => $completeTransList[$i]["cardno"],
		 serial => $completeTransList[$i]["serial"],
		 amount => $completeTransList[$i]["amount"],
		 status => $completeTransList[$i]["status"],
		 transtype => $completeTransList[$i]["transtype"],
		 transtype_id => $completeTransList[$i]["transtype_id"]
		 );
	
	if ($transList[$transListCount-1]["cardno"] == "9372261000102300") {
	  print "\n<debug have Jim's card here! " .
	    $transList[$transListCount-1]["cardno"] . "," . 
	      $transList[$transListCount-1]["transtype_id"] . "," . 
		$transList[$transListCount-1]["date"] . "," . 
		  $transList[$transListCount-1]["partner_id"] . "," . 
		    $transList[$transListCount-1]["merchname"] . "," . 
		      $transList[$transListCount-1]["amount"] . "," . 
			"transList count is " . count($transList) . " = $transListCount>\n";
	}
	
      } #else {

        #print "\n<p>   partner $i not matching";
        #print $completeTransList[$i]["partner"];
        #print " booger ";
        #print $havepartners[$completeTransList[$i]["partner"]];
        #print "\n   ";

      #} 

      $i++;
   
    }


    print "\n<debug processed $i out of $completeTransListCount, " . 
      "transList count is " . count($transList) . " = $transListCount>\n";

    #sort ( $partnerList );
    #$partnerList = array_unique($partnerList);

  }

  if ($transListCount > 0)
    sort ( $transList );
  #print_r($transList);

  print "\n<debug sorted transList" . 
      "transList count is " . count($transList) . " = $transListCount>\n";

  return $transList;
}


function printTransList($page,$transList){

  $i=0;

  # if we have results
  if ($transList[$i]) {

    # create a new header
    $h3 = new H3tag();
    $h3->push("Transaction List report");
    $page->push($h3);

    # make a large table
    $table = new TABLEtag($large_table);
    $total = 0;
    $num_trans = 0;

    $th1 = new THtag(array("width=10%"));
    $th1->push(DATE);
    $th2 = new THtag(array("width=10%"));
    $th2->push(PARTNER);
    $th3 = new THtag(array("width=10%"));
    $th3->push(MERCHANT);
    $th4= new THtag(array("width=10%"));
    $th4->push(TERMINAL);
    $th5 = new THtag(array("width=10%"));
    $th5->push(GIFTCARD);
    $th6 = new THtag(array("width=10%"));
    $th6->push(SERIAL);
    $th7 = new THtag(array("width=10%"));
    $th7->push(AMOUNT);
    $th8 = new THtag(array("width=10%"));
    $th8->push(STATUS);
    $th9 = new THtag(array("width=10%"));
    $th9->push(TYPE);
    $table->push_row($th1,$th2,$th3,$th4,$th5,$th6,$th7,
           $th8,$th9);

    #make entries in table AND add up totals
    while ($transList[$i]){

      $td1 = new TDtag(array("align=center"));
      $td1->push($transList[$i]["date"]);
      $td2 = new TDtag(array("align=center"));
      $td2->push($transList[$i]["partner"]);
      $td3 = new TDtag(array("align=center"));
      $td3->push($transList[$i]["merchid"]);
      $td4 = new TDtag(array("align=center"));
      $td4->push($transList[$i]["termid"]);
      $td5 = new TDtag(array("align=center"));
      $td5->push($transList[$i]["cardno"]);
      $td6 = new TDtag(array("align=center"));
      $td6->push($transList[$i]["serial"]);
      $td7 = new TDtag(array("align=center"));
      $td7->push($transList[$i]["amount"]);
      $td8 = new TDtag(array("align=center"));
      $td8->push($transList[$i]["status"]);
      $td9 = new TDtag(array("align=center"));
      #$td9->push($transList[$i]["transtype"] . $transList[$i]["transtype_id"]);
      $td9->push($transList[$i]["transtype"]);
      $total += $transList[$i]["amount"];
      $num_trans++; $i++;
      $table->push_row($td1,$td2,$td3,$td4,$td5,$td6,$td7,$td8,$td9);
    }

    $td1 = new TDtag(array("colspan=9"));
    $td1->push("<b>".TOTAL." ".TRANS.":</b> $num_trans");
    $table->push_row($td1);
    $td2 = new TDtag(array("colspan=9"));
    $td2->push("<b>".TOTAL." ".VALUE.":</b> $total");
    $table->push_row($td2);

    # push the table to the page
    $page->push($table);

  }

  if ($i == 0) {
    printWarning($page,NO_TRANS_FOUND);
  } 

}

function sci($x, $d=-1) {
   $min=($x<0)?"-":"";
   $x=abs($x); 
   $e=floor(($x!=0)?log10($x):0);
   $x*=pow(10,-$e);
   $fmt=($d>=0)?".".$d:"";
   $e=($e>=0)?"+".sprintf("%02d",$e):"-".sprintf("%02d",-$e);
   return sprintf("$min%".$fmt."fe%s",$x,$e);
}

function moneyPrint($cents) {
  $euros = $cents / 100.0;
  return sprintf("%7.2f",$euros);

  # -1000 / 100.0 = -9.99 :(
  # ? no, not true! :)
  #$euros = $cents / 100;
  #$change = $cents % 100;
  #return sprintf("%7d.%02d",$euros,$change);
}

function printPartnerInfoHeading($page,$gift,$partnerid){

    #$gift->getPartnerData($partnerid,$field);
    #printHtmlArray($page,$field);

    #$partnerdata = $gift->getPartnerData($partnerid,"name, product_id, address, email, phone, partner_text");
    #$partnerdata = $gift->getPartnerData($partnerid,"*");

    $partner[name] = $gift->getPartnerData($partnerid,"name");
    $partner[mopsproductid] = $gift->getPartnerData($partnerid,"product_id");
    $partner[address] = $gift->getPartnerData($partnerid,"address");
    $partner[email] = $gift->getPartnerData($partnerid,"email");
    $partner[phone] = $gift->getPartnerData($partnerid,"phone");
    $partner[text] = $gift->getPartnerData($partnerid,"partner_text");   

    # make a table for partner details
    $table = new TABLEtag($large_table);
    $td1 = new TDtag(array("align=left","width=30%"));
    $td1->push($partner[name]);
    $td1->push("<br>".$partner[address]);
    $tdblank = new TDtag(array("width=3%"));
    $tdblank->push(" ");
    $td2 = new TDtag(array("align=left","width=30%"));
    $td2->push("email: ".$partner[email]);
    $td2->push("<br>phone: ".$partner[phone]);
    $td3 = new TDtag(array("align=left","width=30%"));
    $td3->push("mops product id: ".$partner[mopsproductid]);
    $td3->push("<br>number: ".$partner[mopsproductid]);
    $td3->push("<br>account: "."TBD");
    $table->push_row($td1,$tdblank,$td2,$tdblank,$td3);
    # push the table to the page
    $page->push($table);
}

function printPartnerSalesReportDataList($page,$transList){
  global $showbalance;

    # make a large table
    $table = new TABLEtag($large_table);

    $th1 = new THtag(array("width=10%"));
    $th1->push(DATE);
    $th2 = new THtag(array("width=10%"));
    $th2->push(TYPE);
    $th3 = new THtag(array("width=10%"));
    $th3->push(GIFTCARD);
    $th4 = new THtag(array("width=10%"));
    $th4->push(AMOUNT);
    $table->push_row($th1,$th2,$th3,$th4);

    $totals[total] = 0;
    $totals[activatetotal] = 0;
    $totals[balancetotal] = 0;
    $totals[num_trans] = 0;

    $lastMerchant = 0;
    $merchtotal = 0;

    $i=0;
    #make entries in table AND add up totals
    while ($transList[$i]){

      if ($lastMerchant != $transList[$i]["merchid"]){

	$lastMerchant = $transList[$i]["merchid"];
	$merchtotal = 0;

        # need to get merchant info here - name, not id
        # We need to load up the data for this merchant, so create a new instance.
	$merchant = new merchant($lastMerchant);
        # Initialise all the member variables.
	$merchant->load();
        #$merchant->address1 address2 address3 address4 phone_area cust_no vat_no

	$table->push_row( "merchant number: ".$lastMerchant);
        #$table->push_row( $transList[$i][merchname] ."=". $merchant->name ." - ". $merchant->address1);
	$table->push_row( $merchant->name ." - ". $merchant->address1);

      }
      
      if ($showbalance || $transList[$i]["transtype"] != "balance") { 

	$td1 = new TDtag(array("align=right"));
        # pick out date poart of date, drop time
        #$td1->push($transList[$i]["date"]);
	$td1->push(substr($transList[$i]["date"],0,10));
	$td2 = new TDtag(array("align=center"));
        #$td2->push($transList[$i]["transtype"] . $transList[$i]["transtype_id"]);
	$td2->push($transList[$i]["transtype"]);
	$td3 = new TDtag(array("align=right"));
	$td3->push($transList[$i]["cardno"]);
	$td4 = new TDtag(array("align=right"));
	$td4->push(moneyPrint($transList[$i]["amount"]));
	$table->push_row($td1,$td2,$td3,$td4);

      }
      
      $totals[total] += $transList[$i]["amount"];
      $merchtotal += $transList[$i]["amount"];
      #should get&use typeid instead, 
      #now I have it but dare I use it? 0 = balance 1 = load 2 = redeem 3 = activate
      if ($transList[$i]["transtype"] == "activate") { 
	$totals[activatetotal] += $transList[$i]["amount"];
      }
      if ($transList[$i]["transtype"] == "balance") { 
	$totals[balancetotal]++;
      }
      $totals[num_trans]++; $i++;
      
      # awkward little check before maybe moving on to transactions of another merchant
      if (!$transList[$i] || $lastMerchant != $transList[$i]["merchid"]){
	$tdblank = new TDtag();
	$tdtot = new TDtag(array("align=right"));
	$tdtot->push("Merchant total:");
	$tdmoney = new TDtag(array("align=right"));
	$tdmoney->push(moneyPrint($merchtotal));
	$table->push_row($tdblank,$tdblank,$tdtot,$tdmoney);
      }
      
    }
  
  # push the table to the page
  $page->push($table);
  
  if ($i == 0) {
    printWarning($page,NO_TRANS_FOUND);
  }
  
  return $totals;
  
}

function printPartnerSalesReport($gift,$page,$transList,$partnername,$partnerid,$reportdate,$reporttype){
  # if showbalance not set do not show balance transactions
  global $showbalance;

  if ( (strcmp($reporttype,"redeem") == 0 ) ) {
    $weAreMakingARedeemReport = 1;
  }

  # create a new header
  $h2 = new H2tag();
  $h2->push("Partner $reporttype Report for $partnername");
  $page->push($h2);

  printWarning($page,
          "Rates are fixed in code at 0.08 euros per transaction" .
          " and 1% charge for activations.");

  if (!$showbalance && (strcmp($reporttype,"redeem") != 0 )) {
    printWarning($page,"Not showing balance transactions.");
  }

  $h3 = new H3tag("class=data");
  $h3->push("date: ".$reportdate);
  $page->push($h3);

  $partnernameLength = strlen($partnername);
  $i=0;

  # data split into partner and non partner
  if ($transList[$i]) {
    $transPartnerListCount = 0;
    $transNonPartnerListCount = 0;
    #$transPartnerList = $transList; # where $transList[*][merchname] == $partnername
    #$transNonPartnerList = $transList; # the rest
    $i=0;
    while ($transList[$i]){

      # The type of report we are doing decides what type of transactions we want to collect
      #sales report => activate, load_value and balance
      #redeem report => redeem
      #transtype_id: 0 = balance 1 = load 2 = redeem 3 = activate

      if (($reporttype == "sales" && 
          $transList[$i][transtype_id] != 2 && $transList[$i][transtype_id]<4) ||
         ($weAreMakingARedeemReport && $transList[$i][transtype_id] == 2)) {

        # strncmp partnername and merchant name gives closest match to partners
        # not perfect but I don\'t think there is a better way
        # (need direct relation between merchants and partners in database)
        # TBD investigate this, ask Kathryn, poke at database

        #if \($partnername == $transList[$i][merchname]\) \{

        if ( strncmp($partnername,$transList[$i][merchname],$partnernameLength) == 0) {
          $transPartnerList[$transPartnerListCount++] = $transList[$i];
        } else {
	  $transNonPartnerList[$transNonPartnerListCount++] = $transList[$i];
        }
      }

      $i++;
    }

    print "\n<debug processed transList for partner report\n" . 
      "transList count is $i = " . count($transList) . " = $transListCount>\n";
    print "\n<debug transPartnerList \n" . 
      "count is " . count($transPartnerList) . " = $transPartnerListCount>\n";
    print "\n<debug transNonPartnerList \n" . 
      "count is " . count($transNonPartnerList) . " = $transNonPartnerListCount>\n";

  }

  $i=0;

  # if we have results
  if ($transList[$i]) {

    printPartnerInfoHeading($page,$gift,$partnerid);

    $totals = printPartnerSalesReportDataList($page,$transPartnerList);

    #TBD: rounding up or down
    #round($var) == floor($var + 0.5) == ceil($var - 0.5)

    if ($totals[num_trans] > 0 ){
      # calcs in cents
      $transactionCharge = 8 * $totals[num_trans];
      $activationCharge = 0.01 * $totals[activatetotal];
      
      $table = new TABLEtag($large_table);
      
      $td1 = new TDtag();
      $td1->push("<b>".TOTAL." ".VALUE.":</b>");
      $td2 = new TDtag(array("align=right"));
      $td2->push("<b>".moneyPrint($totals[total])."</b>");
      $table->push_row($td1,$td2);
      
      $td1 = new TDtag();
      $td1->push("<b>".TOTAL." ".TRANS.":</b>");
      $td2 = new TDtag(array("align=right"));
      $td2->push("<b>".moneyPrint($transactionCharge)."</b>");
      $td3 = new TDtag();
      $td3->push("0.08 euro per transaction. ");
      $td3->push("$totals[num_trans] transactions, ");
      $td3->push("$totals[balancetotal] balance transactions. ");
      $table->push_row($td1,$td2,$td3);
      
      if ( ! $weAreMakingARedeemReport ) {

	$td1 = new TDtag();
	$td1->push("<b>Total Activation Value:</b> ".moneyPrint($totals[activatetotal]));
	$td2 = new TDtag(array("align=right"));
	$td2->push("<b>".moneyPrint($activationCharge)."</b>");
	$td3 = new TDtag();
	$td3->push("charged at 1%.");
	$table->push_row($td1,$td2,$td3);

      }
      
      $td1 = new TDtag();
      $td1->push("<b>net:</b>");
      $td2 = new TDtag(array("align=right"));
      $td2->push("<b>". moneyPrint($totals[total] - ($transactionCharge + $activationCharge)) ."</b>" );
      $table->push_row($td1,$td2);
      
      # push the table to the page
      $page->push($table);

    }

    #if \( $reporttype == "redeem" && $transNonPartnerList\) \{
    if ($transNonPartnerList[0]) {

      # create a new header
      $h2 = new H2tag();
      $h2->push("Non-partner $reporttype for $partnername");
      $page->push($h2);

      if ( $weAreMakingARedeemReport ) {

	printWarning($page,"Non-Partner redeems not implemented?".
		     "<br>They should be impossible for now.".
		     "<br>BUT merchant name and partner information may not always be presented correctly in database so this section may appear to catch these error cases.");
	
      }

      $totals = printPartnerSalesReportDataList($page,$transNonPartnerList);

      # calcs in cents
      # fixed at 90%
      $shareNonPartnerTotal = 0.9 * $totals[total]; 

      $table = new TABLEtag($large_table);

      $td1 = new TDtag();
      $td1->push("<b>Non-Partner total:</b>");
      $td2 = new TDtag(array("align=right"));
      $td2->push("<b>".moneyPrint($totals[total])."</b>");
      $td3 = new TDtag();
      $td3->push("$totals[num_trans] transactions, ");
      $td3->push("$totals[balancetotal] balance transactions. ");
      $table->push_row($td1,$td2,$td3);
      
      $td1 = new TDtag();
      $td1->push("<b>Non-Partner debit:</b>");
      $td2 = new TDtag(array("align=right"));
      $td2->push("<b>".moneyPrint($shareNonPartnerTotal)."</b>");
      $td3 = new TDtag();
      $td3->push("fixed at 90% of total.");
      $table->push_row($td1,$td2,$td3);
      
      # push the table to the page
      $page->push($table);

    } else {

      printWarning($page,"no transactions found for Non-Partner $reporttype - This is okay.");

    }

  }

}

function printPartnerGiftcardValues($page,$partnername,$partnerid){

    $dbh = new mopsDB();
    $dbh->connect_read_mgr();

    $SQL = "select sum(value) from giftcard where partner_id = $partnerid and status = 1";

    print "\n<debug SQL query " . ereg_replace("[<>]", "GREATLESS", $SQL)  . ">\n";

    $result = $dbh->execute($SQL);

    if($dbh->errorMsg()){
        return $dbh->errorMsg();
    }

    $p = new Ptag("class=data");
    $p->push("Giftcard total values for $partnername ($partnerid) is ");
    $totalvalue = $result->fields["sum(value)"];
    if (!$totalvalue) { $totalvalue = 0; }
    $p->push(moneyPrint($totalvalue));
    $page->push($p);

    #print "<debug giftcard total values $result $result->fields>";
    #printArray($result->fields);
    #printArray($result);

    #do {
    #  printArray($result->fields);
    #} while ($result->nextRow() );

    #ShowEntireArray($result,$unset);

    printWarning($page,"Giftcard total values include transactions outside time scope of this report.");

    return $result;
}

function PtagJavaScriptBegin($p){
  $p->push('<SCRIPT LANGUAGE="JavaScript">
<!--');
}

function PtagJavaScriptEnd($p){
  $p->push('// -->
</script>');
}

$d = new Date_Calc();
$beginOfPrevMonth = $d->beginOfPrevMonth($un,$un,$un,"%d/%m/%Y");
$endOfPrevMonth = $d->endOfPrevMonth($un,$un,$un,"%d/%m/%Y");
$beginOfThisMonth = $d->beginOfMonth($un,$un,"%d/%m/%Y");
$endOfThisMonthToday = $d->dateNow("%d/%m/%Y");

function magicoPartners($page,$array){
  global $beginOfPrevMonth, $endOfPrevMonth;
  global $beginOfThisMonth, $endOfThisMonthToday;

  #$havepartners[ALL." ".PARTNERS] = "all";

  if (is_array($array)) {
    $p = new Ptag("class=data");
    $plast = new Ptag("class=data");
    $pthis = new Ptag("class=data");
    PtagJavaScriptBegin(&$p);
    PtagJavaScriptBegin(&$plast);
    PtagJavaScriptBegin(&$pthis);

    $p->push('function magico() {');
    $plast->push('function magicoLastMonth() {');
    $pthis->push('function magicoThisMonth() {');
    
    $plast->push("    document.list.start.value=\"$beginOfPrevMonth\";");
    $plast->push("    document.list.end.value=\"$endOfPrevMonth\";");
    $plast->push("    document.list.submit();");

    $pthis->push("    document.list.start.value=\"$beginOfThisMonth\";");
    $pthis->push("    document.list.end.value=\"$endOfThisMonthToday\";");
    $pthis->push("    document.list.submit();");

    while (list($key, $val) = each($array)) {
      if ($val != "all" && $val != "111") {
        #$p->push("open window/tab reportGiftTrans.php?partnerid=$val&start=&end=");
        #[windowVar = ][window].open("URL", "windowName", ["windowFeatures"])
	$name = "Giftcard Partner report for $key";
	$url = "reportGiftTrans.php?partnerid=$val&start=$beginOfPrevMonth&end=$endOfPrevMonth";
        $p->push("    window$val = window.open(\"$url\", \"$name\");");
      }
    }

    $p->push('}');
    $plast->push('}');
    $pthis->push('}');
    PtagJavaScriptEnd(&$p);
    PtagJavaScriptEnd(&$plast);
    PtagJavaScriptEnd(&$pthis);

    $page->push($p);
    $page->push($plast);
    $page->push($pthis);
  }
}

$addToHtmlTitle = "";

if ($partnerid ) {

  while (list($partnername, $pid) = each($havepartners)) {
    # $doallreports)
    if ($pid == $partnerid) {
      $addToHtmlTitle = " for ".$partnername;
    }
  }
  reset($havepartners);

}

define( "GIFT_PARTNER_REPORT", "Giftcard Partner Report");
$htmlTitle = GIFT_PARTNER_REPORT.$addToHtmlTitle;

# Create a new page
$page = new HTMLPageclass($htmlTitle);

# Create a new title object
$title = new TITLETag();

# add title
$title->push($htmlTitle);

# push the title onto the page
$page->push($title);

# push the path to the style sheet to the page.
$page->push_css_link("../".CSS);

# Call the function to create the links for this page.
$links = create_links("../mops_main.php", "../chooseMerch.php?action=".GIFTDIR
                  ."reportGiftTrans.php%3F&title=".LIST_GIFT_TRANS);

if ($start || $end) {
    # Convert the start and end dates to unix timestamps
    $times =  dateConversion($start, $end);
    $estart = $times[0];
    $eend = $times[1];

    # We have an invalid date entry
    if(!$estart || !$eend){
      printWarning($page,INVALID_DATE);
      $page->push($links);
      # Draw the page.
      print $page->render();
      exit();
    }

    # 1st call does sql query, thereafter $httpCompleteTransList is set and used
    # that is when this optimisation works
    #getAndSortTransactions($gift, "", "", "all", $estart, $eend);
}

if (!$showbalance) {
  $showbalance = 0;
}

if (!$showgiftcardvalues){
  $showgiftcardvalues = 0;
}

print "\n<debug please ?>\n";

if (!$start || !$end || !$partnerid ) {

  if (!$start) {
    $start = $beginOfPrevMonth;
  }

  if (!$end) {
    $end = $endOfPrevMonth;
  }

  #$p = new Ptag("class=data");
  #$p->push("james test <a href=reportGiftTrans.php?partnerid=100&start=01/12/2003&end=31/01/2004&doallreports=1&showgiftcardvalues=1&balance=0>reportGiftTrans.php?partnerid=100&start=01/12/2003&end=31/01/2004&doallreports=1&showgiftcardvalues=1&balance=0</a>");
  #$page->push($p);

  # Create a form giving it the next page as an action parameter
  $form_attributes = array("name"   => "list",
			   "method" => "POST",
			   "action" => "reportGiftTrans.php");

  $form = new FORMtag($form_attributes);

  # Assign the attributes to the table object
  $table = new TABLEtag($medium_table);

  if ($httpCompleteTransList) {
    # \( must slashify parenthesis in comments for emacs c-mode and php-mode \)
    # \( also must slashify apostrophes \(\'\) in comments \)
    # but then what if report dates change? :\(
    #$completeTransList = $httpCompleteTransList;
    #$completeTransListCount = $httpCompleteTransListCount;
    $form->push( form_hidden("httpCompleteTransListCount","$httpCompleteTransListCount"));
    $form->push( form_hidden("httpCompleteTransList","$httpCompleteTransList"));
    $form->push( form_hidden("start", $start) );
    $form->push( "<br><b>start</b>: $start" );
    $form->push( form_hidden("end", $end) );
    $form->push( "<br><b>end</b>: $end" );
  } else {

    # Create a row for the start date entry
    $td1 = new TDtag(array("height" => "20"));
    $td2 = new TDtag(array("height" => "20"));
    $td1->push( START_DATE." (dd/mm/yyyy)" );
    $td2->push(  form_text("start", $start, 24, 24) );
    $table->push_row($td1, $td2);

    # Create a row for the end date entry
    $td1 = new TDtag(array("height" => "20"));
    $td2 = new TDtag(array("height" => "20"));
    $td1->push( END_DATE." (dd/mm/yyyy)" );
    $td2->push(  form_text("end", $end, 24, 24) );
    $table->push_row($td1, $td2);
  }

  # javascript for setting dates & getting reports
  magicoPartners($page,$havepartners);

  # create a row for a message on leaving the merchant/terminal field blank.
  $td1 = new TDtag(array("colspan=2"));
  $td1->push( "All merchants and terminals included" );
  $table->push_row($td1);

  # Create a row for the partner entry
  $td1 = new TDtag(array("height" => "20"));
  $td2 = new TDtag(array("height" => "20"));
  $td1->push( GIFTCARD." ".PARTNER );
  $td2->push(form_select("partnerid", $havepartners, "all"));
  #$td2->push(form_hidden("partnername", oh hassle $havepartners, "all"));
  $table->push_row($td1, $td2);

  $td1 = new TDtag(array("height" => "20"));
  $td2 = new TDtag(array("height" => "20"));
  $td1->push( "Show balance transactions?" );
  $td2->push( form_checkbox("showbalance", 1), html_b("Show Balance") );
  $table->push_row($td1, $td2);

  $td1 = new TDtag(array("height" => "20"));
  $td2 = new TDtag(array("height" => "20"));
  $td1->push( "Show totals of giftcard values in system?" );
  $td2->push( form_checkbox("showgiftcardvalues", 1), html_b("Show Giftcard values") );
  $table->push_row($td1, $td2);

  # Display a submit button
  $table->push_row("&nbsp;", form_submit("list",GET_LIST));
  $table->push_row("&nbsp;", 
		   form_button("lastMonth","last month","onClick='magicoLastMonth();'" ) 
		   );
  $table->push_row("&nbsp;", 
		   form_button("thisMonth","this month","onClick='magicoThisMonth();'" ) 
		   );

  $table->push_row("<hr>","<hr>");

  # el Magico javascript button
  #open lots of windows with reports for each different partner
  $table->push_row("&nbsp;", 
		   form_button("magicoButton",
			       "Make seperate report for all partners",
			       "onClick='magico();'" ) 
		   );

  # Append the table to the form
  $form->push($table);

  # push the form onto the page object
  $page->push($form);

# we have enough data to make the report
} else {

  print "\n<debug report dateConversion($start, $end)>\n";

  # Convert the start and end dates to unix timestamps
  $times =  dateConversion($start, $end);
  $estart = $times[0];
  $eend = $times[1];

  # We have an invalid date entry
  if(!$estart || !$eend){
    printWarning($page,INVALID_DATE);
    $page->push($links);
    # Draw the page.
    print $page->render();
    exit();
  }

  #$transList = getAndSortTransactions($gift, $merchid, $termid, $partnerid, $estart, $eend);
  #printTransList($page,$transList);
  #printHtmlArray($page,$partnerList);

  $reportdate = $start."-".$end;

  print "\n<debug report date $reportdate, $estart - $eend>\n";

  while (list($partnername, $pid) = each($havepartners)) {
    print "\n<debug report ( $pid = $partnerid ) ? $partnername ?>\n";
    if ($pid == $partnerid || $doallreports) {
      print "\n<debug making report $pid $partnername giftcard $showgiftcardvalues balance $showbalance>\n";
      $transList = getAndSortTransactions($gift, $partnerid, $estart, $eend);
      printPartnerSalesReport($gift,$page,$transList,$partnername,$partnerid,$reportdate,"sales");
      printPartnerSalesReport($gift,$page,$transList,$partnername,$partnerid,$reportdate,"redeem");
      
      if ($showgiftcardvalues){
	printPartnerGiftcardValues($page,$partnername,$partnerid);
      }
    }
  }
  reset($havepartners);

}

# Push the links onto the page
$page->push($links);

# Draw the page.
print $page->render();
?>

