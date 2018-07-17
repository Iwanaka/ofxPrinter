#include "ofxPrinter.h"

//--------------------------------------------------------------
ofxPrinter::ofxPrinter():
	printerList(0),
	printerIndex(0),
	logMessage(""),
	printFilePath(""),
	inputMargin{ 100, 100, 100, 100},
	inputLandscape(false),
	inputColor(true),
	inputFitToPaper(true)
{
	updatePrinterList();
	loadSettings();
}

//--------------------------------------------------------------
ofxPrinter::~ofxPrinter()
{
	saveSettings();
}

//--------------------------------------------------------------
void ofxPrinter::ImGui(string name) {

	ImGui::Begin(name.c_str());
	{

		ImGui::BulletText("[ log message ]");
		ImGui::Text(logMessage.c_str());
		
		
		ImGui::BulletText("[ printer list ]");

		if (ImGui::Button("  update printer list  ")) {

			updatePrinterList();
			loadSettings();

		}

		//list printer
		for (int i = 0; i < printerList.size(); i++) {

			ImGui::RadioButton(printerList[i].c_str(), &printerIndex, i);

		}		


		//list paper size
		ImGui::BulletText("paper size list");
		for (int i = 0; i < paperSizes.size(); i++) {

			if (printerIndex == i) {

				for (int k = 0; k < paperSizes[i].size(); k++) {

					ImGui::RadioButton(paperSizes[i][k].c_str(), &paperIndex, k);

					if (k + 1 == paperSizes[i].size()) {
						break;
					}
					if ((k + 1) % 4 != 0) ImGui::SameLine(((k + 1) % 4) * 200);

				}
			}
		}


		ImGui::BulletText("check option");
		ImGui::PushItemWidth(500);
		ImGui::InputFloat4("margin", inputMargin, 2);
		ImGui::PopItemWidth();
		ImGui::Checkbox("landscape", &inputLandscape); ImGui::SameLine(100);
		ImGui::Checkbox("color", &inputColor); ImGui::SameLine(200);
		ImGui::Checkbox("fit to paper", &inputFitToPaper);


		ImGui::BulletText("file path : %s" , printFilePath.c_str());

		if (ImGui::Button("  printOut  ")) {
			
			string printerName = getSelectPrinterName();
			string paperSize = getSelectPaperSizeName();


			OFX_PRINTER p;
			p.paperSize = paperSize;
			p.printerName = printerName;
			p.margin = ofVec4f(inputMargin[0], inputMargin[1], inputMargin[2], inputMargin[3]);
			p.landscape = inputLandscape;
			p.color = inputColor;
			p.fitToPaper = inputFitToPaper;


			printOut(printFilePath, p);

		}

	}
	ImGui::End();
}

//--------------------------------------------------------------
void ofxPrinter::updatePrinterList() {

	string temp = "@powershell -NoProfile -ExecutionPolicy unrestricted -Command \"./data/powershell/getPrinterList.ps1\" ";
	system(temp.c_str());

	logMessage = "update complete printer list";
}

//--------------------------------------------------------------
void ofxPrinter::simplePrintOut(string imageFilePath, string printerName) {

	if (!setPrintFilePath(imageFilePath)) {
		return;
	}

	string temp = "@powershell -NoProfile -ExecutionPolicy unrestricted -Command \"./data/powershell/printOut.ps1 '" + printFilePath + "' '" + printerName + "' \"";
	system(temp.c_str());

	logMessage = "input file printed complete";

}

//--------------------------------------------------------------
void ofxPrinter::printOut(string imageFilePath, OFX_PRINTER p) {

	if (!setPrintFilePath(imageFilePath)) {
		return;
	}

	string temp = "@powershell -NoProfile -ExecutionPolicy unrestricted -Command \"./data/powershell/printOutSettingDetail.ps1";
	temp += " '" + printFilePath + "' ";
	temp += " '" + p.printerName + "' ";
	temp += " '" + p.paperSize + "' ";
	temp += " " + ofToString(p.margin.x) + " ";
	temp += " " + ofToString(p.margin.y) + " ";
	temp += " " + ofToString(p.margin.z) + " ";
	temp += " " + ofToString(p.margin.w) + " ";
	temp += " " + ofToString(p.landscape) + " ";
	temp += " " + ofToString(p.color) + " ";
	temp += " " + ofToString(p.fitToPaper) + " ";
	temp += " \"";
	
	cout << temp;

	system(temp.c_str());

	logMessage = "input file printed complete";

}

