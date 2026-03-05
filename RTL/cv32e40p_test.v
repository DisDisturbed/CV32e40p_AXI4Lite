`timescale 1ns / 1ps
`default_nettype none

module cv32e40p_test #(
    parameter INS_FILE_NAME = "ins.mem",
    parameter DATA_FILE_NAME = "data.mem",
    parameter ADDR_WIDTH_DMEM = 12,
    parameter ADDR_WIDTH_IMEM = 12
)(
    input  wire        clk,
    input  wire        rst_n,
       
    //======= irqs ========
    input  wire [31:0] irq,
    output wire        irq_ack_o,
    output wire [ 4:0] irq_id_o
);

    //======== axi4lite instruction master interface signals =========
    wire        m_axi_instr_awvalid;
    wire        m_axi_instr_awready;
    wire [31:0] m_axi_instr_awaddr;
    wire [ 2:0] m_axi_instr_awprot;
    wire        m_axi_instr_wvalid;
    wire        m_axi_instr_wready;
    wire [31:0] m_axi_instr_wdata;
    wire [ 3:0] m_axi_instr_wstrb;
    wire        m_axi_instr_bvalid;
    wire        m_axi_instr_bready;
    wire [ 1:0] m_axi_instr_bresp;
    wire        m_axi_instr_arvalid;
    wire        m_axi_instr_arready;
    wire [31:0] m_axi_instr_araddr;
    wire [ 2:0] m_axi_instr_arprot;
    wire        m_axi_instr_rvalid;
    wire        m_axi_instr_rready;
    wire [31:0] m_axi_instr_rdata;
    wire [ 1:0] m_axi_instr_rresp;
       
    // ============== axi4lite data master interface signals =========
    wire        m_axi_data_awvalid;
    wire        m_axi_data_awready;
    wire [31:0] m_axi_data_awaddr;
    wire [ 2:0] m_axi_data_awprot;
    wire        m_axi_data_wvalid;
    wire        m_axi_data_wready;
    wire [31:0] m_axi_data_wdata; 
    wire [ 3:0] m_axi_data_wstrb;  
    wire        m_axi_data_bvalid; 
    wire        m_axi_data_bready;
    wire [ 1:0] m_axi_data_bresp; 
    wire        m_axi_data_arvalid;
    wire        m_axi_data_arready;
    wire [31:0] m_axi_data_araddr;
    wire [ 2:0] m_axi_data_arprot;
    wire        m_axi_data_rvalid;
    wire        m_axi_data_rready;
    wire [31:0] m_axi_data_rdata;
    wire [ 1:0] m_axi_data_rresp;

    // CV32E40P Core Wrapper
    cv32e40p_axi4lite_wrapper #(
        .COREV_PULP      (0),     
        .COREV_CLUSTER   (0),  
        .FPU             (0),            
        .FPU_ADDMUL_LAT  (0), 
        .FPU_OTHERS_LAT  (0), 
        .ZFINX           (0),          
        .NUM_MHPMCOUNTERS(1)
    ) core_wrapper_i ( 
        .clk_i              (clk),
        .rst_ni             (rst_n),
        
        // --- Core Control & Configuration (ADDED THESE) ---
        .pulp_clock_en_i    (1'b0),
        .scan_cg_en_i       (1'b0),
        .boot_addr_i        (32'h0000_0000), 
        .mtvec_addr_i       (32'h0000_0000),
        .dm_halt_addr_i     (32'h0000_0000),
        .hart_id_i          (32'h0000_0000),
        .dm_exception_addr_i(32'h0000_0000),
        .fetch_enable_i     (1'b1),          
        .core_sleep_o       (),              
        
        // --- Interrupts & Debug (ADDED THESE) ---
        .irq_i              (irq),
        .irq_ack_o          (irq_ack_o),
        .irq_id_o           (irq_id_o),
        .debug_req_i        (1'b0),
        .debug_havereset_o  (),
        .debug_running_o    (),
        .debug_halted_o     (),

        //-------- instr side --------
        .m_axi_instr_awvalid(m_axi_instr_awvalid),
        .m_axi_instr_awready(m_axi_instr_awready),
        .m_axi_instr_awaddr (m_axi_instr_awaddr ),
        .m_axi_instr_awprot (m_axi_instr_awprot ),
        .m_axi_instr_wvalid (m_axi_instr_wvalid ),
        .m_axi_instr_wready (m_axi_instr_wready ),
        .m_axi_instr_wdata  (m_axi_instr_wdata  ),
        .m_axi_instr_wstrb  (m_axi_instr_wstrb  ),
        .m_axi_instr_bvalid (m_axi_instr_bvalid ),
        .m_axi_instr_bready (m_axi_instr_bready ),
        .m_axi_instr_bresp  (m_axi_instr_bresp  ),
        .m_axi_instr_arvalid(m_axi_instr_arvalid),
        .m_axi_instr_arready(m_axi_instr_arready),
        .m_axi_instr_araddr (m_axi_instr_araddr ),
        .m_axi_instr_arprot (m_axi_instr_arprot ),
        .m_axi_instr_rvalid (m_axi_instr_rvalid ),
        .m_axi_instr_rready (m_axi_instr_rready ),
        .m_axi_instr_rdata  (m_axi_instr_rdata  ),
        .m_axi_instr_rresp  (m_axi_instr_rresp  ),
              
        //------------ data side --------
        .m_axi_data_awvalid (m_axi_data_awvalid ),
        .m_axi_data_awready (m_axi_data_awready ),
        .m_axi_data_awaddr  (m_axi_data_awaddr  ),
        .m_axi_data_awprot  (m_axi_data_awprot  ),
        .m_axi_data_wvalid  (m_axi_data_wvalid  ),
        .m_axi_data_wready  (m_axi_data_wready  ),
        .m_axi_data_wdata   (m_axi_data_wdata   ),
        .m_axi_data_wstrb   (m_axi_data_wstrb   ),
        .m_axi_data_bvalid  (m_axi_data_bvalid  ),
        .m_axi_data_bready  (m_axi_data_bready  ),
        .m_axi_data_bresp   (m_axi_data_bresp   ), 
        .m_axi_data_arvalid (m_axi_data_arvalid ),
        .m_axi_data_arready (m_axi_data_arready ),
        .m_axi_data_araddr  (m_axi_data_araddr  ),
        .m_axi_data_arprot  (m_axi_data_arprot  ),
        .m_axi_data_rvalid  (m_axi_data_rvalid  ),
        .m_axi_data_rready  (m_axi_data_rready  ),
        .m_axi_data_rdata   (m_axi_data_rdata   ), 
        .m_axi_data_rresp   (m_axi_data_rresp   )
    );

    // Data RAM
    axil_ram #(
        .DATA_WIDTH     (32),
        .ADDR_WIDTH     (ADDR_WIDTH_DMEM),
        .PIPELINE_OUTPUT(0),
        .RAM_FILE       (DATA_FILE_NAME)
    ) data_ram_inst (
        .clk            (clk),             
        .rst            (~rst_n),                 
        .s_axil_awaddr  (m_axi_data_awaddr[ADDR_WIDTH_DMEM - 1:0]  ),
        .s_axil_awprot  (m_axi_data_awprot  ),
        .s_axil_awvalid (m_axi_data_awvalid ),
        .s_axil_awready (m_axi_data_awready ),
        .s_axil_wdata   (m_axi_data_wdata   ),
        .s_axil_wstrb   (m_axi_data_wstrb   ),
        .s_axil_wvalid  (m_axi_data_wvalid  ),
        .s_axil_wready  (m_axi_data_wready  ),
        .s_axil_bresp   (m_axi_data_bresp   ),
        .s_axil_bvalid  (m_axi_data_bvalid  ),
        .s_axil_bready  (m_axi_data_bready  ),
        .s_axil_araddr  (m_axi_data_araddr [ADDR_WIDTH_DMEM - 1:0] ),
        .s_axil_arprot  (m_axi_data_arprot  ),
        .s_axil_arvalid (m_axi_data_arvalid ),
        .s_axil_arready (m_axi_data_arready ),
        .s_axil_rdata   (m_axi_data_rdata   ),
        .s_axil_rresp   (m_axi_data_rresp   ),
        .s_axil_rvalid  (m_axi_data_rvalid  ),
        .s_axil_rready  (m_axi_data_rready  )
    );
                 
    // Instruction ROM
    axil_rom #(
        .DATA_WIDTH     (32),     
        .ADDR_WIDTH     (ADDR_WIDTH_IMEM),     
        .PIPELINE_OUTPUT(0), 
        .RAM_FILE       (INS_FILE_NAME)
    ) instr_rom_inst (
        .clk            (clk),
        .rst            (~rst_n),
        
        .s_axil_awaddr  (m_axi_instr_awaddr[ADDR_WIDTH_IMEM - 1:0]   ),
        .s_axil_awprot  (m_axi_instr_awprot  ),
        .s_axil_awvalid (m_axi_instr_awvalid ),
        .s_axil_awready (m_axi_instr_awready ),
        .s_axil_wdata   (m_axi_instr_wdata   ),
        .s_axil_wstrb   (m_axi_instr_wstrb   ),
        .s_axil_wvalid  (m_axi_instr_wvalid  ),
        .s_axil_wready  (m_axi_instr_wready  ),
        .s_axil_bresp   (m_axi_instr_bresp   ),
        .s_axil_bvalid  (m_axi_instr_bvalid  ),
        .s_axil_bready  (m_axi_instr_bready  ),
        .s_axil_araddr  (m_axi_instr_araddr [ADDR_WIDTH_IMEM - 1:0] ),
        .s_axil_arprot  (m_axi_instr_arprot  ),
        .s_axil_arvalid (m_axi_instr_arvalid ),
        .s_axil_arready (m_axi_instr_arready ),
        .s_axil_rdata   (m_axi_instr_rdata   ),
        .s_axil_rresp   (m_axi_instr_rresp   ),
        .s_axil_rvalid  (m_axi_instr_rvalid  ),
        .s_axil_rready  (m_axi_instr_rready  )
    );
    
endmodule
`default_nettype wire