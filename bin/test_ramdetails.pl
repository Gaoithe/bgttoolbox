#!/usr/bin/perl

my $ramdetails = "RAM details: 
BankLabel  Capacity    MemoryType  Speed  TypeDetail  
           4294967296  0           1333   128         
           4294967296  0           1333   128   ";

my $ramtype=0;
my $mbmultiplier=1024*1024;


$ramdetails =~ s|(\d+)(\s+\d+\s+\d+\s+\d+\s+$)|$1/$mbmultiplier."MB   ".$2|gem;
print $ramdetails;

$ramdetails =~ s/(\d{1,2})(\s+\d+\s+\d+\s+$)/$ramtype$2/gm;   
$ramdetails =~ s/(\d+)(\s+\d+\s+$)/$1."MHz".$2/gem;

$ramdetails =~ m/(\d+)\s+$/gm;                                
$typedetail = $typedetails{$typedetail}; 

$ramdetails =~ s/\d+(\s+$)/$typedetail$1/gm;

print $ramdetails;



#Illegal division by zero at /home/james/bin/test_ramdetails.pl line 8.
#$ramdetails =~ s|(\d+)(\s+\d+\s+\d+\s+\d+\s+$)|$1/$mbmultiplier."MB   ".$2|ge;
