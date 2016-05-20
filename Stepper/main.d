module main;


import qte5;
import std.stdio;
import core.runtime;
import stepperform;

int main(){


	bool fDebug = true;
	if (1 == LoadQt(dll.QtE5Widgets,fDebug)) return 1;
	QApplication app = new QApplication(&Runtime.cArgs.argc, Runtime.cArgs.argv,1);
	StepperForm f1 = new StepperForm();
	f1.saveThis(&f1);
	f1.show();
	app.exec();
//	scope(exit) f1.s_port.close();
	return 0;

}
