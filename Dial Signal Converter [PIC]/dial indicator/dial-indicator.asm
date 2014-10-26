
_sendChar:

;dial-indicator.c,11 :: 		void sendChar(unsigned char dataout){
;dial-indicator.c,12 :: 		Delay_us(52);
	MOVLW      69
	MOVWF      R13
L_sendChar0:
	DECFSZ     R13, 1
	GOTO       L_sendChar0
;dial-indicator.c,13 :: 		TXREG=dataout;
	MOVF       FARG_sendChar_dataout+0, 0
	MOVWF      TXREG+0
;dial-indicator.c,14 :: 		while(TXSTA.TRMT);
L_sendChar1:
	BTFSS      TXSTA+0, 1
	GOTO       L_sendChar2
	GOTO       L_sendChar1
L_sendChar2:
;dial-indicator.c,15 :: 		while(!TXSTA.TRMT);
L_sendChar3:
	BTFSC      TXSTA+0, 1
	GOTO       L_sendChar4
	GOTO       L_sendChar3
L_sendChar4:
;dial-indicator.c,16 :: 		}
L_end_sendChar:
	RETURN
; end of _sendChar

_myADC:

;dial-indicator.c,18 :: 		unsigned int myADC(unsigned short pin){
;dial-indicator.c,22 :: 		if (pin == 0){
	MOVF       FARG_myADC_pin+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_myADC5
;dial-indicator.c,23 :: 		ADCON0 = ADCON0 & 0b10000011;            //CHS<4:0>: Analog Channel Select bits, 00000 = AN0
	MOVLW      131
	ANDWF      ADCON0+0, 1
;dial-indicator.c,24 :: 		}
	GOTO       L_myADC6
L_myADC5:
;dial-indicator.c,25 :: 		else if (pin == 1){
	MOVF       FARG_myADC_pin+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_myADC7
;dial-indicator.c,26 :: 		ADCON0 = ADCON0 & 0b10000111;            //CHS<4:0>: Analog Channel Select bits, 00001 = AN1
	MOVLW      135
	ANDWF      ADCON0+0, 1
;dial-indicator.c,27 :: 		ADCON0 = ADCON0 | 0b00000100;
	BSF        ADCON0+0, 2
;dial-indicator.c,28 :: 		}
L_myADC7:
L_myADC6:
;dial-indicator.c,31 :: 		Delay_10us();
	CALL       _Delay_10us+0
;dial-indicator.c,34 :: 		ADCON0.GO_NOT_DONE=1;  //GO/DONE: A/D Conversion Status bit, 1 = A/D conversion cycle in progress. Setting this bit starts an A/D conversion cycle. This bit is automatically cleared by hardware when the A/D conversion has completed.
	BSF        ADCON0+0, 1
;dial-indicator.c,37 :: 		while(ADCON0.GO_NOT_DONE);
L_myADC8:
	BTFSS      ADCON0+0, 1
	GOTO       L_myADC9
	GOTO       L_myADC8
L_myADC9:
;dial-indicator.c,40 :: 		adc_data=ADRESH;
	MOVF       ADRESH+0, 0
	MOVWF      myADC_adc_data_L0+0
	CLRF       myADC_adc_data_L0+1
;dial-indicator.c,42 :: 		return adc_data;
	MOVF       myADC_adc_data_L0+0, 0
	MOVWF      R0
	MOVF       myADC_adc_data_L0+1, 0
	MOVWF      R1
;dial-indicator.c,43 :: 		}
L_end_myADC:
	RETURN
; end of _myADC

_main:

