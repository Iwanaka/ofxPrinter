#pragma once

#include "ofMain.h"
#include "ofxPrinter.h"
#include "ofxImGui.h"

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyReleased(int key);
;
		void dragEvent(ofDragInfo dragInfo);

		

		ofxPrinter printer;
		string filePath = "";

		ofxImGui::Gui gui;
};
