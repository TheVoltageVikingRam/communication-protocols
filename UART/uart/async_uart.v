<pre>module uarttx #(
parameter clk_freq = 1000000,
parameter baud_rate = 9600
)
(
input clk, rst,
input newd,
input [7:0] tx_data,
output reg tx,
output reg donetx
);

localparam clkcount = (clk_freq/baud_rate); ///x

integer count = 0;
integer counts = 0;

reg uclk = 0;
typedef enum bit[1:0] {
idle = 2&apos;b00, 
start = 2&apos;b01, 
transfer = 2&apos;b10, 
done = 2&apos;b11} state_t;

state_t state;


//////uart clock gen

always @(posedge clk) begin 
if(rst) begin
	count &lt;= 0;
	uclk &lt;= 0;
end

else begin

	if (count &lt; clkcount/2 - 1)
		count &lt;= count + 1;
	else begin 
		count &lt;= 0;
		uclk &lt;= ~uclk;	
		end
	end
end


reg [7:0] din;


//UART TX 
always @(posedge uclk)
begin 
	if(rst)
	begin
		state &lt;= idle;
		tx &lt;= 1&apos;b1;
		donetx &lt;= 1&apos;b0;
		counts &lt;= 0;

	end
	else begin
	case (state)
		idle:
		 begin
			counts &lt;= 0;
			tx &lt;= 1&apos;b1;
			donetx &lt;= 1&apos;b0;
			
			if(newd)
			begin
				state &lt;= start;
				din &lt;= tx_data;
			end

		end

		start: begin
			tx &lt;= 1&apos;b0;  ///Start bit
			state &lt;= transfer;
		end


		transfer:
		 begin
			if (counts &lt;= 7) begin
				counts &lt;= counts + 1;
				tx &lt;= din[counts];
			end

			else begin
				state &lt;= done;
			end
		end
		done:begin

			
				tx &lt;= 1&apos;b1; //stop bit
				state &lt;= idle;
				donetx &lt;= 1&apos;b1;
		end
		
		default: state &lt;= idle;
		endcase
	end

end

endmodule





module uartrx
#(
parameter clk_freq = 1000000,  //1 Mhz
parameter baud_rate = 9600
)

(
input clk,
input rst,
input rx,
output reg done,
output reg [7:0] rxdata
);


localparam clkcount = (clk_freq/baud_rate);

integer count = 0;
integer counts = 0;

reg uclk = 0;

typedef enum bit[1:0] {idle = 2&apos;b00, start = 2&apos;b01 } state_t;

state_t state;

//uart_clock_gen

always @(posedge clk)
	begin
		if(rst) begin
		count &lt;= 0;
		uclk &lt;= 0;
		end
		else begin

		if(count &lt; clkcount/2)
		 count &lt;= count + 1;
		else begin
		 count &lt;= 0;
		 uclk &lt;= ~uclk;
		end
	end
end



always @(posedge uclk)
	begin 
		if (rst) begin
		rxdata &lt;= 8&apos;h00;
		counts &lt;= 0;
		done &lt;= 1&apos;b0;
		end
		else
		begin
		 case(state)

		idle : begin
			rxdata &lt;= 8&apos;h00;
			counts &lt;= 0;
			done &lt;= 1&apos;b0;
		
		if (rx == 1&apos;b0)
		state &lt;= start;
		else
		state &lt;= idle;
		end


		start:
		begin

			if (counts &lt;= 7)
			begin
			counts &lt;= counts + 1;
			rxdata &lt;= {rx, rxdata[7:1]};
			end
		else begin
			counts &lt;= 0;
			done &lt;= 1&apos;b1;
			state &lt;= idle;
		end
		end

		default: state &lt;= idle;
	endcase

	end
end
endmodule





module uart_top
#(
parameter clk_freq = 1000000,
parameter baud_rate = 9600
)

(
input clk, rst,
input rx,
input [7:0] dintx,
input newd,
output tx,
output [7:0] doutrx,
output donetx,
output donerx
);


uarttx #(clk_freq, baud_rate) utx (clk, rst, newd, dintx, tx, donetx);

uartrx #(clk_freq, baud_rate) rtx (clk, rst, rx, donerx, doutrx);

endmodule


</pre>
