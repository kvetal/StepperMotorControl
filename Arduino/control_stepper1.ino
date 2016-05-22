int  counter = 0;
byte ch = 0;
const int motorPin1 = 6;
const int motorPin2 = 9;
const int motorPin3 = 10;
const int motorPin4 = 11;
int motorDelay = 5;
const int vlevel = 200; // voltage level
const int CpR = 4;   //cycle per Rotation
const int buttonPin1 = 2;
const int buttonPin2 = 3;
int buttonState1 = 0;
int buttonState2 = 0;
char mdelay[100];
bool status = false, direction = true;

void setup() {
  pinMode(motorPin1, OUTPUT);
  pinMode(motorPin2, OUTPUT);
  pinMode(motorPin3, OUTPUT);
  pinMode(motorPin4, OUTPUT);
  pinMode(buttonPin1, INPUT);
  pinMode(buttonPin2, INPUT);
  Serial.begin(9600);
}


void loop() {

  if (Serial.available() > 0) {
    delay(50);

    ch = Serial.read();
  }

  switch (ch) {
    case 'F': forward();
      break;
    case 'B': backward();
      break;
    case 'S': motor_stop();
      break;
    case 'D': {
        ch = Serial.read();
        while (ch != '\0') {
          mdelay[counter] = ch;
          ch = Serial.read();
          counter++;
        }
        mdelay[counter] = '\0';
        counter = 0;
        motorDelay = atoi(mdelay);
      }
      break;
  }


//---------------------Обработка нажатий кнопок -----------------
  buttonState1 = digitalRead(buttonPin1);
  buttonState2 = digitalRead(buttonPin2);
  if (buttonState1 == HIGH)
  {
    ch = 0;
    forward();
  }
  if (buttonState2 == HIGH)
  {
    ch = 0;
    backward();
  }
  if ((buttonState1 != HIGH) && (buttonState2 != HIGH))
    motor_stop();
}


//---------------------Вращение вперёд ----------------------------
void forward() {
  for (int i = 0; i <= CpR - 1; i++) {
    m_step1();
    delay(motorDelay);
    m_step2();
    delay(motorDelay);
    m_step3();
    delay(motorDelay);
    m_step4();
    delay(motorDelay);
  }
}


//---------------------Вращение назад ----------------------------
void backward() {
  for (int i = 0; i <= CpR - 1; i++) {
    m_step4();
    delay(motorDelay);
    m_step3();
    delay(motorDelay);
    m_step2();
    delay(motorDelay);
    m_step1();
    delay(motorDelay);
  }
}



void steps(int st, int s_delay) {
  switch (st) {
    case 1: m_step1();
      delay(s_delay);
      break;
    case 2: m_step2();
      delay(s_delay);
      break;
    case 3: m_step3();
      delay(s_delay);
      break;
    case 4: m_step4();
      delay(s_delay);
      break;
  }

}


//-------------------- Отключение мотора ---------------
void motor_stop() {
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, LOW);
  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, LOW);
}



//----------------------Шаг 1 --------------------------
void m_step1() {
  digitalWrite(motorPin1, LOW); //step 1
  digitalWrite(motorPin2, LOW);
  digitalWrite(motorPin3, HIGH);
  digitalWrite(motorPin4, HIGH);

  //  analogWrite(motorPin3, vlevel);
  //  analogWrite(motorPin4, vlevel);

}

//----------------------Шаг 2 --------------------------
void m_step2() {
  digitalWrite(motorPin1, HIGH); //step 2
  digitalWrite(motorPin2, LOW);
  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, HIGH);

  //  analogWrite(motorPin1, vlevel);
  //  analogWrite(motorPin4, vlevel);
}

//----------------------Шаг 3 --------------------------
void m_step3() {
  digitalWrite(motorPin1, HIGH); ////step 3
  digitalWrite(motorPin2, HIGH);
  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, LOW);

  //  analogWrite(motorPin1, vlevel);
  //  analogWrite(motorPin2, vlevel);
}


//----------------------Шаг 4 --------------------------
void m_step4() {
  digitalWrite(motorPin1, LOW); //step 4
  digitalWrite(motorPin2, HIGH);
  digitalWrite(motorPin3, HIGH);
  digitalWrite(motorPin4, LOW);

  //  analogWrite(motorPin2, vlevel);
  //  analogWrite(motorPin3, vlevel);

}





