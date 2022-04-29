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

package Foswiki::Plugins::FlexPaperPlugin;

use strict;
use warnings;

=begin TML

---+ package FlexPaperPlugin

=cut

use Foswiki::Func ();

our $VERSION = '2.10';
our $RELEASE = '29 Apr 2022';
our $SHORTDESCRIPTION = 'flash-based document viewer component';
our $NO_PREFS_IN_TOPIC = 1;
our $baseWeb;
our $baseTopic;
our $doneInit;


=begin TML

---++ initPlugin($topic, $web, $user) -> $boolean

=cut

sub initPlugin {
  ($baseTopic, $baseWeb) = @_;

  Foswiki::Func::registerTagHandler('FLEXPAPER', \&FLEXPAPER);
  Foswiki::Func::registerTagHandler('FLEXPAPERINIT', \&FLEXPAPERINIT);

  $doneInit = 0;
  return 1;
}

=begin TML

---++ init()

=cut

sub init {
  return if $doneInit;

  $doneInit = 1;

  require Foswiki::Plugins::FlexPaperPlugin::Core;
  Foswiki::Plugins::FlexPaperPlugin::Core::init($baseWeb, $baseTopic);
}

=begin TML

---+ FLEXPAPER($session, $params, $theTopic, $theWeb) -> $string

stub for FLEXPAPER to initiate the core before handling the macro

=cut

sub FLEXPAPER {
  init();
  return Foswiki::Plugins::FlexPaperPlugin::Core::FLEXPAPER(@_);
}

=begin TML

---+ FLEXPAPERINIT()

just triggers the init of the core

=cut

sub FLEXPAPERINIT {
  init();
  return "";
}

1;
