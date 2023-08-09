import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../main.dart';

class ShowPDF extends StatefulWidget {
  String filename;
  String fileURL;
  ShowPDF({Key? key,required this.filename,required this.fileURL}) : super(key: key);

  @override
  State<ShowPDF> createState() => _ShowPDFState(filename,fileURL);
}

class _ShowPDFState extends State<ShowPDF> {
  late GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();
  late PdfViewerController _pdfController;
  late int currentPageNo = 1;
  late PdfTextSearchResult _searchResult;
  bool snackbar = false;


  OverlayEntry? _overlayEntry;


  String filename,fileURL;
  _ShowPDFState( this.filename, this.fileURL);



  void _showContextMenu(
      BuildContext context, PdfTextSelectionChangedDetails details) {
    final OverlayState _overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalSelectedRegion!.center.dy - 55,
        left: details.globalSelectedRegion?.bottomLeft.dx,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Colors.black.withOpacity(0.5),
          ),
          child: TextButton(
            child: Text(
              'Copy',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: details.selectedText!));
              _pdfController.clearSelection();
            },
          ),
        ),
      ),
    );
    _overlayState.insert(_overlayEntry!);
  }

  @override
  void initState() {
    _pdfController = PdfViewerController();
    currentPageNo = _pdfController.pageNumber;
    _searchResult = PdfTextSearchResult();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: Text(filename),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    snackbar = false;
                  });
                  showAlertDialog();

                },
              ),
              Visibility(
                visible: _searchResult.hasResult,
                child: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchResult.clear();
                    });
                  },
                ),
              ),
              Visibility(
                visible: _searchResult.hasResult,
                child: IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _searchResult.previousInstance();
                  },
                ),
              ),
              Visibility(
                visible: _searchResult.hasResult,
                child: IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _searchResult.nextInstance();
                  },
                ),
              ),
              Visibility(
                visible: !_searchResult.hasResult,
                child: IconButton(
                    onPressed: () {
                      _pdfViewerStateKey.currentState!.openBookmarkView();
                    },
                    icon: Icon(Icons.bookmark)),
              ),
            ],
          ),
          body: Stack(
            children: [
              SfPdfViewer.network(
                fileURL,
                key: _pdfViewerStateKey,
                controller: _pdfController,
                canShowPageLoadingIndicator: true,
                canShowPasswordDialog: true,
                currentSearchTextHighlightColor: Colors.yellow.withOpacity(0.6),
                otherSearchTextHighlightColor: Colors.grey.withOpacity(0.6),
                onPageChanged: (PdfPageChangedDetails details) {
                  setState(() {
                    currentPageNo = details.newPageNumber;
                  });
                },
                onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                  if (details.selectedText == null && _overlayEntry != null) {
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                  } else if (details.selectedText != null &&
                      _overlayEntry == null) {
                    _showContextMenu(context, details);
                  }
                },
              ),
              Container(
                margin: EdgeInsets.all(8),
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Center(
                    child: Text(
                      '${currentPageNo} / ${_pdfController.pageCount}',
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ],
          ),
          bottomNavigationBar: Container(
            height: 70,
            color: Colors.black.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(onPressed: () {
                  _pdfController.firstPage();
                }, icon: Icon(Icons.first_page,color: Colors.white,),),
                IconButton(onPressed: () {
                  _pdfController.previousPage();
                }, icon: Icon(Icons.navigate_before,color: Colors.white,)),
                IconButton(
                  onPressed: () {
                    _pdfController.zoomLevel += 0.5;
                  },
                  icon: Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _pdfController.zoomLevel -= 0.5;
                  },
                  icon: Icon(
                    Icons.zoom_out,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _pdfController.nextPage();
                  },
                  icon: Icon(
                    Icons.navigate_next,
                    color: Colors.white,
                  ),
                ),
                IconButton(onPressed: () {
                  _pdfController.lastPage();
                }, icon: Icon(Icons.last_page,color: Colors.white,),),


              ],
            ),
          ),
        ));
  }
  showAlertDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog( // <-- SEE HERE
          title: const Text('Enter Search text'),
          content:  SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ),

                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _searchResult = _pdfController.searchText(_textController.text.trim(),);

                _searchResult.addListener(() {
                  if (_searchResult.hasResult) {
                    setState(() {});
                  }else if(_searchResult.isSearchCompleted){
                    if (!snackbar) {
                      setState(() {
                        snackbar = true;
                      });
                      snackbarKey.currentState!.showSnackBar(
                          SnackBar(content: Text('No Text Found')));
                    }
                  }
                });
                _textController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
