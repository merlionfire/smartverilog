#!/usr/bin/perl -w 

#---------------------------------------------------------------------------------
# FILE         : SmartVerilog
# DESCRIPTION  : This is a tool to instatiate verilog modules from several files.   
# AUTHOR       : Merlionfire 
# Created      : June-08-2014
#---------------------------------------------------------------------------------

use strict ; 

#---------------------------------------------------------------------------------
#  Usage 
#---------------------------------------------------------------------------------
my $script = $0 ; 
my $usage = " 
USAGE: $0 <verilog.v> 

"; 

#---------------------------------------------------------------------------------
#  Global vars
#---------------------------------------------------------------------------------
my $tab  = "   ";
my $tab2 = $tab x 2 ; 
my $module_name;
my @ports;
my $max_len_port_name = 0 ; 
my @wires ; 
my @m_wires ; 

#---------------------------------------------------------------------------------
#  Main
#---------------------------------------------------------------------------------
die $usage if @ARGV == 0 ; 

while (<>) {
  # catch module interface   
  if ( /^\s*module/ .. /;/ ) {                                 
     $module_name = $1  if /\bmodule\b\s+(\w+)/ ;   # catch module name  
     # Catch: 
     #   input    clk ,
     #   output   enb ,
     #   input [ N : 0 ] data ,
     #   inout    di   
     if ( /(input|output|inout)\s*(reg|wire| )\s*(\[.*]| )\s+(\w+).*,?/ ) {    
        push @ports ,  "$1#$3#$4" ;  
        $max_len_port_name = length($4) if $max_len_port_name < length($4) ; 
     }
  # catch the end of verilog file and print  
  } elsif ( /endmodule/ ) {   
     print_inst ( @ports ) ;  
     gen_wires ( @ports ) ; 
     @ports = () ; 
  }   
} 

print_wires ( ) ; 

exit;


#---------------------------------------------------------------------------------
#  Subroutine 
#     print_wires : print wire declarations   
#---------------------------------------------------------------------------------
sub print_wires {
   print "wire" ; 
   print "  $_,"  foreach @wires ; 
   print "\n\n" ; 
   print "wire [ : ] $_;\n" foreach @m_wires ;  
   print "\n" ; 
}    

#---------------------------------------------------------------------------------
#  Subroutine 
#    get_wires : analyze ports of module and add them into wire array @wires and 
#                m-width wires array @m_wires     
#---------------------------------------------------------------------------------
sub gen_wires {
   my @items ; 
   foreach (@_ ) { 
      @items = split /#/  ; 
      if ( $items[1] ne  " " ) {
         push @m_wires, "$items[2]" unless @m_wires ~~ /\b$items[2]\b/ ; 
      } elsif ( ! ( @wires ~~ /\b$items[2]\b/ ) ) { 
         push @wires, "$items[2]" ; 
      }
   }    
}   

#---------------------------------------------------------------------------------
#  Subroutine 
#    print_inst : print instantiation of module in the format like  
#                 <module_name> <module_name>_inst (  
#                    .port1  ( port1 ) //i      
#                    .portN  ( portN ) //o      
#                 )
#---------------------------------------------------------------------------------
sub print_inst { 
   my @items ; 
   my $n = @_ ; 
   print "$module_name  ${module_name}_inst (\n" ; 
   foreach ( @_ ) {
      my $n_tabs = 0 ; 
      my $add_tabs ; 
      @items = split /#/  ; 
      $n_tabs = $max_len_port_name - length($items[2]) ;  
      $add_tabs = " " x $n_tabs ; 
      print "   .$items[2]$add_tabs ( $items[2]$add_tabs )" ; 
      if (--$n) { print ", //" ;
      } else    { print "  //" ; }   
      print substr($items[0],0,1) . "\n" ;  
   }   
   print ");\n" ;
   print "\n" ; 
}
