#include <IRremote.h>

// To support more than 5 receivers, remember to change the define
// IR_PARAMS_MAX in IRremoteInt.h as well.
#define RECEIVERS 2

IRrecv *irrecvs[RECEIVERS];

char* IR_dict[] = {"c952508a", "ef1f150a", "5b2f91b5", "989d243a", "cc36ff5f"};

int IR1_signal[6] = {0,0,0,0,0,0};
int IR2_signal[6] = {0,0,0,0,0,0};

bool paired = false;
int timeInst = 1;
long prevTime = 0;
decode_results results;

int positionInterval = 1000; // unit: ms

void setup()
{
  Serial.begin(9600);

  irrecvs[0] = new IRrecv(12); // Receiver #0: pin 2
  irrecvs[1] = new IRrecv(13); // Receiver #1: pin 3

  for (int i = 0; i < RECEIVERS; i++)
    irrecvs[i]->enableIRIn();

  prevTime = millis();
}

void loop() {
  
  if (millis()- prevTime < positionInterval){
    for (int i = 0; i < 2; i++)
    {
      if (irrecvs[i]->decode(&results))
      {
        //Serial.print("Receiver #");
        //Serial.print(i);
        //Serial.print(":");
        //Serial.println(results.value, HEX);
        
        String valueStr = String(results.value, HEX);
        //Serial.println(valueStr);
        paired = false;
        for (int dictidx = 0; dictidx < 5; dictidx ++){
          if (valueStr == IR_dict[dictidx]){
            paired = true;
            if (i == 0){
              IR1_signal[dictidx] = 1;
            }else if (i == 1){
              IR2_signal[dictidx] = 1;
            }
          }
        }
        if (paired == false){
          if (i == 0){
              IR1_signal[5] = 1;
            }else if (i == 1){
              IR2_signal[5] = 1;
          }
        }
        irrecvs[i]->resume();
      }
    }
  }else{
    
    Serial.print("Time: ");
    Serial.println(timeInst);
    for (int iridx = 0; iridx < 2; iridx++){
      Serial.print("Receiver ");
      Serial.print(iridx+1);
      Serial.print(" :[");
      for (int idx = 0; idx < 6; idx++){
        if (iridx == 0){
          Serial.print(IR1_signal[idx]);
        }else if (iridx == 1){
          Serial.print(IR2_signal[idx]);
        }
        Serial.print(" ,");
      }
      Serial.print("]  ");
    }
    Serial.println();
    Serial.println("=======================");
    
    timeInst = timeInst+1;
    prevTime = millis();

    for (int dictidx = 0; dictidx < 6; dictidx ++){
        IR1_signal[dictidx] = 0;
        IR2_signal[dictidx] = 0;
    }
  }
}