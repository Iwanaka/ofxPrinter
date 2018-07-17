#pragma once
#include "ofxImGui.h"
#include "ofMain.h"

#define IM_TEXT_SIZE 1000
#define ARRAYSIZE(_ARR)  ((int)(sizeof(_ARR)/sizeof(*_ARR)))

typedef struct OFX_PRINTER {

	string printerName = "default";
	string paperSize = "A4";
	ofVec4f margin = ofVec4f(100, 100, 100, 100);
	bool landscape = false;
	bool color = true;
	bool fitToPaper = true;

};


class ofxPrinter
{
public:
	ofxPrinter();
	~ofxPrinter();

	void ImGui(string name);

	void updatePrinterList();
	void simplePrintOut(string imageFilePath, string printerName);
	void printOut(string imageFilePath, OFX_PRINTER p);

	bool setPrintFilePath(string filePath);

	string getCurrentPrintFilePath();
	string getCurrentSelectPrinterName();
	string getCurrentSelectPaperSize();
	vector<string> getPrinterList();
	vector<string> getPrinterPaperSizes(string printerName);

private:

	void loadSettings();
	void saveSettings();

	string getSelectPrinterName();
	string getSelectPaperSizeName();

	vector<string> printerList;
	vector<vector<string>> paperSizes;
	int printerIndex;
	int paperIndex;

	string printFilePath;
	string logMessage;

	float inputMargin[4];
	bool inputLandscape, inputColor, inputFitToPaper;

};

