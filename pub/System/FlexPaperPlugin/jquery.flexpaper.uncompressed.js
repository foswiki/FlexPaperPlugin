/**
 * global variables used by flexplayer
 */
var docViewer,
  onExternalLinkClicked = function() {},
  onProgress = function() {},
  onDocumentLoading = function() {},
  onCurrentPageChanged = function() {},
  onDocumentLoaded = function() {},
  onDocumentLoadedError = function() {};

function getDocViewer(){
  if(docViewer) {
    return docViewer;
  } 
    
  if(window.FlexPaperViewer) {
    return window.FlexPaperViewer;
  }
  
  if(document.FlexPaperViewer) {
    return document.FlexPaperViewer;
  }

  return null;
}

(function($) {
  var defaults = {
    Scale : 0.6, 
    ZoomTransition : "easeOut",
    ZoomTime : 0.5,
    ZoomInterval : 0.1,
    FitPageOnLoad : false,
    FitWidthOnLoad : true,
    PrintEnabled : true,
    FullScreenAsMaxWindow : false,
    ProgressiveLoading : true,
    
    PrintToolsVisible : true,
    ViewModeToolsVisible : true,
    ZoomToolsVisible : true,
    FullScreenVisible : true,
    NavToolsVisible : true,
    CursorToolsVisible : true,
    SearchToolsVisible : true,
    
    localeChain: "en_US",

    width: 800,
    height: 600
  };


  $(".jqFlexPaper:not(.jqFlexPaperInited)").livequery(function() {
    var $this = $(this),
      opts,
      viewer,
      id;

    $this.addClass("jqFlexPaperInited");

    opts = $.extend({}, defaults, $this.metadata());
    opts.SwfFile = escape(opts.source),


    viewer = foswiki.getPreference("FlexPaperPlugin.viewer");
    id = $this.attr("id");

    swfobject.embedSWF(
        viewer, 
        id,
        opts.width,
        opts.height,
        "9.0.0", 
        "", 
        opts, 
        {
          quality: "high",
          bgcolor: "#ffffff",
          allowscriptaccess: "sameDomain",
          allowfullscreen: "true"
        },
        {
          id: "FlexPaperViewer",
          name: "FlexPaperViewer"
        }
      );
      //swfobject.createCSS(id, "display:block;text-align:left;");
  });

})(jQuery);
