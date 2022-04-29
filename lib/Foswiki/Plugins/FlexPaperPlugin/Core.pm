# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# FlexPaperPlugin is Copyright (C) 2010-2012 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::FlexPaperPlugin::Core;

use strict;
use warnings;

=begin TML

---+ package FlexPaperPlugin::Core

=cut

use Foswiki::Func ();
use Foswiki::Sandbox ();
use Foswiki::Plugins::JQueryPlugin::Plugins ();

our $baseWeb;
our $baseTopic;
#our %cache;

use constant TRACE => 0; # toggle me

=begin TML

---++ writeDebug($message(

prints a debug message to STDERR when this module is in TRACE mode

=cut

sub writeDebug {
  print STDERR "FlexPaperPlugin::Core - $_[0]\n" if TRACE;
}

=begin TML

---++ init($baseWeb, $baseTopic)

initializer for the plugin core; called before any macro hanlder is executed

=cut

sub init {
  ($baseWeb, $baseTopic) = @_;

  Foswiki::Func::addToZone("script", "SWFOBJECT",
    "<script src='%PUBURLPATH%/%SYSTEMWEB%/FlexPaperPlugin/swfobject.js'></script>"
  );
  Foswiki::Func::addToZone("script", "FLEXPAPER::META",
    "<meta name='foswiki.FlexPaperPlugin.viewer' content='%ENCODE{\"%PUBURL%/%SYSTEMWEB%/FlexPaperPlugin/FlexPaperViewer.swf\" type=\"html\"}%' />"
  );
  Foswiki::Func::addToZone("script", "FLEXPAPER::JS",
    "<script src='%PUBURLPATH%/%SYSTEMWEB%/FlexPaperPlugin/jquery.flexpaper.js'></script>",
    "SWFOBJECT, JQUERYPLUGIN::METADATA"
  );

  writeDebug("called init");
}

=begin TML

---++ FLEXPAPER($session, $params, $theTopic, $theWeb) -> $result

implementation of this macro

=cut

sub FLEXPAPER {
  my ($session, $params, $topic, $web) = @_;

  writeDebug("called FLEXPAPER()");

  my $theFileName = $params->{_DEFAULT}  || $params->{file};
  my $theTopic = $params->{topic} || $baseTopic;
  my $theWeb = $params->{web} || $baseWeb;
  my $theWidth = $params->{width} || "800";
  my $theHeight = $params->{height} || "600";
  my $theScale = $params->{scale} || "1.0";
  my $theLayout = $params->{layout} || "fitwidth";
  my $thePrintTools = $params->{printtools} || "on";
  my $theViewModeTools = $params->{viewmodetools} || "on";
  my $theZoomTools = $params->{zoomtools} || "on";
  my $theNavTools = $params->{navtools} || "on";
  my $theCursorTools = $params->{cursortools} || "on";
  my $theSearchTools = $params->{searchtools} || "on";
  my $theFullScreenTools = $params->{fullscreentools} || "on";
  my $theToolbar = $params->{toolbar} || "on";

  return '' unless $theFileName;

  my $fitPageOnLoad = "false";
  my $fitWidthOnLoad = "false";
  $fitPageOnLoad = "true" if $theLayout eq "fitpage";
  $fitWidthOnLoad = "true" if $theLayout eq "fitwidth";

  $thePrintTools = ($thePrintTools eq "on")?"true":"false";
  $theViewModeTools = ($theViewModeTools eq "on")?"true":"false";
  $theZoomTools = ($theZoomTools eq "on")?"true":"false";
  $theNavTools = ($theNavTools eq "on")?"true":"false";
  $theCursorTools = ($theCursorTools eq "on")?"true":"false";
  $theSearchTools = ($theSearchTools eq "on")?"true":"false";
  $theFullScreenTools = ($theFullScreenTools eq "on")?"true":"false";

  if ($theToolbar eq "off") {
    $thePrintTools = "false";
    $theViewModeTools = "false";
    $theZoomTools = "false";
    $theNavTools = "false";
    $theCursorTools = "false";
    $theSearchTools = "false";
    $theFullScreenTools = "false";
  } elsif ($theToolbar eq "on") {
    $thePrintTools = "true";
    $theViewModeTools = "true";
    $theZoomTools = "true";
    $theNavTools = "true";
    $theCursorTools = "true";
    $theSearchTools = "true";
    $theFullScreenTools = "true";
  }

  ($theWeb, $theTopic) = Foswiki::Func::normalizeWebTopicName($theWeb, $theTopic);

  return inlineError("$theFileName not found at $theWeb.$theTopic")
    unless Foswiki::Func::attachmentExists($theWeb, $theTopic, $theFileName);

  my $fileExt = '';
  my $fileBase = '';
  if ($theFileName =~ /^(.*)\.(pdf)$/) {
    $fileBase = $1;
    $fileExt = $2;
  } else {
    return inlineError("unsupported fileformat");
  }

  return inlineError("unsupported fileformat")
    unless $fileExt =~ /^(pdf)$/;

  my $origFile = $Foswiki::cfg{PubDir}."/".$theWeb."/".$theTopic."/".$theFileName;

  return inlineError("$theFileName not found at $theWeb.$theTopic even though the store says so")
    unless -f $origFile;

  my $swfFile = $Foswiki::cfg{PubDir}."/".$theWeb."/".$theTopic."/_flexpaper_".$fileBase.".swf";

  my $origModified = modificationTime($origFile);
  my $cachedModified = modificationTime($swfFile);

  writeDebug("origFile=$origFile, origModified=$origModified, swfFile=$swfFile, cachedModified=$cachedModified");

  if ($origModified > $cachedModified) {
    writeDebug("generating new swf for $theFileName at $swfFile");
    my $pdf2swfCmd = $Foswiki::cfg{FlexPaperPlugin}{Pdf2swfCmd} || 'pdf2swf -q -f -T 9 -t -s storeallcharacters %FILENAME|F% -o %OUTPUT|F%';
    my ($output, $exit) = Foswiki::Sandbox->sysCommand(
      $pdf2swfCmd,
      FILENAME => $origFile,
      OUTPUT => $swfFile
    );

    #writeDebug("output=$output, exit=$exit");

    return inlineError("can't create preview: $output") if $exit;
    return inlineError("can't create preview") unless -f $swfFile;

  } else {
    writeDebug("found up-to-date swf for $theFileName");
  }

  my $langTag = $session->i18n->language();
  my $locale;
  if ($langTag =~ /^en[-_]?/i) {
    $locale = "en_US";
  } elsif ($langTag =~/^fr[-_]?/i) {
    $locale = "fr_FR";
  } elsif ($langTag =~/^zh[-_]?/i) {
    $locale = "zh_CN";
  } elsif ($langTag =~/^es[-_]?/i) {
    $locale = "es_ES";
  } elsif ($langTag =~/^pt[-_]br?/i) {
    $locale = "pt_BR";
  } elsif ($langTag =~/^pt[-_]ot?/i) {
    $locale = "pt_PT";
  } elsif ($langTag =~/^ru[-_]?/i) {
    $locale = "ru_RU";
  } elsif ($langTag =~/^fi[-_]?/i) {
    $locale = "fi_FN";
  } elsif ($langTag =~/^de[-_]?/i) {
    $locale = "de_DE";
  } elsif ($langTag =~/^nl[-_]?/i) {
    $locale = "nl_NL";
  } elsif ($langTag =~/^tr[-_]?/i) {
    $locale = "tr_TR";
  } elsif ($langTag =~/^se[-_]?/i) {
    $locale = "se_SE";
  } elsif ($langTag =~/^el[-_]?/i) {
    $locale = "el_EL";
  } elsif ($langTag =~/^da[-_]?/i) {
    $locale = "da_DN";
  } elsif ($langTag =~/^cz[-_]?/i) {
    $locale = "cz_CS";
  } elsif ($langTag =~/^it[-_]?/i) {
    $locale = "it_IT";
  } elsif ($langTag =~/^pl[-_]?/i) {
    $locale = "pl_PL";
  } elsif ($langTag =~/^pv[-_]?/i) {
    $locale = "pv_FN";
  } elsif ($langTag =~/^hu[-_]?/i) {
    $locale = "hu_HU";
  }

  my $id = "flexPaper".Foswiki::Plugins::JQueryPlugin::Plugins::getRandom();
  my $swfUrl = $Foswiki::cfg{PubUrlPath}."/".$theWeb."/".$theTopic."/_flexpaper_".$fileBase.".swf?t=".time();
  my $result = "<noautolink><div id='$id' class='jqFlexPaper {".
    "source:\"$swfUrl\", ".
    "width:\"$theWidth\", ".
    "height:\"$theHeight\", ".
    "Scale:\"$theScale\", ".
    "FitPageOnLoad:$fitPageOnLoad, ".
    "FitWidthOnLoad:$fitWidthOnLoad, ".
    "PrintToolsVisible:$thePrintTools, ".
    "ViewModeToolsVisible:$theViewModeTools, ".
    "ZoomToolsVisible:$theZoomTools, ".
    "FullScreenVisible:$theFullScreenTools, ".
    "NavToolsVisible:$theNavTools, ".
    "CursorToolsVisible:$theCursorTools, ".
    "SearchToolsVisible:$theSearchTools, ".
    "localeChain:\"$locale\"".
    "}'></div></noautolink>";
  				  

  return $result;
}

=begub TML

---++ modificationTime($fileName) -> $timestamp

=cut

sub modificationTime {
  my $filename = shift;

  my @stat = stat($filename);
  return $stat[9] || $stat[10] || 0;
}

=begin TML

---++ inlineError($string) -> $errorMsg

returns an error string to be displayed inline

=cut

sub inlineError {
  return "<span class='foswikiAlert'>Error: ".$_[0]."</span>";
}


1;
