package parameter_def;
/*------------------------------------------------------------------------------
--  system fractional bits setting
------------------------------------------------------------------------------*/
    localparam      FRANCTIONAL_BIT = 8;
/*------------------------------------------------------------------------------
--  QAM MOD
    mod_q, mod_i : 2Q0
------------------------------------------------------------------------------*/
    localparam      MOD_WIDTH =   3;
/*------------------------------------------------------------------------------
--  TX SR FIR
    s_axis_data_tdata : 2Q0  REAL[2:0]
    m_axis_data_tdata : Full precision -> 1Q13 REAL[14:0] 
                        Take 8-bit fractional bits -> 1Q8
------------------------------------------------------------------------------*/
    localparam      FILTER_WIDTH =   10;
/*------------------------------------------------------------------------------
--  TX mult :   Q = filter.q * -sin     I = filter.i *cos
    filter  :   1Q8
    sin cos :   1Q6
    mult    :   3Q14  Take 8-bit fractional bits -> 3Q8  
------------------------------------------------------------------------------*/
    localparam      MULT_WIDTH  =   12;
/*------------------------------------------------------------------------------
--  TX QAM      : QAM = I + Q
    I,Q         : 3Q8
    QAM         : 4Q8  
------------------------------------------------------------------------------*/
    localparam      QAM_WIDTH   =   13;
/*------------------------------------------------------------------------------
--  RX mult :   deQ = QAM*(-sin)    deI = QAM*cos
    QAM     :   4Q8    
    sin cos :   1Q6
    demult  :   5Q14  Take 8-bit fractional bits -> 5Q8
------------------------------------------------------------------------------*/
    localparam      DEMULT_WIDTH =   14;
/*------------------------------------------------------------------------------
--  RX SR FIR
    s_axis_data_tdata : 5Q8     REAL[13:0]
    m_axis_data_tdata : Full precision -> 23Q8 REAL[31:0]
                        Take 8-bit fractional bits -> 4Q8 
------------------------------------------------------------------------------*/
    localparam      DEFILTER_WIDTH =   13; 
/*------------------------------------------------------------------------------
--  qam carrier
    cos sin     : 1Q6
------------------------------------------------------------------------------*/
    localparam      CARRIER_WIDTH  =   8;   
endpackage : parameter_def

/*------------------------------------------------------------------------------
--  qam_internal_port
    For tx : filter
    For rx : defilter demult
------------------------------------------------------------------------------*/
interface qam_internal_port #(parameter WIDTH = 15)();
    logic signed    [WIDTH-1 : 0]    q, i;
    logic                            valid;   

    modport pin     (input  q, i, valid);
    modport pout    (output q, i, valid);
endinterface : qam_internal_port
/*------------------------------------------------------------------------------
--  qam carrier
    cos sin     : 1Q6
------------------------------------------------------------------------------*/
interface qam_carrier #(parameter WIDTH = 8)();   
    logic signed    [WIDTH-1 : 0]   cos,sin;
    logic                           valid,zero;

    modport pin     (input  cos, sin, valid, zero);
    modport pout    (output cos, sin, valid, zero);    
endinterface : qam_carrier
/*------------------------------------------------------------------------------
--  qam.data = I*cos - Q*sin
    cos sin     : 1Q6
    filter I Q  : 3Q8
    QAM         : 4Q14  Take 8-bit fractional bits -> 4Q8
------------------------------------------------------------------------------*/
interface qam_port #(parameter WIDTH = 8)();
    logic signed    [WIDTH-1 : 0]   data;
    logic                           valid;

    modport pin     (input  data, valid);
    modport pout    (output data, valid);
endinterface : qam_port
