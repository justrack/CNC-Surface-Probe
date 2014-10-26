unsigned short clock;
unsigned short clock_lpv=1;
unsigned long data_bit;
unsigned long data_word;
unsigned long measurement;
unsigned int timeout_counter=0;
unsigned short bit_count;
unsigned char digit_05;
unsigned char digits[4];

void sendChar(unsigned char dataout){
      Delay_us(52);
      TXREG=dataout;
      while(TXSTA.TRMT);
      while(!TXSTA.TRMT);
}

unsigned int myADC(unsigned short pin){
      unsigned int adc_data;

      //Configure the ADC module: Select ADC input channel
      if (pin == 0){
         ADCON0 = ADCON0 & 0b10000011;            //CHS<4:0>: Analog Channel Select bits, 00000 = AN0
      }
      else if (pin == 1){
         ADCON0 = ADCON0 & 0b10000111;            //CHS<4:0>: Analog Channel Select bits, 00001 = AN1
         ADCON0 = ADCON0 | 0b00000100;
      }

      //4. Wait the required acquisition time
      Delay_10us();

      //5. Start conversion by setting the GO/DONE bit.
      ADCON0.GO_NOT_DONE=1;  //GO/DONE: A/D Conversion Status bit, 1 = A/D conversion cycle in progress. Setting this bit starts an A/D conversion cycle. This bit is automatically cleared by hardware when the A/D conversion has completed.

      //6. Wait for ADC conversion to complete by Polling the GO/DONE bit
      while(ADCON0.GO_NOT_DONE);

      //7. Read ADC Result.
      adc_data=ADRESH;

      return adc_data;
}

void main() {
     
     //Set Oscillator
     OSCCON=0x78; //01111000    //SPLLEN: Software PLL Enable bit,0 = 4x PLL is disabled
                               //IRCF<3:0>: Internal Oscillator Frequency Select bits,1111 = 16 MHz HF
                               //Unimplemented: Read as ‘0’
                               //SCS<1:0>: System Clock Select bits,00 = Clock determined by FOSC<2:0> in Configuration Word 1.
     
     //Set Digital port directions
     TRISA.TRISA0=1;               //TRISA: PORTA TRI-STATE REGISTER, all inputs
     TRISA.TRISA1=1;
     TRISA.TRISA2=1;
     TRISA.TRISA3=1;               //This bit is always ‘1’ as RA3 is an input only
     TRISA.TRISA4=0;
     TRISA.TRISA5=1;
     
     //Set Analog Pins
     ANSELA.ANSA0=1;              //ANSELA: PORTA ANALOG SELECT REGISTER: Pin 1 is analog
     ANSELA.ANSA1=1;
     ANSELA.ANSA2=0;
     ANSELA.ANSA4=0;
     
     //Set ADC config
     ADCON1.adcs0=0;           //ADCS<2:0>: A/D Conversion Clock Select bits
     ADCON1.adcs1=1;              //010 = FOSC/32
     ADCON1.adcs2=0;
     ADCON1.ADPREF0=0;         //ADPREF<1:0>: A/D Positive Voltage Reference Configuration bits
     ADCON1.ADPREF1=0;            //00 = VREF+ is connected to AVDD
     ADCON1.ADFM=0;            //ADFM: A/D Result Format Select bit, 0 = Left justified. Six Least Significant bits of ADRESL are set to ‘0’ when the conversion result is loaded.
     ADCON1.ADCS0=0;           //ADCS<2:0>: A/D Conversion Clock Select bits
     ADCON1.ADCS1=1;              //010 = FOSC/32
     ADCON1.ADCS2=0;
     ADCON1.ADPREF0=0;         //ADPREF<1:0>: A/D Positive Voltage Reference Configuration bits
     ADCON1.ADPREF1=0;            //00 = VREF+ is connected to AVDD

     ADCON0.ADON=1;           //ADON: ADC Enable bit, 1 = ADC is enabled
     
     //setup UART tx (ra4)
     SPBRGL=12;
     SPBRGH=0;
     TXSTA.BRGH=0;
     TXSTA.SYNC=0;
     BAUDCON.BRG16=0;
     APFCON.TXCKSEL=1;   //1 = TX/CK function is on RA4
     RCSTA.SPEN=1;
     TXSTA.TXEN=1;
     //setup UART rx (ra5)
     APFCON.RXDTSEL=1;   //1 = RX/DT function is on RA5
     RCSTA.CREN=1;
     
     ///////Pins
     //0 -> clock
     //1 -> data
     //2
     //3
     //4 -> UART Tx
     //5 -> UART Rx

     //Main Loop
     while(1){
          //reset counters and data
          bit_count=0;
          timeout_counter=0;
          data_word=0;
          data_bit=0;
          
          //wait for clock to go low
          while(myADC(0) > 33);
          
          //read in data
          while( bit_count < 24 && timeout_counter < 50 ){
            clock=(myADC(0) > 33);



            if(clock==1 && clock_lpv==0) {
              //read data bit
              data_bit=(myADC(1)> 33);


              //store data bit into word
              data_bit = data_bit << 24;
              data_word = data_word + data_bit ;
              data_word = data_word >> 1;

              //reset timeout counter
              timeout_counter=0;

              //increment bit counter
              bit_count++;


            }

            //increment timeout counter
            timeout_counter++;



            clock_lpv=clock;
          }
          if (bit_count==24){
                //extract measurement data from message (bits 0..19)
                measurement = data_word & 0b00000000000011111111111111111111;

                //Break integer in to decimal digits
                digit_05=measurement % 2;
                measurement=measurement/2;
                digits[0]=measurement/1000;
                measurement=measurement-1000*digits[0];
                digits[1]=measurement/100;
                measurement=measurement-100*digits[1];
                digits[2]=measurement/10;
                measurement=measurement-10*digits[2];
                digits[3]=measurement;

                //turn decimal digits to strings
                digits[0]+=0x30;
                digits[1]+=0x30;
                digits[2]+=0x30;
                digits[3]+=0x30;
                if (digit_05==1){
                  digit_05=0x35; //"5"
                }
                else {
                  digit_05=0x30; //"0"
                }
                

          }
          if(PIR1.RCIF){
            if(RCREG=='r'){
                //send data out UART
                sendChar(digits[0]);
                sendChar('.');
                sendChar(digits[1]);
                sendChar(digits[2]);
                sendChar(digits[3]);
                sendChar(digit_05);
                sendChar('\n');
            }
          }
          if(RCSTA.OERR){
            RCSTA.CREN=0;
            RCSTA.CREN=1;
          }
          
     }
}