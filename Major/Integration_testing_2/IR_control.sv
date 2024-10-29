module IR_control (
	input clk,
	input reset,
	inout [3:0]	sd_DAT,
	inout [3:0] hsmc_d,
	inout	[6:0]	ex_io,
	input irda_rxd,
	inout aud_adclrck,
	inout aud_daclrck,
	inout [35:0] gpio,
	input 		overwrite,
	
	output  [6:0] HEX0,
	output  [6:0] HEX1,
	output  [6:0] HEX2,
	output  [6:0] HEX3,
	output  [6:0] HEX4,
	output  [6:0] HEX5,
	output  [6:0] HEX6,
	output  [6:0] HEX7,
	
	output wire [31:0] hex_output //seg data input
);

wire    data_ready;        //IR data_ready flag
//reg   data_read;         //read    
wire    clk50;             //pll 50M output for irda


//	All inout port turn to tri-state 
assign	sd_DAT		=	4'b1zzz;  //Set SD Card to SD Mode
assign	hsmc_d   	=	4'hz;
assign	ex_io   	=	7'bzz;
assign 	gpio = 36'hzzzzzzzzz;
assign aud_adclrck = aud_daclrck;


// The following might be better to include in top level instead:
//======================================================
// IR Remote Logic

//logic button1, button2, button3, button4;
//logic mute_button;
//wire [31:0] hex_data; // Put this part if not already declared earlier

//IR_control ir_control(.*); // Definitely put this part only in top-level

//assign button1 = (hex_data[31:16] == 16'hfe01);
//assign button2 = (hex_data[31:16] == 16'hfd02);
//assign button3 = (hex_data[31:16] == 16'hfc03);
//assign button4 = (hex_data[31:16] == 16'hfb04);

//assign mute_button = (output_data[31:16] == 16'hf30c);
//======================================================


//=============================================================================
// Structural coding
//=============================================================================

//	All inout port turn to tri-state 
//assign	SD_DAT		=	4'b1zzz;  //Set SD Card to SD Mode
//assign	AUD_ADCLRCK	=	AUD_DACLRCK;
//assign	GPIO	=	36'hzzzzzzzzz;
//assign	HSMC_D   	=	4'hz;
//assign	EX_IO   	=	7'bzz;

//////////wait for data_ready///////////////
//always @( data_ready)
//	begin
//		if(data_ready)
//			data_read <= 1;
//		else
//		    data_read <= 0;
//	end
 
pll1 u0(
		.inclk0(clk),
		//irda clock 50M 
		.c0(clk50),          
		.c1());

IR_RECEIVE u1(
					///clk 50MHz////
					.iCLK(clk50), 
					//reset          
					.iRST_n(reset),        
					//IRDA code input
					.iIRDA(irda_rxd), 
					//read command      
					//.iREAD(data_read),
					//data ready      					
					.oDATA_READY(data_ready),
					//decoded data 32bit
					.oDATA(hex_data)        
					);
					
// Key code is displayed on HEX0 ~ HEX3
// Custom code is displayed on HEX4 ~ HEX7

logic [31:0] hex_data;

always_comb begin
	hex_output = hex_data;
	if (overwrite) begin
		hex_output [31:16] = 16'hfe01;
		hex_output [15:0] = hex_data[15:0];
	end
end

SEG_HEX u2( //display the HEX on HEX0                               
			.iDIG(hex_output[31:28]),         
			.oHEX_D(HEX0)
		  );  
SEG_HEX u3( //display the HEX on HEX1                                
           .iDIG(hex_output[27:24]),
           .oHEX_D(HEX1)
           );
SEG_HEX u4(//display the HEX on HEX2                                
           .iDIG(hex_output[23:20]),
           .oHEX_D(HEX2)
           );
SEG_HEX u5(//display the HEX on HEX3                                 
           .iDIG(hex_output[19:16]),
           .oHEX_D(HEX3)
           );
SEG_HEX u6(//display the HEX on HEX4                                 
           .iDIG(hex_output[15:12]),
           .oHEX_D(HEX4)
           );
SEG_HEX u7(//display the HEX on HEX5                                 
           .iDIG(hex_output[11:8]) , 
           .oHEX_D(HEX5)
           );
SEG_HEX u8(//display the HEX on HEX6                                 
           .iDIG(hex_output[7:4]) ,
           .oHEX_D(HEX6)
           );
SEG_HEX u9(//display the HEX on HEX7                                 
           .iDIG(hex_output[3:0]) ,
           .oHEX_D(HEX7)
           );           





endmodule
