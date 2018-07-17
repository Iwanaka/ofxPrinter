#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

	ofBackground(46, 51, 70);
	gui.setup();

}

//--------------------------------------------------------------
void ofApp::update(){
	
}

//--------------------------------------------------------------
void ofApp::draw(){

	ofSetColor(255);
	ofDrawBitmapString("please drop here a image file", 50, 50);
	ofDrawBitmapString("space key : print out", 50, 70);

	gui.begin();
	{
		printer.ImGui("host");
	}
	gui.end();

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

	if (key == ' ') {

		OFX_PRINTER p;
		p.printerName = "";// set a you will use printer name
		p.paperSize = "";// set a you will use paper size
		p.color = false;// "false" is Black-and-White 
		p.fitToPaper = false;// whether fit to paper size
		p.landscape = false;// "false" is vertical printing, "true" is horizontal printing
		p.margin = ofVec4f(50.f, 50.f, 50.f, 50.f);//margin size

		//print out
		if (filePath != "") printer.printOut(filePath, p);

	}

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

	for (int i = 0; i < dragInfo.files.size(); i++) {

		filePath = printer.setPrintFilePath(dragInfo.files[i]);

	}

}
