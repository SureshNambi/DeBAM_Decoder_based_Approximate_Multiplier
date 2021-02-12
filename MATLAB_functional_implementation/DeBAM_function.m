% Authors : Suresh Nambi, Kavya Radhakrishnan, Mythreye Venkatesan
% Dependencies : May require additional MATLAB Toolboxes
% Functionality : DeBAM MATLAB function to ascertain error metrics 

% ########################################################################
%           DeBAM Parameterized (N,M) Matlab Function Defintion
% ########################################################################

% Input Arguments description
% A = Input A (Expects number in decimal format)
% B = Input B (Expects number in decimal format)
% N = Multiplier bitwidth
% M = Number of Accurate blocks (description in publication DeBAM)

function [Papprox] = p_approx(A,B,n,m)
    A = reverse(dec2bin(A));
    B = reverse(dec2bin(B));
    lA = length(A);
    lB = length(B);
    a = zeros(1,n);
    b = zeros(1,n);
    for i = 1: lA
        a(i) = str2num(A(i));
    end
    for i = 1: lB
        b(i) = str2num(B(i));
    end

    Decimal_A=bi2de(a);
    % Decimal_B=bi2de(b);

    for i=1:1:n
        c(i+1)=a(i);
    end
    ax = [a, zeros(1,1)];
    for i=1:1:n+1
        d=c|ax;
    end
    AorB=0;
    for i=1:1:n+1
        AorB = AorB +d(i).*2.^(i-1);
    end
    Papprox=0;
    for i=1:2:n-m %innacurate partial products
        Two_bits_selected = b(i).*2.^(0)+b(i+1).*2.^(1);
        if Two_bits_selected==0
            Papprox= Papprox+0;
        end
        if Two_bits_selected==1
            Papprox= Papprox+Decimal_A.*2.^(i-1);
        end
        if Two_bits_selected==2
            Papprox= Papprox+Decimal_A.*2.^(i);
        end
        if Two_bits_selected==3
            Papprox= Papprox+AorB.*2.^(i-1);
        end
    end
    for i = n-m+1:n %accurate partial products
        if b(i)==1
            Papprox = Papprox+Decimal_A.*2.^(i-1);
        end
    end
end