;dial-indicator.c,45 :: 		void main() {
;dial-indicator.c,48 :: 		OSCCON=0x78; //01111000    //SPLLEN: Software PLL Enable bit,0 = 4x PLL is disabled
	MOVLW      120
	MOVWF      OSCCON+0
;dial-indicator.c,54 :: 		TRISA.TRISA0=1;               //TRISA: PORTA TRI-STATE REGISTER, all inputs
	BSF        TRISA+0, 0
;dial-indicator.c,55 :: 		TRISA.TRISA1=1;
	BSF        TRISA+0, 1
;dial-indicator.c,56 :: 		TRISA.TRISA2=1;
	BSF        TRISA+0, 2
;dial-indicator.c,57 :: 		TRISA.TRISA3=1;               //This bit is always ‘1’ as RA3 is an input only
	BSF        TRISA+0, 3
;dial-indicator.c,58 :: 		TRISA.TRISA4=0;
	BCF        TRISA+0, 4
;dial-indicator.c,59 :: 		TRISA.TRISA5=1;
	BSF        TRISA+0, 5
;dial-indicator.c,62 :: 		ANSELA.ANSA0=1;              //ANSELA: PORTA ANALOG SELECT REGISTER: Pin 1 is analog
	BSF        ANSELA+0, 0
;dial-indicator.c,63 :: 		ANSELA.ANSA1=1;
	BSF        ANSELA+0, 1
;dial-indicator.c,64 :: 		ANSELA.ANSA2=0;
	BCF        ANSELA+0, 2
;dial-indicator.c,65 :: 		ANSELA.ANSA4=0;
	BCF        ANSELA+0, 4
;dial-indicator.c,68 :: 		ADCON1.adcs0=0;           //ADCS<2:0>: A/D Conversion Clock Select bits
	BCF        ADCON1+0, 4
;dial-indicator.c,69 :: 		ADCON1.adcs1=1;              //010 = FOSC/32
	BSF        ADCON1+0, 5
;dial-indicator.c,70 :: 		ADCON1.adcs2=0;
	BCF        ADCON1+0, 6
;dial-indicator.c,71 :: 		ADCON1.ADPREF0=0;         //ADPREF<1:0>: A/D Positive Voltage Reference Configuration bits
	BCF        ADCON1+0, 0
;dial-indicator.c,72 :: 		ADCON1.ADPREF1=0;            //00 = VREF+ is connected to AVDD
	BCF        ADCON1+0, 1
;dial-indicator.c,73 :: 		ADCON1.ADFM=0;            //ADFM: A/D Result Format Select bit, 0 = Left justified. Six Least Significant bits of ADRESL are set to ‘0’ when the conversion result is loaded.
	BCF        ADCON1+0, 7
;dial-indicator.c,74 :: 		ADCON1.ADCS0=0;           //ADCS<2:0>: A/D Conversion Clock Select bits
	BCF        ADCON1+0, 4
;dial-indicator.c,75 :: 		ADCON1.ADCS1=1;              //010 = FOSC/32
	BSF        ADCON1+0, 5
;dial-indicator.c,76 :: 		ADCON1.ADCS2=0;
	BCF        ADCON1+0, 6
;dial-indicator.c,77 :: 		ADCON1.ADPREF0=0;         //ADPREF<1:0>: A/D Positive Voltage Reference Configuration bits
	BCF        ADCON1+0, 0
;dial-indicator.c,78 :: 		ADCON1.ADPREF1=0;            //00 = VREF+ is connected to AVDD
	BCF        ADCON1+0, 1
;dial-indicator.c,80 :: 		ADCON0.ADON=1;           //ADON: ADC Enable bit, 1 = ADC is enabled
	BSF        ADCON0+0, 0
;dial-indicator.c,83 :: 		SPBRGL=12;
	MOVLW      12
	MOVWF      SPBRGL+0
;dial-indicator.c,84 :: 		SPBRGH=0;
	CLRF       SPBRGH+0
;dial-indicator.c,85 :: 		TXSTA.BRGH=0;
	BCF        TXSTA+0, 2
;dial-indicator.c,86 :: 		TXSTA.SYNC=0;
	BCF        TXSTA+0, 4
;dial-indicator.c,87 :: 		BAUDCON.BRG16=0;
	BCF        BAUDCON+0, 3
;dial-indicator.c,88 :: 		APFCON.TXCKSEL=1;   //1 = TX/CK function is on RA4
	BSF        APFCON+0, 2
;dial-indicator.c,89 :: 		RCSTA.SPEN=1;
	BSF        RCSTA+0, 7
;dial-indicator.c,90 :: 		TXSTA.TXEN=1;
	BSF        TXSTA+0, 5
;dial-indicator.c,92 :: 		APFCON.RXDTSEL=1;   //1 = RX/DT function is on RA5
	BSF        APFCON+0, 7
;dial-indicator.c,93 :: 		RCSTA.CREN=1;
	BSF        RCSTA+0, 4
;dial-indicator.c,104 :: 		while(1){
L_main10:
;dial-indicator.c,106 :: 		bit_count=0;
	CLRF       _bit_count+0
;dial-indicator.c,107 :: 		timeout_counter=0;
	CLRF       _timeout_counter+0
	CLRF       _timeout_counter+1
;dial-indicator.c,108 :: 		data_word=0;
	CLRF       _data_word+0
	CLRF       _data_word+1
	CLRF       _data_word+2
	CLRF       _data_word+3
;dial-indicator.c,109 :: 		data_bit=0;
	CLRF       _data_bit+0
	CLRF       _data_bit+1
	CLRF       _data_bit+2
	CLRF       _data_bit+3
;dial-indicator.c,112 :: 		while(myADC(0) > 33);
L_main12:
	CLRF       FARG_myADC_pin+0
	CALL       _myADC+0
	MOVF       R1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main32
	MOVF       R0, 0
	SUBLW      33
L__main32:
	BTFSC      STATUS+0, 0
	GOTO       L_main13
	GOTO       L_main12
L_main13:
;dial-indicator.c,115 :: 		while( bit_count < 24 && timeout_counter < 50 ){
L_main14:
	MOVLW      24
	SUBWF      _bit_count+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main15
	MOVLW      0
	SUBWF      _timeout_counter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main33
	MOVLW      50
	SUBWF      _timeout_counter+0, 0
L__main33:
	BTFSC      STATUS+0, 0
	GOTO       L_main15
L__main28:
;dial-indicator.c,116 :: 		clock=(myADC(0) > 33);
	CLRF       FARG_myADC_pin+0
	CALL       _myADC+0
	MOVF       R1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main34
	MOVF       R0, 0
	SUBLW      33
L__main34:
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R2
	MOVF       R2, 0
	MOVWF      _clock+0
;dial-indicator.c,120 :: 		if(clock==1 && clock_lpv==0) {
	MOVF       R2, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main20
	MOVF       _clock_lpv+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main20
L__main27:
;dial-indicator.c,122 :: 		data_bit=(myADC(1)> 33);
	MOVLW      1
	MOVWF      FARG_myADC_pin+0
	CALL       _myADC+0
	MOVF       R1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main35
	MOVF       R0, 0
	SUBLW      33
L__main35:
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      _data_bit+0
	MOVWF      _data_bit+1
	MOVWF      _data_bit+2
	MOVWF      _data_bit+3
	MOVLW      0
	MOVWF      _data_bit+1
	MOVWF      _data_bit+2
	MOVWF      _data_bit+3
;dial-indicator.c,126 :: 		data_bit = data_bit << 24;
	MOVF       _data_bit+0, 0
	MOVWF      R3
	CLRF       R0
	CLRF       R1
	CLRF       R2
	MOVF       R0, 0
	MOVWF      _data_bit+0
	MOVF       R1, 0
	MOVWF      _data_bit+1
	MOVF       R2, 0
	MOVWF      _data_bit+2
	MOVF       R3, 0
	MOVWF      _data_bit+3
;dial-indicator.c,127 :: 		data_word = data_word + data_bit ;
	MOVF       R0, 0
	ADDWF      _data_word+0, 1
	MOVF       R1, 0
	ADDWFC     _data_word+1, 1
	MOVF       R2, 0
	ADDWFC     _data_word+2, 1
	MOVF       R3, 0
	ADDWFC     _data_word+3, 1
;dial-indicator.c,128 :: 		data_word = data_word >> 1;
	LSRF       _data_word+3, 1
	RRF        _data_word+2, 1
	RRF        _data_word+1, 1
	RRF        _data_word+0, 1
;dial-indicator.c,131 :: 		timeout_counter=0;
	CLRF       _timeout_counter+0
	CLRF       _timeout_counter+1
;dial-indicator.c,134 :: 		bit_count++;
	INCF       _bit_count+0, 1
;dial-indicator.c,137 :: 		}
L_main20:
;dial-indicator.c,140 :: 		timeout_counter++;
	INCF       _timeout_counter+0, 1
	BTFSC      STATUS+0, 2
	INCF       _timeout_counter+1, 1
;dial-indicator.c,144 :: 		clock_lpv=clock;
	MOVF       _clock+0, 0
	MOVWF      _clock_lpv+0
;dial-indicator.c,145 :: 		}
	GOTO       L_main14
L_main15:
;dial-indicator.c,146 :: 		if (bit_count==24){
	MOVF       _bit_count+0, 0
	XORLW      24
	BTFSS      STATUS+0, 2
	GOTO       L_main21
;dial-indicator.c,148 :: 		measurement = data_word & 0b00000000000011111111111111111111;
	MOVLW      255
	ANDWF      _data_word+0, 0
	MOVWF      R5
	MOVLW      255
	ANDWF      _data_word+1, 0
	MOVWF      R6
	MOVLW      15
	ANDWF      _data_word+2, 0
	MOVWF      R7
	MOVLW      0
	ANDWF      _data_word+3, 0
	MOVWF      R8
	MOVF       R5, 0
	MOVWF      _measurement+0
	MOVF       R6, 0
	MOVWF      _measurement+1
	MOVF       R7, 0
	MOVWF      _measurement+2
	MOVF       R8, 0
	MOVWF      _measurement+3
;dial-indicator.c,151 :: 		digit_05=measurement % 2;
	MOVLW      1
	ANDWF      R5, 0
	MOVWF      R0
	MOVF       R6, 0
	MOVWF      R1
	MOVF       R7, 0
	MOVWF      R2
	MOVF       R8, 0
	MOVWF      R3
	MOVLW      0
	ANDWF      R1, 1
	ANDWF      R2, 1
	ANDWF      R3, 1
	MOVF       R0, 0
	MOVWF      _digit_05+0
;dial-indicator.c,152 :: 		measurement=measurement/2;
	MOVF       R5, 0
	MOVWF      R0
	MOVF       R6, 0
	MOVWF      R1
	MOVF       R7, 0
	MOVWF      R2
	MOVF       R8, 0
	MOVWF      R3
	LSRF       R3, 1
	RRF        R2, 1
	RRF        R1, 1
	RRF        R0, 1
	MOVF       R0, 0
	MOVWF      _measurement+0
	MOVF       R1, 0
	MOVWF      _measurement+1
	MOVF       R2, 0
	MOVWF      _measurement+2
	MOVF       R3, 0
	MOVWF      _measurement+3
;dial-indicator.c,153 :: 		digits[0]=measurement/1000;
	MOVLW      232
	MOVWF      R4
	MOVLW      3
	MOVWF      R5
	CLRF       R6
	CLRF       R7
	CALL       _Div_32x32_U+0
	MOVF       R0, 0
	MOVWF      _digits+0
;dial-indicator.c,154 :: 		measurement=measurement-1000*digits[0];
	MOVLW      0
	MOVWF      R1
	MOVLW      232
	MOVWF      R4
	MOVLW      3
	MOVWF      R5
	CALL       _Mul_16x16_U+0
	MOVF       _measurement+0, 0
	MOVWF      R4
	MOVF       _measurement+1, 0
	MOVWF      R5
	MOVF       _measurement+2, 0
	MOVWF      R6
	MOVF       _measurement+3, 0
	MOVWF      R7
	MOVF       R0, 0
	SUBWF      R4, 1
	MOVF       R1, 0
	SUBWFB     R5, 1
	MOVLW      0
	BTFSC      R1, 7
	MOVLW      255
	SUBWFB     R6, 1
	SUBWFB     R7, 1
	MOVF       R4, 0
	MOVWF      _measurement+0
	MOVF       R5, 0
	MOVWF      _measurement+1
	MOVF       R6, 0
	MOVWF      _measurement+2
	MOVF       R7, 0
	MOVWF      _measurement+3
;dial-indicator.c,155 :: 		digits[1]=measurement/100;
	MOVF       R4, 0
	MOVWF      R0
	MOVF       R5, 0
	MOVWF      R1
	MOVF       R6, 0
	MOVWF      R2
	MOVF       R7, 0
	MOVWF      R3
	MOVLW      100
	MOVWF      R4
	CLRF       R5
	CLRF       R6
	CLRF       R7
	CALL       _Div_32x32_U+0
	MOVF       R0, 0
	MOVWF      _digits+1
;dial-indicator.c,156 :: 		measurement=measurement-100*digits[1];
	MOVLW      100
	MOVWF      R4
	CALL       _Mul_8x8_U+0
	MOVF       _measurement+0, 0
	MOVWF      R4
	MOVF       _measurement+1, 0
	MOVWF      R5
	MOVF       _measurement+2, 0
	MOVWF      R6
	MOVF       _measurement+3, 0
	MOVWF      R7
	MOVF       R0, 0
	SUBWF      R4, 1
	MOVF       R1, 0
	SUBWFB     R5, 1
	MOVLW      0
	BTFSC      R1, 7
	MOVLW      255
	SUBWFB     R6, 1
	SUBWFB     R7, 1
	MOVF       R4, 0
	MOVWF      _measurement+0
	MOVF       R5, 0
	MOVWF      _measurement+1
	MOVF       R6, 0
	MOVWF      _measurement+2
	MOVF       R7, 0
	MOVWF      _measurement+3
;dial-indicator.c,157 :: 		digits[2]=measurement/10;
	MOVF       R4, 0
	MOVWF      R0
	MOVF       R5, 0
	MOVWF      R1
	MOVF       R6, 0
	MOVWF      R2
	MOVF       R7, 0
	MOVWF      R3
	MOVLW      10
	MOVWF      R4
	CLRF       R5
	CLRF       R6
	CLRF       R7
	CALL       _Div_32x32_U+0
	MOVF       R0, 0
	MOVWF      _digits+2
;dial-indicator.c,158 :: 		measurement=measurement-10*digits[2];
	MOVLW      10
	MOVWF      R4
	CALL       _Mul_8x8_U+0
	MOVF       _measurement+0, 0
	MOVWF      R2
	MOVF       _measurement+1, 0
	MOVWF      R3
	MOVF       _measurement+2, 0
	MOVWF      R4
	MOVF       _measurement+3, 0
	MOVWF      R5
	MOVF       R0, 0
	SUBWF      R2, 1
	MOVF       R1, 0
	SUBWFB     R3, 1
	MOVLW      0
	BTFSC      R1, 7
	MOVLW      255
	SUBWFB     R4, 1
	SUBWFB     R5, 1
	MOVF       R2, 0
	MOVWF      _measurement+0
	MOVF       R3, 0
	MOVWF      _measurement+1
	MOVF       R4, 0
	MOVWF      _measurement+2
	MOVF       R5, 0
	MOVWF      _measurement+3
;dial-indicator.c,159 :: 		digits[3]=measurement;
	MOVF       R2, 0
	MOVWF      _digits+3
;dial-indicator.c,162 :: 		digits[0]+=0x30;
	MOVLW      48
	ADDWF      _digits+0, 1
;dial-indicator.c,163 :: 		digits[1]+=0x30;
	MOVLW      48
	ADDWF      _digits+1, 1
;dial-indicator.c,164 :: 		digits[2]+=0x30;
	MOVLW      48
	ADDWF      _digits+2, 1
;dial-indicator.c,165 :: 		digits[3]+=0x30;
	MOVLW      48
	ADDWF      _digits+3, 1
;dial-indicator.c,166 :: 		if (digit_05==1){
	MOVF       _digit_05+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main22
;dial-indicator.c,167 :: 		digit_05=0x35; //"5"
	MOVLW      53
	MOVWF      _digit_05+0
;dial-indicator.c,168 :: 		}
	GOTO       L_main23
L_main22:
;dial-indicator.c,170 :: 		digit_05=0x30; //"0"
	MOVLW      48
	MOVWF      _digit_05+0
;dial-indicator.c,171 :: 		}
L_main23:
;dial-indicator.c,174 :: 		}
L_main21:
;dial-indicator.c,175 :: 		if(PIR1.RCIF){
	BTFSS      PIR1+0, 5
	GOTO       L_main24
;dial-indicator.c,176 :: 		if(RCREG=='r'){
	MOVF       RCREG+0, 0
	XORLW      114
	BTFSS      STATUS+0, 2
	GOTO       L_main25
;dial-indicator.c,178 :: 		sendChar(digits[0]);
	MOVF       _digits+0, 0
	MOVWF      FARG_sendChar_dataout+0
	CALL       _sendChar+0
;dial-indicator.c,179 :: 		sendChar('.');
	MOVLW      46
	MOVWF      FARG_sendChar_dataout+0
	CALL       _sendChar+0
;dial-indicator.c,180 :: 		sendChar(digits[1]);
	MOVF       _digits+1, 0
	MOVWF      FARG_sendChar_dataout+0
	CALL       _sendChar+0
;dial-indicator.c,181 :: 		sendChar(digits[2]);
	MOVF       _digits+2, 0
	MOVWF      FARG_sendChar_dataout+0
	CALL       _sendChar+0
;dial-indicator.c,182 :: 		sendChar(digits[3]);
	MOVF       _digits+3, 0
	MOVWF      FARG_sendChar_dataout+0
	CALL       _sendChar+0
;dial-indicator.c,183 :: 		sendChar(digit_05);
	MOVF       _digit_05+0, 0
	MOVWF      FARG_sendChar_dataout+0
	CALL       _sendChar+0
;dial-indicator.c,184 :: 		sendChar('\n');
	MOVLW      10
	MOVWF      FARG_sendChar_dataout+0
	CALL       _sendChar+0
;dial-indicator.c,185 :: 		}
L_main25:
;dial-indicator.c,186 :: 		}
L_main24:
;dial-indicator.c,187 :: 		if(RCSTA.OERR){
	BTFSS      RCSTA+0, 1
	GOTO       L_main26
;dial-indicator.c,188 :: 		RCSTA.CREN=0;
	BCF        RCSTA+0, 4
;dial-indicator.c,189 :: 		RCSTA.CREN=1;
	BSF        RCSTA+0, 4
;dial-indicator.c,190 :: 		}
L_main26:
;dial-indicator.c,192 :: 		}
	GOTO       L_main10
;dial-indicator.c,193 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