//--------------------------------------------------------------
bool ofxPrinter::setPrintFilePath(string filePath) {

	if (filePath.size() >= IM_TEXT_SIZE) {
		logMessage = "input path is over size for capacity";
		return false;
	}
	

	ofFile file(filePath);

	logMessage = "there is no file path : " + filePath;
	if (!file.exists()) return false;

	string imageExtention[8] = { "tif" ,"tiff" ,"jpeg" ,"jpg" ,"png" ,"gif" ,"bmp" ,"pict" };
	string extention = file.getExtension();

	bool match = false;
	for (int i = 0; i < ARRAYSIZE(imageExtention); i++) {

		if (imageExtention[i] == extention) {
			match = true;
			break;
		}
	}

	if (!match) {
		logMessage = "input file is not image file";
		return false;
	}

	printFilePath = filePath;
	
	return true;
}

//--------------------------------------------------------------
string ofxPrinter::getCurrentPrintFilePath() {

	return printFilePath;

}

//--------------------------------------------------------------
string ofxPrinter::getCurrentSelectPrinterName() {

	if (0 < printerList.size()) return printerList[printerIndex];
	return "";

}

//--------------------------------------------------------------
string ofxPrinter::getCurrentSelectPaperSize() {

	if (0 < printerList.size()) return paperSizes[printerIndex][paperIndex];
	return "";

}

//--------------------------------------------------------------
vector<string> ofxPrinter::getPrinterList() {

	return printerList;

}

//--------------------------------------------------------------
vector<string> ofxPrinter::getPrinterPaperSizes(string printerName) {

	for (int i = 0; i < printerList.size(); i++) {
		if (printerList[i] == printerName) {
			return paperSizes[i];
		}
	}

	vector<string> zero;
	return zero;
}


//--------------------------------------------------------------
string ofxPrinter::getSelectPrinterName() {

	if (printerList.size() > 0) return printerList[printerIndex];
	return "";

}

//--------------------------------------------------------------
string ofxPrinter::getSelectPaperSizeName() {
	
	if (paperSizes.size() > 0) return paperSizes[printerIndex][paperIndex];
	return false;

}

//--------------------------------------------------------------
void ofxPrinter::loadSettings() {

	ofFile file("../printerList.ini");

	logMessage = "printerList.ini load failed";

	if (!file.exists()) return;
	
	printerList.clear();
	paperSizes.clear();
	printerIndex = 0;
	paperIndex = 0;

	ofBuffer buf(file);

	int count = 0;
	for (ofBuffer::Line it = buf.getLines().begin(), end = buf.getLines().end(); it != end; it++) {

		string line = *it;

		if (line == "") continue;

		vector<string> firstSplit = ofSplitString(line, ":");
		if (3 <= firstSplit.size()) {

			//printer
			printerList.push_back(firstSplit[0]);
			if ("True" == firstSplit[1]) {
				//printer.printerName = firstSplit[1];
				printerIndex = count;
			}
			vector<string> secoundSplit = ofSplitString(firstSplit[2], ",");

			//paper
			vector<string> temp;
			for (int i = 0; i < secoundSplit.size();  i++) {
				temp.push_back(secoundSplit[i]);
			}
			paperSizes.push_back(temp);

		}
		count++;

	}

	logMessage = "printerList.ini load success!";

}

//--------------------------------------------------------------
void ofxPrinter::saveSettings() {

	//filebuf fb;
	//fb.open("selectPrinter.ini", std::ios::out);
	//std::ostream os(&fb);

	//os << index << "\n";

	//fb.close();

}

//--------------------------------------------------------------