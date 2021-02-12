`timescale 1ns / 1ps

// Author : Suresh Nambi
// Collaborators : Anil Kumar Uppugunduru, Kavya Radhakrishnan, Mythreye Venkatesan, Dr. Syed Ershad Ahmed
// Dependencies : Simple Testbench to generate simulation results if required
// Functionality : DeBAM verilog design sources to ascertain h/w utilization metrics
// TODO : Clean up code

// PARAMETERS DESCRIPTION
// N = Multiplier bitwidth
// M = Number of Accurate blocks (description in publication DeBAM)

module DeBAM_top #(parameter N=8, M=2)(A,B,PRODUCT);
    input [N-1:0] A;
    input [N-1:0] B;
    output [2*N-1:0] PRODUCT;

    wire [N-1:1] OR;
    wire [N:0] Out [(N-M)/2-1:0]   ;
    wire [N-1:0] Out_Acc [M-1:0]   ;
    wire [(N-M)/2-3+N:0] carry  ;     // Partial Product Reduction wires

    //  PARTIAL PRODUCT GENERATION (PPG) STAGE

    // ################### Seed Inaccurate Block #########################
    Module_1_Adder  #(N) A1  (A,B[0],B[1],OR,Out[0]); // Seed Block
    // Kept separate as it has OR logic

    // ##################### Inaccurate Blocks ###########################
        genvar i;
    generate
        for (i=1;i<(N-M)/2;i=i+1)
        begin
         Module_1_General #(N) Ax (A,B[i*2],B[i*2+1],OR,Out[i]);
        end
    endgenerate


    // ##################### Accurate Blocks ###########################

    generate
        for (i=0;i<M;i=i+1)
        begin
         Module_Accurate #(N) Ax (A,B[N-M+i],Out_Acc[i]);
        end
    endgenerate



    // PARTIAL PRODUCT REDUCTION (PPR) Stage

// Here the minimum number of Inaccurate blocks is 3 becaue this statement is always executed

    wire [N+2+(((N-M)/2)-3):0] inter_sum [((N-M)/2)-3+M:0]  ;
    wire [N+1+(((N-M)/2)-3):0] inter_carry [((N-M)/2)-3+M:0] ;
    //Partial product reduction - Stage 1
    assign PRODUCT[1:0] = Out[0][1:0];
    Module_HA H11 (Out[0][2],Out[1][0],inter_sum[0][0],inter_carry[0][0]);
    Module_HA H12 (Out[0][3],Out[1][1],inter_sum[0][1],inter_carry[0][1]);
    generate
        for (i=2;i<N-1;i=i+1)
        begin
         Module_FA F1x (Out[0][i+2],Out[1][i],Out[2][i-2],inter_sum[0][i],inter_carry[0][i]);
        end
    endgenerate

    Module_HA H13 (Out[1][N-1],Out[2][N-3],inter_sum[0][N-1],inter_carry[0][N-1]);
    Module_HA H14 (Out[1][N],Out[2][N-2],inter_sum[0][N],inter_carry[0][N]);
    assign inter_sum[0][N+2:N+1] = Out[2][N:N-1];

// Generic CSA blocks incase there are more than 3 inaccurate blocks
    genvar j,k;
        generate
        for (k=1;k<((N-M)/2)-2;k=k+1)
        begin
         assign PRODUCT [k+1] = inter_sum[k-1][0];
            for (j=1;j<k+3;j=j+1)
            begin
                 Module_HA Hx__ (inter_sum[k-1][j],inter_carry[k-1][j-1],inter_sum[k][j-1],inter_carry[k][j-1]);
            end
            for (i=k+3;i<k+N+1;i=i+1)
            begin
                 Module_FA F1x (inter_sum[k-1][i],inter_carry[k-1][i-1],Out[2+k][i-k-3],inter_sum[k][i-1],inter_carry[k][i-1]);
            end
            Module_HA Hx_int (inter_sum[k-1][k+N+1],Out[2+k][N-2],inter_sum[k][k+N],inter_carry[k][k+N]);
                assign inter_sum[k][k+N+2:k+N+1] = Out[2+k][N:N-1];
            end
    endgenerate

// Seed Accurate Block
    assign PRODUCT [((N-M)/2)-2+1] = inter_sum[(N-M)/2-3][0];
    for (j=1; j<(N-M)/2+1; j=j+1)
    begin
     Module_HA Hxa_ (inter_sum[(N-M)/2-3][j],inter_carry[(N-M)/2-3][j-1],inter_sum[(N-M)/2-2][j-1],inter_carry[(N-M)/2-2][j-1]);
    end
    for (i=(N-M)/2+1; i<(N-M)/2-3+N+2; i=i+1)
    begin
     Module_FA F1xa_ (inter_sum[(N-M)/2-3][i],inter_carry[(N-M)/2-3][i-1],Out_Acc[0][i-(N-M)/2-1],inter_sum[(N-M)/2-2][i-1],inter_carry[(N-M)/2-2][i-1]);
    end
    Module_HA Hxa_ (inter_sum[(N-M)/2-3][(N-M)/2-3+N+2],Out_Acc[0][N-2],inter_sum[(N-M)/2-2][(N-M)/2-3+N+2-1],inter_carry[(N-M)/2-2][(N-M)/2-3+N+2-1]);
    assign inter_sum [(N-M)/2-2][(N-M)/2-3+N+2] = Out_Acc[0][N-1];

// Generic Accurate CSA if More than 1 accurate block outputs are present
    generate
        for (k=1; k<M; k=k+1)
        begin
            assign PRODUCT [k+((N-M)/2)-2+1] = inter_sum[(N-M)/2-3+k][0];
            for (j=1; j<(N-M)/2+1; j=j+1)
            begin
             Module_HA Hxag_ (inter_sum[(N-M)/2-3+k][j],inter_carry[(N-M)/2-3+k][j-1],inter_sum[(N-M)/2-3+k+1][j-1],inter_carry[(N-M)/2-3+k+1][j-1]);
            end
            for (i=(N-M)/2+1; i<(N-M)/2-3+N+2+1; i=i+1)
            begin
             Module_FA F1xag_ (inter_sum[(N-M)/2-3+k][i],inter_carry[(N-M)/2-3+k][i-1],Out_Acc[k][i-(N-M)/2-1],inter_sum[(N-M)/2-2+k][i-1],inter_carry[(N-M)/2-2+k][i-1]);
            end
            assign inter_sum[(N-M)/2-2+k][(N-M)/2-3+N+2+1-1] = Out_Acc[k][N-1] ;
        end
    endgenerate



// Final product calculation using a ripple carry adder

    assign PRODUCT [M+((N-M)/2)-2+1] = inter_sum[(N-M)/2-3+M][0];
    Module_HA HAf (inter_sum[(N-M)/2-3+M][1],inter_carry[(N-M)/2-3+M][0],PRODUCT[M+((N-M)/2)-2+2],carry[0]);
    generate
        for(i=1;i<((N-M)/2-3+N+1);i=i+1)
            begin
            Module_FA FAf (inter_sum[(N-M)/2-3+M][i+1],inter_carry[(N-M)/2-3+M][i],carry[i-1],PRODUCT[M+((N-M)/2)-2+2+i],carry[i]);
            end
    endgenerate
    Module_FA FAfL (inter_sum[(N-M)/2-3+M][(N-M)/2-3+N+2],inter_carry[(N-M)/2-3+M][(N-M)/2-3+N+1],carry[(N-M)/2-3+N],PRODUCT[M+((N-M)/2)+(N-M)/2-3+N+1],PRODUCT[M+((N-M)/2)+(N-M)/2-3+N+1+1]);

endmodule


// ########################## Sub Modules ################################

// DeBAM Logic block with output OR logic (Reused in other Decoder logic blocks)
module Module_1_Adder #(parameter N=8)(A,B0,B1,OR,OUT);
    input [N-1:0] A;
    input B0;
    input B1;
    output [N-1:1] OR;
    output [N:0] OUT;

    wire NB0,NB1,aB,Ab,AB;            // always defined
    wire [N-1:0] G1;
    wire [N:1] G2;
    wire [N:0] G3;



    //Decoder part
    not X(NB0,B0);
    not Y(NB1,B1);
    and A0(aB,NB1,B0);
    and A1(Ab,B1,NB0);
    and A2(AB,B1,B0);

    //Case 01 outputs
    genvar i;
    generate
        for (i=0;i<N;i=i+1)
        begin
        and aBx (G1[i],aB,A[i]);
        end
    endgenerate


    //Case 10 outputs
    generate
        for (i=0;i<N;i=i+1)
        begin
        and Abx (G2[i+1],Ab,A[i]);
        end
    endgenerate


    //OR outputs for case 11
    generate
        for (i=1;i<N;i=i+1)
        begin
        or ORx (OR[i],A[i],A[i-1]);
        end
    endgenerate


    //Case 11 outputs
     and AB0(G3[0],AB,A[0]);
        generate
        for (i=1;i<N;i=i+1)
        begin
        and ABx (G3[i],AB,OR[i]);
        end
    endgenerate
    and AB8(G3[N],AB,A[N-1]);


    //Calculating final product of 8*2 block

    or outN(OUT[N],G2[N],G3[N]);

    generate
        for (i=1;i<N;i=i+1)
        begin
        or outx (OUT[i],G3[i],G2[i],G1[i]);
        end
    endgenerate


    or out0 (OUT[0],G3[0],G1[0]);

endmodule

// DeBAM Logic block with input OR logic (Reuses OR values from seed block)
module Module_1_General#(parameter N=8)(A,B0,B1,OR,OUT);
    input [N-1:0] A;
    input B0;
    input B1;
    input [N-1:1] OR;
    output [N:0] OUT;

    wire NB0,NB1,aB,Ab,AB;            // always defined
    wire [N-1:0] G1;
    wire [N:1] G2;
    wire [N:0] G3;


    //Decoder part

    not X(NB0,B0);
    not Y(NB1,B1);
    and A0(aB,NB1,B0);
    and A1(Ab,B1,NB0);
    and A2(AB,B1,B0);

    //Case 01 outputs
    genvar i;
    generate
        for (i=0;i<N;i=i+1)
        begin
        and aBx (G1[i],aB,A[i]);
        end
    endgenerate


    //Case 10 outputs
    generate
        for (i=0;i<N;i=i+1)
        begin
        and Abx (G2[i+1],Ab,A[i]);
        end
    endgenerate


    //Case 11 outputs

         and AB0(G3[0],AB,A[0]);
        generate
        for (i=1;i<N;i=i+1)
        begin
        and ABx (G3[i],AB,OR[i]);
        end
    endgenerate
    and AB8(G3[N],AB,A[N-1]);



    //Calculating final product of 8*2 block

    or outN(OUT[N],G2[N],G3[N]);

    generate
        for (i=1;i<N;i=i+1)
        begin
        or outx (OUT[i],G3[i],G2[i],G1[i]);
        end
    endgenerate

    or out0 (OUT[0],G3[0],G1[0]);


endmodule

// Single row accurate multiplier implementation
module Module_Accurate #(parameter N=8)(A,B,OUT);
    input [N-1:0] A;
    input B;
    output [N-1:0] OUT;

    genvar i;
    generate
        for (i=0;i<N;i=i+1)
        begin
        and ACCx (OUT[i],B,A[i]);
        end
    endgenerate


endmodule

// Half adder block designed with basic gates
module Module_HA(
    input A,
    input B,
    output Sum,
    output Cout
    );

    xor x1(Sum, A, B);
    and a1(Cout, A, B);

endmodule

// Full adder blocks designed with basic gates
module Module_FA(
    input A,
    input B,
    input Cin,
    output Sum,
    output Cout
    );

    wire w1,w2,w3;

    xor x1(w1, A, B);
    xor x2(Sum, w1, Cin);
    and a1(w3, Cin, w1);
    and a2(w2, A, B);
    or o1(Cout, w2, w3);
endmodule
