module stepperform;
import qte5;
import std.stdio;
import std.string;
import core.thread;
import serial.device;
import std.conv;

extern (C) {
	void h_qrbCW(StepperForm* h,int N,bool sel) {        
		(*h).m_qrbCW(N,sel);
	}
	void h_qrbCCW(StepperForm* h,int N,bool sel) {       
		(*h).m_qrbCCW(N,sel);
	}
	void h_qrbStop(StepperForm* h,int N,bool sel) {        
		(*h).m_qrbStop(N,sel);
	}
	void h_qsbDelay(StepperForm* h,int N,int val){
		(*h).m_qrbValue(N,val);
	}
	void h_qpbClosePort(StepperForm* h){
		(*h).m_qpbClosePort();

	}
}


class StepperForm : QWidget
{
	private {
		QPushButton qpbClosePort;
		QVBoxLayout vMainLayout; //vL1,vL2,
		QHBoxLayout hL1,hL2,hL3,hL4;
		QLabel labelPort, labelDelay, labelVLevel;
		QLineEdit qlePort;
		QSpinBox qsbDelay, qsbVLevel;
		QRadioButton qrbCW,qrbCCW,qrbStop;
		//	QCheckBox qcbOnOff;
		SerialPort s_port;
		char[] buf;
		QAction act_CW,act_CCW,act_Stop, act_qsbDelay,act_qpbClosePort;
	}
	

	this()
	{
		super(this);
		setWindowTitle("Управление шаговым двигателем");
		resize(300,100);

		vMainLayout = new QVBoxLayout();
		qpbClosePort = new QPushButton(this);
		qpbClosePort.setText("Закрыть порт");
		qpbClosePort.setEnabled(false);

		hL1 = new QHBoxLayout();
		hL2 = new QHBoxLayout();
		hL3 = new QHBoxLayout();
		hL4 = new QHBoxLayout();

		
		labelPort = new QLabel(this);
		labelPort.setText("Порт:");
		labelDelay= new QLabel(this);
		labelDelay.setText("Задержка между шагами (мс)");

		qlePort = new QLineEdit(this);
		qlePort.setText("/dev/ttyUSB0");

		qsbDelay = new QSpinBox(this);
		qsbDelay.setMaximumWidth(100);
		qsbDelay.setMaximum(10000);
		qsbDelay.setMinimum(1);

		qrbCW = new QRadioButton(this);
		qrbCW.setText("CW");
		qrbCCW = new QRadioButton(this);
		qrbCCW.setText("CCW");
		qrbStop = new QRadioButton(this);
		qrbStop.setText("Stop");

		
		hL1.addWidget(labelPort).addWidget(qlePort).addWidget(qpbClosePort);
		hL2.addWidget(labelDelay).addWidget(qsbDelay);

		hL4.addWidget(qrbCW).addWidget(qrbCCW).addWidget(qrbStop);
		vMainLayout.addLayout(hL1).addLayout(hL2).addLayout(hL3).addLayout(hL4);
		setLayout(vMainLayout);

		act_CW = new QAction(this,&h_qrbCW,aThis);
		act_CCW = new QAction(this,&h_qrbCCW,aThis);
		act_Stop = new QAction(this,&h_qrbStop,aThis);
		act_qsbDelay = new QAction(this,&h_qsbDelay,aThis);
		act_qpbClosePort = new QAction(this,&h_qpbClosePort,aThis);

		connects(qrbCW,"toggled(bool)",act_CW,"Slot_v__A_N_b(bool)");
		connects(qrbCCW,"toggled(bool)",act_CCW,"Slot_v__A_N_b(bool)");
		connects(qrbStop,"toggled(bool)",act_Stop,"Slot_v__A_N_b(bool)");
		connects(qsbDelay,"valueChanged(int)",act_qsbDelay,"Slot_v__A_N_i(int)");
		connects(qpbClosePort,"clicked()",act_qpbClosePort,"Slot()");

		

	}

	/*
	 * Реакция прошивки МК на полученые команды.
	 * Команды могут идти одна за другой.
	 * !!! Чувствительны к регистру !!!
	 * "B"(латиница) Вращение против часовой стрелки
	 * "F" Врашение по часовой стрелки 
	 * "S" Стоп
	 * "D" Следующие символы до "\0" переводятся в число тип int и задаются в качестве задержки между шагами.
	 * 
	 */
	
	void portOpen(){ 
		if ((s_port is null)||(s_port.closed)) {
			s_port = new SerialPort(qlePort.text!string); 
			Thread.sleep(dur!("seconds")(2));
		}
		if ((s_port !is null)||(!s_port.closed))qpbClosePort.setEnabled(true);

		
	}

	void m_qpbClosePort(){
		s_port.close();
		if ((s_port is null)||(s_port.closed)) {
			qpbClosePort.setEnabled(false);
			qlePort.setEnabled = true;

		}
	}

	// при Изменении значения в qsbDelay меняем задержку между шагами и восстанавливаем действие.
	void m_qrbValue(int N,int val){
		try{
			portOpen();
			if ((s_port !is null)||(!s_port.closed)) qlePort.setEnabled = false; //Блокировка поля ввода если порт открыт
			string tmpstr;
			if (qrbCW.isChecked) {			
				tmpstr = "D"~to!string(val)~"\0"~"F";
				s_port.write(tmpstr);
			}

			if (qrbCCW.isChecked) {
				tmpstr = "D"~to!string(val)~"\0"~"B";
				s_port.write(tmpstr);
			}

			if (qrbStop.isChecked) {
				tmpstr = "D"~to!string(val)~"\0"~"S";
				s_port.write(tmpstr);
			}
		} catch (InvalidDeviceException e) {
			string ss = e.toString;
			msgbox("Произошла ошибка, проверьте параматры порта и подключение устройства \n"~ss,"Ошибка");
		}

	}

	// Крутим вперёд (По часовой)
	void m_qrbCW(int N,bool sel){
		try{
			portOpen();
			if ((s_port !is null)||(!s_port.closed)) qlePort.setEnabled = false; //Блокировка поля ввода если порт открыт
			if (qrbCW.isChecked) {
				string tmpstr;
				tmpstr = "D"~to!string(qsbDelay.value)~"\0"~"F";
				s_port.write(tmpstr);
			}
		} catch (InvalidDeviceException e) {
			string ss = e.toString;
			msgbox("Произошла ошибка, проверьте параматры порта и подключение устройства \n"~ss,"Ошибка");
		}
	}

	// Крутим назад (Против часовой)
	void m_qrbCCW(int N,bool sel){
		try{
			portOpen();
			if ((s_port !is null)||(!s_port.closed)) qlePort.setEnabled = false; //Блокировка поля ввода если порт открыт
			if (qrbCCW.isChecked) {
				string tmpstr;
				tmpstr = "D"~to!string(qsbDelay.value)~"\0"~"B";
				s_port.write(tmpstr);
			}
		} catch (InvalidDeviceException e) {
			string ss = e.toString;
			msgbox("Произошла ошибка, проверьте параматры порта и подключение устройства \n"~ss,"Ошибка");
		}
	}

	// Останавливаем (с отключением напряжения с обмоток)
	void m_qrbStop(int N,bool sel){
		try{
			portOpen();
			if ((s_port !is null)||(!s_port.closed)) qlePort.setEnabled = false; //Блокировка поля ввода если порт открыт
			if (qrbStop.isChecked) {
				s_port.write("S");
			}
		} catch (InvalidDeviceException e) {
			string ss = e.toString;
			msgbox("Произошла ошибка, проверьте параматры порта и подключение устройства \n"~ss,"Ошибка");
		}
	}

	
}

