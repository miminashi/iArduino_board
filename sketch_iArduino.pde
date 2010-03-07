//
// iArduino HEXBUG
//
// 2009/02/20
// miminashi
//

#include <Ethernet.h>

// Debug mode?
const int DEBUG = false;

// Pin setting for left motor
const int LeftMotorPin_0    = 8;
const int LeftMotorPin_1    = 9;
const int LeftMotorPin_PWM  = 3;

// Pin setting for right motor
const int RightMotorPin_0   = 4;
const int RightMotorPin_1   = 5;
const int RightMotorPin_PWM = 6;

// EthernetShield MAC Address
byte mac[] = {0x00, 0x05, 0xC2, 0x97, 0x23, 0xE4};

// EthernetShield IP Address
byte ip[] = {192, 168, 1, 2};

Server server(10050);

char charFromClient;
char strVal[5];
int charCount = 0;

int leftVal = 0;
int rightVal = 0;


/*
  Motor function
 
  - notation -
  The hardware's PWM dosen't work now, so each PWM sections
  in this function are commented.
  
 */
void driveMotor(const int motorPin_0, const int motorPin_1, const int motorPin_PWM, int value)
{
  if(value == 0)
  {
    // Stop motor
    digitalWrite(motorPin_0, LOW);
    digitalWrite(motorPin_1, LOW);
    //analogWrite(motorPin_PWM, 0);
  }
  else if(value > 0)
  {
    // Normal rotation
    digitalWrite(motorPin_0, HIGH);
    digitalWrite(motorPin_1, LOW);
    //analogWrite(motorPin_PWM, value);
  }
  else if(value < 0)
  {
    // Reverse rotation
    digitalWrite(motorPin_0, LOW);
    digitalWrite(motorPin_1, HIGH);
    //analogWrite(motorPin_PWM, value*-1);
  }
}

/*
  Setup function
 */
void setup() {
  pinMode(LeftMotorPin_0, OUTPUT);
  pinMode(LeftMotorPin_1, OUTPUT);
  
  pinMode(RightMotorPin_0, OUTPUT);
  pinMode(RightMotorPin_1, OUTPUT);

  if(DEBUG)
  {
    Serial.begin(9600);
  }
  Ethernet.begin(mac, ip);
  server.begin();
}

/*
  Main loop
 */
void loop() {
  leftVal = 0;
  rightVal = 0;
  driveMotor(LeftMotorPin_0, LeftMotorPin_1, LeftMotorPin_PWM, leftVal);
  driveMotor(RightMotorPin_0, RightMotorPin_1, RightMotorPin_PWM, rightVal);

  Client client = server.available();

  while(client.connected()) {
    driveMotor(LeftMotorPin_0, LeftMotorPin_1, LeftMotorPin_PWM, leftVal);
    driveMotor(RightMotorPin_0, RightMotorPin_1, RightMotorPin_PWM, rightVal);
    
    if(client.available()) {
      charFromClient = client.read();
      
      if(charFromClient == ' ')
      {
        // Get value for left motor
        strVal[charCount] = '\0';
        charCount = 0;
        leftVal = atoi((const char *)strVal);
        if(DEBUG)
        {
          Serial.println(leftVal, DEC);
        }
      }
      else if(charFromClient == '\r')
      {
        // Do nothing
      }
      else if(charFromClient == '\n')
      {
        // Get value for right motor
        strVal[charCount] = '\0';
        charCount = 0;
        rightVal = atoi((const char *)strVal);
        if(DEBUG)
        {
          Serial.println(rightVal, DEC);
          Serial.println("");
        }
      }
      else
      {
        if(charCount < 4)
        {
          strVal[charCount] = charFromClient;
          charCount++;
        }
        else
        {
          // If the string format is wrong,
          // clear socket buffer.
          client.flush();
          charCount = 0;
        }
      }
    }
  }
}

