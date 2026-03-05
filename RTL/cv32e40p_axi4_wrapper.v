`timescale 1ns / 1ps
`default_nettype none

module cv32e40p_axi4lite_wrapper #(
    parameter COREV_PULP = 0,
    parameter COREV_CLUSTER = 0,
    parameter FPU = 0,
    parameter FPU_ADDMUL_LAT = 0,
    parameter FPU_OTHERS_LAT = 0,
    parameter ZFINX = 0,
    parameter NUM_MHPMCOUNTERS = 1
)(
    input  wire        clk_i,
    input  wire        rst_ni,

    // Core Control & Config
    input  wire        pulp_clock_en_i,
    input  wire        scan_cg_en_i,
    input  wire [31:0] boot_addr_i,
    input  wire [31:0] mtvec_addr_i,
    input  wire [31:0] dm_halt_addr_i,
    input  wire [31:0] hart_id_i,
    input  wire [31:0] dm_exception_addr_i,
    input  wire        fetch_enable_i,
    output wire        core_sleep_o,

    // Interrupts
    input  wire [31:0] irq_i,
    output wire        irq_ack_o,
    output wire [ 4:0] irq_id_o,

    // Debug
    input  wire        debug_req_i,
    output wire        debug_havereset_o,
    output wire        debug_running_o,
    output wire        debug_halted_o,

    // ==========================================
    // AXI4-Lite Master 0: INSTRUCTION FETCH
    // ==========================================
    output wire        m_axi_instr_awvalid,
    input  wire        m_axi_instr_awready,
    output wire [31:0] m_axi_instr_awaddr,
    output wire [ 2:0] m_axi_instr_awprot,
    output wire        m_axi_instr_wvalid,
    input  wire        m_axi_instr_wready,
    output wire [31:0] m_axi_instr_wdata,
    output wire [ 3:0] m_axi_instr_wstrb,
    input  wire        m_axi_instr_bvalid,
    output wire        m_axi_instr_bready,
    input  wire [ 1:0] m_axi_instr_bresp,
    output wire        m_axi_instr_arvalid,
    input  wire        m_axi_instr_arready,
    output wire [31:0] m_axi_instr_araddr,
    output wire [ 2:0] m_axi_instr_arprot,
    input  wire        m_axi_instr_rvalid,
    output wire        m_axi_instr_rready,
    input  wire [31:0] m_axi_instr_rdata,
    input  wire [ 1:0] m_axi_instr_rresp,

    // ==========================================
    // AXI4-Lite Master 1: DATA
    // ==========================================
    output wire        m_axi_data_awvalid,
    input  wire        m_axi_data_awready,
    output wire [31:0] m_axi_data_awaddr,
    output wire [ 2:0] m_axi_data_awprot,
    output wire        m_axi_data_wvalid,
    input  wire        m_axi_data_wready,
    output wire [31:0] m_axi_data_wdata,
    output wire [ 3:0] m_axi_data_wstrb,
    input  wire        m_axi_data_bvalid,
    output wire        m_axi_data_bready,
    input  wire [ 1:0] m_axi_data_bresp,
    output wire        m_axi_data_arvalid,
    input  wire        m_axi_data_arready,
    output wire [31:0] m_axi_data_araddr,
    output wire [ 2:0] m_axi_data_arprot,
    input  wire        m_axi_data_rvalid,
    output wire        m_axi_data_rready,
    input  wire [31:0] m_axi_data_rdata,
    input  wire [ 1:0] m_axi_data_rresp
);

    // ------------------------------------------
    // Internal OBI Wires
    // ------------------------------------------
    wire        instr_req;
    wire        instr_gnt;
    wire        instr_rvalid;
    wire [31:0] instr_addr;
    wire [31:0] instr_rdata;

    wire        data_req;
    wire        data_gnt;
    wire        data_rvalid;
    wire        data_we;
    wire [ 3:0] data_be;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;

    // ------------------------------------------
    // Core Instantiation
    // ------------------------------------------
    cv32e40p_top #(
        .COREV_PULP      (COREV_PULP),
        .COREV_CLUSTER   (COREV_CLUSTER),
        .FPU             (FPU),
        .FPU_ADDMUL_LAT  (FPU_ADDMUL_LAT),
        .FPU_OTHERS_LAT  (FPU_OTHERS_LAT),
        .ZFINX           (ZFINX),
        .NUM_MHPMCOUNTERS(NUM_MHPMCOUNTERS)
    ) core_i (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        .pulp_clock_en_i    (pulp_clock_en_i),
        .scan_cg_en_i       (scan_cg_en_i),
        .boot_addr_i        (boot_addr_i),
        .mtvec_addr_i       (mtvec_addr_i),
        .dm_halt_addr_i     (dm_halt_addr_i),
        .hart_id_i          (hart_id_i),
        .dm_exception_addr_i(dm_exception_addr_i),

        .instr_req_o        (instr_req),
        .instr_gnt_i        (instr_gnt),
        .instr_rvalid_i     (instr_rvalid),
        .instr_addr_o       (instr_addr),
        .instr_rdata_i      (instr_rdata),

        .data_req_o         (data_req),
        .data_gnt_i         (data_gnt),
        .data_rvalid_i      (data_rvalid),
        .data_we_o          (data_we),
        .data_be_o          (data_be),
        .data_addr_o        (data_addr),
        .data_wdata_o       (data_wdata),
        .data_rdata_i       (data_rdata),

        .irq_i              (irq_i),
        .irq_ack_o          (irq_ack_o),
        .irq_id_o           (irq_id_o),

        .debug_req_i        (debug_req_i),
        .debug_havereset_o  (debug_havereset_o),
        .debug_running_o    (debug_running_o),
        .debug_halted_o     (debug_halted_o),

        .fetch_enable_i     (fetch_enable_i),
        .core_sleep_o       (core_sleep_o)
    );

    // ==========================================
    // FSM 1: INSTRUCTION FETCH (Read-Only)
    // ==========================================
    localparam ST_I_IDLE    = 2'd0;
    localparam ST_I_READ_AR = 2'd1;
    localparam ST_I_READ_R  = 2'd2;

    reg [1:0]  state_i, next_state_i;
    reg [31:0] latched_instr_addr;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_i            <= ST_I_IDLE;
            latched_instr_addr <= 32'd0;
        end else begin
            state_i <= next_state_i;
            if (state_i == ST_I_IDLE && instr_req) begin
                latched_instr_addr <= instr_addr;
            end
        end
    end

    always @(*) begin
        next_state_i = state_i;
        case (state_i)
            ST_I_IDLE:    if (instr_req)           next_state_i = ST_I_READ_AR;
            ST_I_READ_AR: if (m_axi_instr_arready) next_state_i = ST_I_READ_R;
            ST_I_READ_R:  if (m_axi_instr_rvalid)  next_state_i = ST_I_IDLE;
            default:                               next_state_i = ST_I_IDLE;
        endcase
    end

    // Instruction OBI assignments
    assign instr_gnt    = (state_i == ST_I_IDLE) && instr_req;
    assign instr_rvalid = (state_i == ST_I_READ_R && m_axi_instr_rvalid);
    assign instr_rdata  = m_axi_instr_rdata;

    // Instruction AXI-Lite Read Channels
    assign m_axi_instr_arvalid = (state_i == ST_I_READ_AR);
    assign m_axi_instr_araddr  = latched_instr_addr;
    assign m_axi_instr_arprot  = 3'b100; // Instruction fetch, unprivileged, secure
    assign m_axi_instr_rready  = (state_i == ST_I_READ_R);

    // Instruction AXI-Lite Write Channels (Tied off - it's ROM/Flash)
    assign m_axi_instr_awvalid = 1'b0;
    assign m_axi_instr_awaddr  = 32'd0;
    assign m_axi_instr_awprot  = 3'd0;
    assign m_axi_instr_wvalid  = 1'b0;
    assign m_axi_instr_wdata   = 32'd0;
    assign m_axi_instr_wstrb   = 4'd0;
    assign m_axi_instr_bready  = 1'b0;


    // ==========================================
    // FSM 2: DATA (Read and Write)
    // ==========================================
    localparam ST_D_IDLE       = 3'd0;
    localparam ST_D_WRITE_AW_W = 3'd1;
    localparam ST_D_WRITE_B    = 3'd2;
    localparam ST_D_READ_AR    = 3'd3;
    localparam ST_D_READ_R     = 3'd4;

    reg [2:0]  state_d, next_state_d;
    reg [31:0] latched_data_addr;
    reg [31:0] latched_data_wdata;
    reg [ 3:0] latched_data_wstrb;
    reg        aw_accepted;
    reg        w_accepted;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_d            <= ST_D_IDLE;
            latched_data_addr  <= 32'd0;
            latched_data_wdata <= 32'd0;
            latched_data_wstrb <= 4'd0;
            aw_accepted        <= 1'b0;
            w_accepted         <= 1'b0;
        end else begin
            state_d <= next_state_d;
            
            if (state_d == ST_D_IDLE && data_req) begin
                latched_data_addr  <= data_addr;
                latched_data_wdata <= data_wdata;
                latched_data_wstrb <= data_be;
            end

            if (state_d == ST_D_IDLE) begin
                aw_accepted <= 1'b0;
                w_accepted  <= 1'b0;
            end else if (state_d == ST_D_WRITE_AW_W) begin
                if (m_axi_data_awvalid && m_axi_data_awready) aw_accepted <= 1'b1;
                if (m_axi_data_wvalid  && m_axi_data_wready)  w_accepted  <= 1'b1;
            end
        end
    end

    always @(*) begin
        next_state_d = state_d;
        case (state_d)
            ST_D_IDLE: begin
                if (data_req) begin
                    if (data_we) next_state_d = ST_D_WRITE_AW_W;
                    else         next_state_d = ST_D_READ_AR;
                end
            end
            ST_D_WRITE_AW_W: begin
                if ((aw_accepted || m_axi_data_awready) && (w_accepted || m_axi_data_wready)) 
                    next_state_d = ST_D_WRITE_B;
            end
            ST_D_WRITE_B: if (m_axi_data_bvalid)  next_state_d = ST_D_IDLE;
            ST_D_READ_AR: if (m_axi_data_arready) next_state_d = ST_D_READ_R;
            ST_D_READ_R:  if (m_axi_data_rvalid)  next_state_d = ST_D_IDLE;
            default:                              next_state_d = ST_D_IDLE;
        endcase
    end

    // Data OBI Assignments
    assign data_gnt    = (state_d == ST_D_IDLE) && data_req;
    assign data_rvalid = (state_d == ST_D_WRITE_B && m_axi_data_bvalid) || 
                         (state_d == ST_D_READ_R  && m_axi_data_rvalid);
    assign data_rdata  = m_axi_data_rdata;

    // Data AXI-Lite Write Channels
    assign m_axi_data_awvalid = (state_d == ST_D_WRITE_AW_W) && !aw_accepted;
    assign m_axi_data_awaddr  = latched_data_addr;
    assign m_axi_data_awprot  = 3'b000;
    
    assign m_axi_data_wvalid  = (state_d == ST_D_WRITE_AW_W) && !w_accepted;
    assign m_axi_data_wdata   = latched_data_wdata;
    assign m_axi_data_wstrb   = latched_data_wstrb;
    
    assign m_axi_data_bready  = (state_d == ST_D_WRITE_B);

    // Data AXI-Lite Read Channels
    assign m_axi_data_arvalid = (state_d == ST_D_READ_AR);
    assign m_axi_data_araddr  = latched_data_addr;
    assign m_axi_data_arprot  = 3'b000;
    
    assign m_axi_data_rready  = (state_d == ST_D_READ_R);

endmodule
`default_nettype wire