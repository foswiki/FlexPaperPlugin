# ---+ Extensions
# ---++ FlexPaperPlugin
# This is the configuration used by the <b>FlexPaperPlugin</b>.

# **STRING**
# Command to start the <code>pdf2swf</cmd> tool.
$Foswiki::cfg{FlexPaperPlugin}{Pdf2swfCmd} = 'pdf2swf -q -f -T 9 -t -s storeallcharacters %FILENAME|F% -o %OUTPUT|F%';

1;
