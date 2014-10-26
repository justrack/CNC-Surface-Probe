#line 1 "C:/Users/Justin/Dropbox/Backup/NEW/dial indicator/dial-indicator.c"
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


 if (pin == 0){
 ADCON0 = ADCON0 & 0b10000011;
 }
 else if (pin == 1){
 ADCON0 = ADCON0 & 0b10000111;
 ADCON0 = ADCON0 | 0b00000100;
 }


 Delay_10us();


 ADCON0.GO_NOT_DONE=1;


 while(ADCON0.GO_NOT_DONE);


 adc_data=ADRESH;

 return adc_data;
}

void main() {


 OSCCON=0x78;





 TRISA.TRISA0=1;
 TRISA.TRISA1=1;
 TRISA.TRISA2=1;
 TRISA.TRISA3=1;
 TRISA.TRISA4=0;
 TRISA.TRISA5=1;


 ANSELA.ANSA0=1;
 ANSELA.ANSA1=1;
 ANSELA.ANSA2=0;
 ANSELA.ANSA4=0;


 ADCON1.adcs0=0;
 ADCON1.adcs1=1;
 ADCON1.adcs2=0;
 ADCON1.ADPREF0=0;
 ADCON1.ADPREF1=0;
 ADCON1.ADFM=0;
 ADCON1.ADCS0=0;
 ADCON1.ADCS1=1;
 ADCON1.ADCS2=0;
 ADCON1.ADPREF0=0;
 ADCON1.ADPREF1=0;

 ADCON0.ADON=1;


 SPBRGL=12;
 SPBRGH=0;
 TXSTA.BRGH=0;
 TXSTA.SYNC=0;
 BAUDCON.BRG16=0;
 APFCON.TXCKSEL=1;
 RCSTA.SPEN=1;
 TXSTA.TXEN=1;

 APFCON.RXDTSEL=1;
 RCSTA.CREN=1;










 while(1){

 bit_count=0;
 timeout_counter=0;
 data_word=0;
 data_bit=0;


 while(myADC(0) > 33);


 while( bit_count < 24 && timeout_counter < 50 ){
 clock=(myADC(0) > 33);



 if(clock==1 && clock_lpv==0) {

 data_bit=(myADC(1)> 33);



 data_bit = data_bit << 24;
 data_word = data_word + data_bit ;
 data_word = data_word >> 1;


 timeout_counter=0;


 bit_count++;


 }


 timeout_counter++;



 clock_lpv=clock;
 }
 if (bit_count==24){

 measurement = data_word & 0b00000000000011111111111111111111;


 digit_05=measurement % 2;
 measurement=measurement/2;
 digits[0]=measurement/1000;
 measurement=measurement-1000*digits[0];
 digits[1]=measurement/100;
 measurement=measurement-100*digits[1];
 digits[2]=measurement/10;
 measurement=measurement-10*digits[2];
 digits[3]=measurement;


 digits[0]+=0x30;
 digits[1]+=0x30;
 digits[2]+=0x30;
 digits[3]+=0x30;
 if (digit_05==1){
 digit_05=0x35;
 }
 else {
 digit_05=0x30;
 }


 }
 if(PIR1.RCIF){
 if(RCREG=='r'){

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
