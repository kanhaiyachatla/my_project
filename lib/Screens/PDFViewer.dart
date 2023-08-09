import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../main.dart';

class PDFViewer extends StatefulWidget {
  var submission_data;
  String class_id,assign_id;
  PDFViewer({Key? key, required this.submission_data,required this.assign_id,required this.class_id}) : super(key: key);

  @override
  State<PDFViewer> createState() => _PDFViewerState(submission_data,assign_id,class_id);
}

class _PDFViewerState extends State<PDFViewer> {
  var submission_data;
  String assign_id,class_id;




  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();
  late PdfViewerController _pdfController;
  late int currentPageNo = 1;
  late PdfTextSearchResult _searchResult;
  bool snackbar = false;
  final TextEditingController _controller = TextEditingController();
  final FormKey = GlobalKey<FormState>();




  OverlayEntry? _overlayEntry;
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
            child: const Text(
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
  }

  _PDFViewerState(this.submission_data,this.assign_id,this.class_id);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(submission_data['file_name']),
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
                icon: const Icon(Icons.bookmark)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            submission_data['url'],
            key: _pdfViewerStateKey,
            scrollDirection: PdfScrollDirection.horizontal,
            controller: _pdfController,
            pageLayoutMode: PdfPageLayoutMode.single,
            canShowScrollHead: false,
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
            margin: const EdgeInsets.all(8),
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
                child: Text(
              '${currentPageNo} / ${_pdfController.pageCount}',
              style: const TextStyle(color: Colors.white),
            )),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        if (submission_data['marks'] !=
            null) {
          snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Marks already assigned for ${submission_data['name']}')));
        } else {
          DisplayBottomSheet(
              submission_data);
        }

      }, label: const Text('Assign Marks'),backgroundColor: Theme.of(context).colorScheme.primary,),
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.black.withOpacity(0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: () {
              _pdfController.firstPage();
            }, icon: const Icon(Icons.first_page,color: Colors.white,),),
            IconButton(
              onPressed: () {
                _pdfController.previousPage();
              },
              icon: const Icon(
                Icons.navigate_before,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                _pdfController.zoomLevel += 0.5;
              },
              icon: const Icon(
                Icons.zoom_in,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                _pdfController.zoomLevel -= 0.5;
              },
              icon: const Icon(
                Icons.zoom_out,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                _pdfController.nextPage();
              },
              icon: const Icon(
                Icons.navigate_next,
                color: Colors.white,
              ),
            ),
            IconButton(onPressed: () {
              _pdfController.lastPage();
            }, icon: const Icon(Icons.last_page,color: Colors.white,),),


          ],
        ),
      ),
    ));
  }

  Future DisplayBottomSheet(Map<String,dynamic> data) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        builder: (context) {
          return Padding(
              padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter marks for ${data['name']}',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Form(
                    key: FormKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: false,signed: false),
                        maxLines: 1,
                        validator: (value) {
                          if(value!.isEmpty) {
                            return 'Enter marks';
                          }else if(int.parse(value) > 10){
                            return 'Enter a value between 0 to 10';
                          }else{
                            return null;
                          }
                        },
                        controller: _controller,
                        decoration: InputDecoration(
                          label: const Text('Enter Marks..'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),

                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green
                            ),
                              onPressed: () async {
                                if(FormKey.currentState!.validate()){
                                  await FirebaseFirestore.instance.collection('Classes').doc(class_id).collection('Assignments').doc(assign_id).collection('Submission').doc(submission_data['id']).update({
                                    'marks' : _controller.text.trim().toString()
                                  });
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  snackbarKey.currentState!.showSnackBar(const SnackBar(content: Text('Marks assigned')));
                                }
                              },
                              child: const Text('confirm marks'))),
                    ],
                  ),
                ],
              ),
            ),
          ));
        });
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
                            const SnackBar(content: Text('No Text Found')));
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
